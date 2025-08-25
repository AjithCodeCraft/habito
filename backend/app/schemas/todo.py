from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional


class TodoBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)  # Task name
    description: Optional[str] = None  # Task description (optional)
    priority: int = Field(..., ge=1, le=3)
    due_date: Optional[datetime] = None


class TodoCreate(TodoBase):
    pass


class TodoUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    priority: Optional[int] = Field(None, ge=1, le=3)
    is_completed: Optional[bool] = None
    due_date: Optional[datetime] = None


class TodoResponse(TodoBase):
    id: str
    user_id: str
    is_completed: bool
    completed_at: Optional[datetime]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True