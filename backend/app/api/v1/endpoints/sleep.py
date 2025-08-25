from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import and_, func
from typing import List, Optional
from datetime import datetime, date, timedelta
from app.db.base import get_db
from app.core.dependencies import get_current_user, PaginationParams
from app.models.user import User
from app.models.sleep import SleepEntry
from app.schemas.sleep import (
    SleepEntryCreate, SleepEntryUpdate, SleepEntryResponse,
    WeeklySummaryResponse
)

router = APIRouter()


def calculate_duration(bedtime: datetime, wake_time: datetime) -> float:
    """Calculate sleep duration in hours."""
    duration = wake_time - bedtime
    if duration.total_seconds() < 0:
        # Handle case where wake time is next day
        duration = duration + timedelta(days=1)
    return round(duration.total_seconds() / 3600, 2)


@router.get("/entries", response_model=List[SleepEntryResponse])
async def get_sleep_entries(
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
    pagination: PaginationParams = Depends(),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's sleep entries with optional filters."""
    query = db.query(SleepEntry).filter(SleepEntry.user_id == current_user.id)
    
    if date_from:
        query = query.filter(SleepEntry.date >= date_from)
    if date_to:
        query = query.filter(SleepEntry.date <= date_to)
    
    entries = query.order_by(SleepEntry.date.desc())\
                   .offset(pagination.skip)\
                   .limit(pagination.limit)\
                   .all()
    
    return entries


@router.post("/entries", response_model=SleepEntryResponse, status_code=status.HTTP_201_CREATED)
async def create_sleep_entry(
    entry_data: SleepEntryCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new sleep entry."""
    # Calculate duration
    duration = calculate_duration(entry_data.bedtime, entry_data.wake_time)
    
    # Determine date based on wake time
    sleep_date = entry_data.wake_time.date()
    
    # Check if entry already exists for this date
    existing_entry = db.query(SleepEntry).filter(
        and_(
            SleepEntry.user_id == current_user.id,
            SleepEntry.date == sleep_date
        )
    ).first()
    
    if existing_entry:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Sleep entry already exists for {sleep_date}"
        )
    
    new_entry = SleepEntry(
        user_id=current_user.id,
        bedtime=entry_data.bedtime,
        wake_time=entry_data.wake_time,
        duration_hours=duration,
        quality_rating=entry_data.quality_rating,
        notes=entry_data.notes,
        date=sleep_date
    )
    
    db.add(new_entry)
    db.commit()
    db.refresh(new_entry)
    
    return new_entry


@router.get("/entries/{entry_id}", response_model=SleepEntryResponse)
async def get_sleep_entry(
    entry_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get a specific sleep entry."""
    entry = db.query(SleepEntry).filter(
        and_(
            SleepEntry.id == entry_id,
            SleepEntry.user_id == current_user.id
        )
    ).first()
    
    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Sleep entry not found"
        )
    
    return entry


@router.put("/entries/{entry_id}", response_model=SleepEntryResponse)
async def update_sleep_entry(
    entry_id: str,
    entry_data: SleepEntryUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update a sleep entry."""
    entry = db.query(SleepEntry).filter(
        and_(
            SleepEntry.id == entry_id,
            SleepEntry.user_id == current_user.id
        )
    ).first()
    
    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Sleep entry not found"
        )
    
    # Update fields if provided
    update_data = entry_data.model_dump(exclude_unset=True)
    
    # If bedtime or wake_time is updated, recalculate duration
    if "bedtime" in update_data or "wake_time" in update_data:
        bedtime = update_data.get("bedtime", entry.bedtime)
        wake_time = update_data.get("wake_time", entry.wake_time)
        entry.duration_hours = calculate_duration(bedtime, wake_time)
        
        # Update date based on new wake time
        if "wake_time" in update_data:
            entry.date = wake_time.date()
    
    for field, value in update_data.items():
        if field not in ["bedtime", "wake_time"]:
            setattr(entry, field, value)
    
    if "bedtime" in update_data:
        entry.bedtime = update_data["bedtime"]
    if "wake_time" in update_data:
        entry.wake_time = update_data["wake_time"]
    
    entry.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(entry)
    
    return entry


@router.delete("/entries/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_sleep_entry(
    entry_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a sleep entry."""
    entry = db.query(SleepEntry).filter(
        and_(
            SleepEntry.id == entry_id,
            SleepEntry.user_id == current_user.id
        )
    ).first()
    
    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Sleep entry not found"
        )
    
    db.delete(entry)
    db.commit()


@router.get("/weekly-summary", response_model=WeeklySummaryResponse)
async def get_weekly_summary(
    start_date: Optional[date] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get weekly sleep summary."""
    if not start_date:
        # Default to current week (Monday to Sunday)
        today = date.today()
        start_date = today - timedelta(days=today.weekday())
    
    end_date = start_date + timedelta(days=6)
    
    entries = db.query(SleepEntry).filter(
        and_(
            SleepEntry.user_id == current_user.id,
            SleepEntry.date >= start_date,
            SleepEntry.date <= end_date
        )
    ).order_by(SleepEntry.date).all()
    
    # Calculate averages
    if entries:
        avg_duration = sum(e.duration_hours for e in entries) / len(entries)
        quality_ratings = [e.quality_rating for e in entries if e.quality_rating]
        avg_quality = sum(quality_ratings) / len(quality_ratings) if quality_ratings else None
    else:
        avg_duration = 0
        avg_quality = None
    
    # Build daily data
    daily_data = []
    for entry in entries:
        daily_data.append({
            "date": entry.date.isoformat(),
            "duration_hours": entry.duration_hours,
            "quality_rating": entry.quality_rating,
            "bedtime": entry.bedtime.isoformat(),
            "wake_time": entry.wake_time.isoformat()
        })
    
    return WeeklySummaryResponse(
        week_start=start_date,
        week_end=end_date,
        average_duration=round(avg_duration, 2),
        average_quality=round(avg_quality, 1) if avg_quality else None,
        total_entries=len(entries),
        daily_data=daily_data
    )