from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, Dict, Any
from app.models.food import MealCategory


class NutritionalInfo(BaseModel):
    carbs: Optional[float] = None
    protein: Optional[float] = None
    fat: Optional[float] = None
    fiber: Optional[float] = None
    sugar: Optional[float] = None
    sodium: Optional[float] = None


class FoodEntryBase(BaseModel):
    food_name: str = Field(..., min_length=1, max_length=255)
    quantity: float = Field(..., gt=0)
    calories: int = Field(..., ge=0)
    meal_category: MealCategory
    nutritional_info: Optional[Dict[str, Any]] = None


class FoodEntryCreate(FoodEntryBase):
    logged_at: Optional[datetime] = None


class FoodEntryUpdate(BaseModel):
    food_name: Optional[str] = Field(None, min_length=1, max_length=255)
    quantity: Optional[float] = Field(None, gt=0)
    calories: Optional[int] = Field(None, ge=0)
    meal_category: Optional[MealCategory] = None
    nutritional_info: Optional[Dict[str, Any]] = None
    logged_at: Optional[datetime] = None


class FoodEntryResponse(FoodEntryBase):
    id: str
    user_id: str
    logged_at: datetime
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class DailySummaryResponse(BaseModel):
    date: str
    total_calories: int
    meal_breakdown: Dict[str, int]
    entries_count: int
    nutritional_summary: Dict[str, float]