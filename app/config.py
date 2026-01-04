"""
Life Scheduler - Configuration Classes
"""
import os
from typing import Optional


class Config:
    """Base configuration class."""
    
    SECRET_KEY: str = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    SQLALCHEMY_DATABASE_URI: str = os.getenv(
        'DATABASE_URL',
        'postgresql://lifescheduler_user:password@db:5432/lifescheduler'
    )
    SQLALCHEMY_TRACK_MODIFICATIONS: bool = False
    
    @staticmethod
    def init_app(app) -> None:
        """Initialize application configuration."""
        pass


class DevelopmentConfig(Config):
    """Development environment configuration."""
    
    DEBUG: bool = True
    TESTING: bool = False


class ProductionConfig(Config):
    """Production environment configuration."""
    
    DEBUG: bool = False
    TESTING: bool = False
    
    @classmethod
    def init_app(cls, app) -> None:
        """Initialize production-specific settings."""
        Config.init_app(app)
        
        # Production-specific initialization can go here
        # (logging, error handlers, etc.)


class TestingConfig(Config):
    """Testing environment configuration."""
    
    TESTING: bool = True
    SQLALCHEMY_DATABASE_URI: str = os.getenv(
        'TEST_DATABASE_URL',
        'postgresql://lifescheduler_user:password@db:5432/lifescheduler_test'
    )


# Configuration dictionary
config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}






