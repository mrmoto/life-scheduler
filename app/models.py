"""
Life Scheduler - Database Models
"""
from datetime import datetime
from typing import Optional
from . import db


class User(db.Model):
    """
    User model for authentication and data ownership.
    
    This is a placeholder model for M1. Full authentication will be
    implemented in M2.
    """
    __tablename__ = 'users'
    
    id: int = db.Column(db.Integer, primary_key=True)
    email: str = db.Column(db.String(255), unique=True, nullable=False, index=True)
    created_at: datetime = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at: datetime = db.Column(
        db.DateTime,
        nullable=False,
        default=datetime.utcnow,
        onupdate=datetime.utcnow
    )
    
    def __repr__(self) -> str:
        return f'<User {self.email}>'






