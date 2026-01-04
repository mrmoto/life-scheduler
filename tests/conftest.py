"""
Life Scheduler - Pytest Fixtures and Configuration
"""
import pytest
from typing import Generator
from app import create_app, db as _db
from app.models import User


@pytest.fixture(scope='session')
def app() -> Generator:
    """
    Create application instance for testing.
    
    Yields:
        Flask application configured for testing
    """
    _app = create_app()
    _app.config['TESTING'] = True
    _app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://lifescheduler_user:changeme_secure_password@db:5432/lifescheduler'
    
    with _app.app_context():
        yield _app


@pytest.fixture(scope='function')
def db(app) -> Generator:
    """
    Create database tables for testing.
    
    Tables are created before each test and dropped after.
    
    Yields:
        SQLAlchemy database instance
    """
    with app.app_context():
        _db.create_all()
        yield _db
        _db.session.remove()
        _db.drop_all()


@pytest.fixture(scope='function')
def client(app):
    """
    Create test client for making requests.
    
    Yields:
        Flask test client
    """
    return app.test_client()






