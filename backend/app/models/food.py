from sqlalchemy import Column, String, Integer, Float, DateTime, ForeignKey, Enum, JSON
from sqlalchemy.dialects.mysql import CHAR
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
import enum
from app.db.base import Base


class MealCategory(str, enum.Enum):
    BREAKFAST = "breakfast"
    LUNCH = "lunch"
    DINNER = "dinner"
    SNACK = "snack"


class FoodEntry(Base):
    __tablename__ = "food_entries"
    
    id = Column(CHAR(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(CHAR(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    food_name = Column(String(255), nullable=False)
    quantity = Column(Float, nullable=False, default=1.0)
    calories = Column(Integer, nullable=False)
    meal_category = Column(Enum(MealCategory), nullable=False)
    nutritional_info = Column(JSON, nullable=True)  # {carbs, protein, fat, fiber, sugar, sodium}
    logged_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="food_entries")