from sqlalchemy import Column, String, Integer, DateTime, Boolean, ForeignKey, Text, Date
from sqlalchemy.dialects.mysql import CHAR
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from app.db.base import Base


class Habit(Base):
    __tablename__ = "habits"
    
    id = Column(CHAR(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(CHAR(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    current_streak = Column(Integer, default=0, nullable=False)
    longest_streak = Column(Integer, default=0, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="habits")
    completions = relationship("HabitCompletion", back_populates="habit", cascade="all, delete-orphan")


class HabitCompletion(Base):
    __tablename__ = "habit_completions"
    
    id = Column(CHAR(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    habit_id = Column(CHAR(36), ForeignKey("habits.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(CHAR(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    completion_date = Column(Date, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    habit = relationship("Habit", back_populates="completions")
    user = relationship("User", back_populates="habit_completions")