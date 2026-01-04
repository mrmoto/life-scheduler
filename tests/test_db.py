"""
Life Scheduler - Database Connection Tests
"""
import pytest
from app import db
from app.models import User


def test_database_connection(client):
    """
    Test that database connection works via health endpoint.
    
    This verifies:
    - Flask application starts
    - Database is reachable
    - Health endpoint responds correctly
    """
    response = client.get('/health')
    assert response.status_code == 200
    
    data = response.get_json()
    assert data['status'] == 'ok'
    assert data['database'] == 'connected'


def test_user_model_creation(db):
    """
    Test that User model can be created and persisted.
    
    This verifies:
    - SQLAlchemy models work
    - Database tables exist
    - CRUD operations function
    """
    # Create user
    user = User(email='test@example.com')
    db.session.add(user)
    db.session.commit()
    
    # Verify user was created
    assert user.id is not None
    assert user.email == 'test@example.com'
    assert user.created_at is not None
    
    # Query user back
    queried_user = User.query.filter_by(email='test@example.com').first()
    assert queried_user is not None
    assert queried_user.id == user.id


def test_root_endpoint(client):
    """
    Test that root endpoint returns API identification.
    """
    response = client.get('/')
    assert response.status_code == 200
    assert b'Life Scheduler API' in response.data






