from sqlalchemy import Column, String, Integer, Float, DateTime, Date, ForeignKey, Text
from sqlalchemy.dialects.mysql import CHAR
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from app.db.base import Base


class SleepEntry(Base):
    __tablename__ = "sleep_entries"
    
    id = Column(CHAR(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(CHAR(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    bedtime = Column(DateTime, nullable=False)
    wake_time = Column(DateTime, nullable=False)
    duration_hours = Column(Float, nullable=False)  # Calculated field
    quality_rating = Column(Integer, nullable=True)  # 1-10 scale
    notes = Column(Text, nullable=True)
    date = Column(Date, nullable=False, index=True)  # Date of sleep (based on wake time)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="sleep_entries")