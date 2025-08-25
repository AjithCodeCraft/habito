from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import and_, func
from typing import List, Optional
from datetime import datetime, date, timedelta
from app.db.base import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.models.habit import Habit, HabitCompletion
from app.schemas.habit import (
    HabitCreate, HabitUpdate, HabitResponse,
    HabitCompletionCreate, HabitCompletionResponse
)

router = APIRouter()


def update_habit_streak(habit: Habit, db: Session):
    """Update habit streak based on completions."""
    today = date.today()
    yesterday = today - timedelta(days=1)
    
    # Check if completed today
    today_completion = db.query(HabitCompletion).filter(
        and_(
            HabitCompletion.habit_id == habit.id,
            HabitCompletion.completion_date == today
        )
    ).first()
    
    # Check if completed yesterday
    yesterday_completion = db.query(HabitCompletion).filter(
        and_(
            HabitCompletion.habit_id == habit.id,
            HabitCompletion.completion_date == yesterday
        )
    ).first()
    
    if today_completion:
        if yesterday_completion:
            # Continue streak
            habit.current_streak = habit.current_streak + 1 if habit.current_streak >= 0 else 1
        else:
            # Start new streak
            habit.current_streak = 1
    else:
        if not yesterday_completion:
            # Streak broken
            habit.current_streak = 0
    
    # Update longest streak
    if habit.current_streak > habit.longest_streak:
        habit.longest_streak = habit.current_streak
    
    db.commit()


@router.get("/", response_model=List[HabitResponse])
async def get_habits(
    is_active: Optional[bool] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's habits."""
    query = db.query(Habit).filter(Habit.user_id == current_user.id)
    
    if is_active is not None:
        query = query.filter(Habit.is_active == is_active)
    
    habits = query.order_by(Habit.created_at.desc()).all()
    
    # Check if each habit is completed today
    today = date.today()
    habit_responses = []
    
    for habit in habits:
        completion = db.query(HabitCompletion).filter(
            and_(
                HabitCompletion.habit_id == habit.id,
                HabitCompletion.completion_date == today
            )
        ).first()
        
        habit_dict = {
            "id": habit.id,
            "user_id": habit.user_id,
            "name": habit.name,
            "description": habit.description,
            "current_streak": habit.current_streak,
            "longest_streak": habit.longest_streak,
            "is_active": habit.is_active,
            "created_at": habit.created_at,
            "updated_at": habit.updated_at,
            "is_completed_today": completion is not None
        }
        habit_responses.append(HabitResponse(**habit_dict))
    
    return habit_responses


@router.post("/", response_model=HabitResponse, status_code=status.HTTP_201_CREATED)
async def create_habit(
    habit_data: HabitCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new habit."""
    # Check if user has reached habit limit (3 active habits)
    active_habits_count = db.query(func.count(Habit.id)).filter(
        and_(
            Habit.user_id == current_user.id,
            Habit.is_active == True
        )
    ).scalar()
    
    if active_habits_count >= 3:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Maximum of 3 active habits allowed"
        )
    
    new_habit = Habit(
        user_id=current_user.id,
        name=habit_data.name,
        description=habit_data.description
    )
    
    db.add(new_habit)
    db.commit()
    db.refresh(new_habit)
    
    return HabitResponse(
        **new_habit.__dict__,
        is_completed_today=False
    )


@router.get("/{habit_id}", response_model=HabitResponse)
async def get_habit(
    habit_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get a specific habit."""
    habit = db.query(Habit).filter(
        and_(
            Habit.id == habit_id,
            Habit.user_id == current_user.id
        )
    ).first()
    
    if not habit:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Habit not found"
        )
    
    # Check if completed today
    today = date.today()
    completion = db.query(HabitCompletion).filter(
        and_(
            HabitCompletion.habit_id == habit.id,
            HabitCompletion.completion_date == today
        )
    ).first()
    
    return HabitResponse(
        **habit.__dict__,
        is_completed_today=completion is not None
    )


@router.put("/{habit_id}", response_model=HabitResponse)
async def update_habit(
    habit_id: str,
    habit_data: HabitUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update a habit."""
    habit = db.query(Habit).filter(
        and_(
            Habit.id == habit_id,
            Habit.user_id == current_user.id
        )
    ).first()
    
    if not habit:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Habit not found"
        )
    
    # If activating a habit, check limit
    if habit_data.is_active is True and not habit.is_active:
        active_habits_count = db.query(func.count(Habit.id)).filter(
            and_(
                Habit.user_id == current_user.id,
                Habit.is_active == True
            )
        ).scalar()
        
        if active_habits_count >= 3:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Maximum of 3 active habits allowed"
            )
    
    # Update fields if provided
    update_data = habit_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(habit, field, value)
    
    habit.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(habit)
    
    # Check if completed today
    today = date.today()
    completion = db.query(HabitCompletion).filter(
        and_(
            HabitCompletion.habit_id == habit.id,
            HabitCompletion.completion_date == today
        )
    ).first()
    
    return HabitResponse(
        **habit.__dict__,
        is_completed_today=completion is not None
    )


@router.delete("/{habit_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_habit(
    habit_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a habit."""
    habit = db.query(Habit).filter(
        and_(
            Habit.id == habit_id,
            Habit.user_id == current_user.id
        )
    ).first()
    
    if not habit:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Habit not found"
        )
    
    db.delete(habit)
    db.commit()


@router.post("/{habit_id}/complete", response_model=HabitCompletionResponse)
async def complete_habit(
    habit_id: str,
    completion_data: Optional[HabitCompletionCreate] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark a habit as complete for a specific date."""
    habit = db.query(Habit).filter(
        and_(
            Habit.id == habit_id,
            Habit.user_id == current_user.id
        )
    ).first()
    
    if not habit:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Habit not found"
        )
    
    completion_date = completion_data.completion_date if completion_data else date.today()
    
    # Check if already completed for this date
    existing_completion = db.query(HabitCompletion).filter(
        and_(
            HabitCompletion.habit_id == habit_id,
            HabitCompletion.completion_date == completion_date
        )
    ).first()
    
    if existing_completion:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Habit already completed for {completion_date}"
        )
    
    # Create completion record
    new_completion = HabitCompletion(
        habit_id=habit_id,
        user_id=current_user.id,
        completion_date=completion_date
    )
    
    db.add(new_completion)
    db.commit()
    
    # Update streak
    update_habit_streak(habit, db)
    
    db.refresh(new_completion)
    
    return new_completion


@router.delete("/{habit_id}/complete", status_code=status.HTTP_204_NO_CONTENT)
async def uncomplete_habit(
    habit_id: str,
    completion_date: Optional[date] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Remove completion for a habit on a specific date."""
    if not completion_date:
        completion_date = date.today()
    
    completion = db.query(HabitCompletion).filter(
        and_(
            HabitCompletion.habit_id == habit_id,
            HabitCompletion.user_id == current_user.id,
            HabitCompletion.completion_date == completion_date
        )
    ).first()
    
    if not completion:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Habit completion not found"
        )
    
    habit = db.query(Habit).filter(Habit.id == habit_id).first()
    
    db.delete(completion)
    db.commit()
    
    # Update streak
    if habit:
        update_habit_streak(habit, db)