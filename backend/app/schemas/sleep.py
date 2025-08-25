from pydantic import BaseModel, Field
from datetime import datetime, date
from typing import Optional


class SleepEntryBase(BaseModel):
    bedtime: datetime
    wake_time: datetime
    quality_rating: Optional[int] = Field(None, ge=1, le=10)
    notes: Optional[str] = None


class SleepEntryCreate(SleepEntryBase):
    pass


class SleepEntryUpdate(BaseModel):
    bedtime: Optional[datetime] = None
    wake_time: Optional[datetime] = None
    quality_rating: Optional[int] = Field(None, ge=1, le=10)
    notes: Optional[str] = None


class SleepEntryResponse(SleepEntryBase):
    id: str
    user_id: str
    duration_hours: float
    date: date
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class WeeklySummaryResponse(BaseModel):
    week_start: date
    week_end: date
    average_duration: float
    average_quality: Optional[float]
    total_entries: int
    daily_data: list[dict]