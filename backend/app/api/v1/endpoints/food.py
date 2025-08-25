from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from typing import List, Optional
from datetime import datetime, date, timedelta
from app.db.base import get_db
from app.core.dependencies import get_current_user, PaginationParams
from app.models.user import User
from app.models.food import FoodEntry, MealCategory
from app.schemas.food import (
    FoodEntryCreate, FoodEntryUpdate, FoodEntryResponse,
    DailySummaryResponse
)

router = APIRouter()


@router.get("/entries", response_model=List[FoodEntryResponse])
async def get_food_entries(
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
    meal_category: Optional[MealCategory] = None,
    pagination: PaginationParams = Depends(),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's food entries with optional filters."""
    query = db.query(FoodEntry).filter(FoodEntry.user_id == current_user.id)
    
    if date_from:
        query = query.filter(FoodEntry.logged_at >= date_from)
    if date_to:
        query = query.filter(FoodEntry.logged_at <= datetime.combine(date_to, datetime.max.time()))
    if meal_category:
        query = query.filter(FoodEntry.meal_category == meal_category)
    
    entries = query.order_by(FoodEntry.logged_at.desc())\
                   .offset(pagination.skip)\
                   .limit(pagination.limit)\
                   .all()
    
    return entries


@router.post("/entries", response_model=FoodEntryResponse, status_code=status.HTTP_201_CREATED)
async def create_food_entry(
    entry_data: FoodEntryCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new food entry."""
    new_entry = FoodEntry(
        user_id=current_user.id,
        food_name=entry_data.food_name,
        quantity=entry_data.quantity,
        calories=entry_data.calories,
        meal_category=entry_data.meal_category,
        nutritional_info=entry_data.nutritional_info,
        logged_at=entry_data.logged_at or datetime.utcnow()
    )
    
    db.add(new_entry)
    db.commit()
    db.refresh(new_entry)
    
    return new_entry


@router.get("/entries/{entry_id}", response_model=FoodEntryResponse)
async def get_food_entry(
    entry_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get a specific food entry."""
    entry = db.query(FoodEntry).filter(
        and_(
            FoodEntry.id == entry_id,
            FoodEntry.user_id == current_user.id
        )
    ).first()
    
    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Food entry not found"
        )
    
    return entry


@router.put("/entries/{entry_id}", response_model=FoodEntryResponse)
async def update_food_entry(
    entry_id: str,
    entry_data: FoodEntryUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update a food entry."""
    entry = db.query(FoodEntry).filter(
        and_(
            FoodEntry.id == entry_id,
            FoodEntry.user_id == current_user.id
        )
    ).first()
    
    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Food entry not found"
        )
    
    # Update fields if provided
    update_data = entry_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(entry, field, value)
    
    entry.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(entry)
    
    return entry


@router.delete("/entries/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_food_entry(
    entry_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a food entry."""
    entry = db.query(FoodEntry).filter(
        and_(
            FoodEntry.id == entry_id,
            FoodEntry.user_id == current_user.id
        )
    ).first()
    
    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Food entry not found"
        )
    
    db.delete(entry)
    db.commit()


@router.get("/daily-summary", response_model=DailySummaryResponse)
async def get_daily_summary(
    target_date: Optional[date] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get daily nutrition summary."""
    if not target_date:
        target_date = date.today()
    
    start_time = datetime.combine(target_date, datetime.min.time())
    end_time = datetime.combine(target_date, datetime.max.time())
    
    entries = db.query(FoodEntry).filter(
        and_(
            FoodEntry.user_id == current_user.id,
            FoodEntry.logged_at >= start_time,
            FoodEntry.logged_at <= end_time
        )
    ).all()
    
    # Calculate summaries
    total_calories = sum(entry.calories for entry in entries)
    meal_breakdown = {}
    nutritional_summary = {
        "carbs": 0,
        "protein": 0,
        "fat": 0,
        "fiber": 0,
        "sugar": 0,
        "sodium": 0
    }
    
    for entry in entries:
        # Meal breakdown
        category = entry.meal_category.value
        meal_breakdown[category] = meal_breakdown.get(category, 0) + entry.calories
        
        # Nutritional summary
        if entry.nutritional_info:
            for nutrient, value in entry.nutritional_info.items():
                if nutrient in nutritional_summary and value:
                    nutritional_summary[nutrient] += value
    
    return DailySummaryResponse(
        date=target_date.isoformat(),
        total_calories=total_calories,
        meal_breakdown=meal_breakdown,
        entries_count=len(entries),
        nutritional_summary=nutritional_summary
    )


@router.get("/search")
async def search_food(
    query: str = Query(..., min_length=1),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Search for food items (placeholder for food database integration)."""
    # This is a placeholder for food database search
    # In production, this would integrate with a nutrition API
    return {
        "results": [
            {"name": "Apple", "calories": 95, "serving": "1 medium"},
            {"name": "Banana", "calories": 105, "serving": "1 medium"},
            {"name": "Orange", "calories": 62, "serving": "1 medium"}
        ]
    }