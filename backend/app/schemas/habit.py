from pydantic import BaseModel, Field
from datetime import datetime, date
from typing import Optional


class HabitBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None


class HabitCreate(HabitBase):
    pass


class HabitUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    is_active: Optional[bool] = None


class HabitResponse(HabitBase):
    id: str
    user_id: str
    current_streak: int
    longest_streak: int
    is_active: bool
    created_at: datetime
    updated_at: datetime
    is_completed_today: Optional[bool] = None
    
    class Config:
        from_attributes = True


class HabitCompletionCreate(BaseModel):
    habit_id: str
    completion_date: Optional[date] = None


class HabitCompletionResponse(BaseModel):
    id: str
    habit_id: str
    user_id: str
    completion_date: date
    created_at: datetime
    
    class Config:
        from_attributes = True