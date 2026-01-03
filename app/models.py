"""SQLAlchemy database models."""
from app import db
from datetime import datetime
from typing import Optional


class BaseModel:
    """Base model with common fields."""
    id: int = db.Column(db.Integer, primary_key=True)
    created_at: datetime = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at: datetime = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)


# Base class for Alembic migrations - use db.Model directly
Base = db.Model

