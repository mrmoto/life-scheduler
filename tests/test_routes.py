"""Tests for route handlers."""
from flask import Flask
from flask.testing import FlaskClient
import pytest


def test_health_endpoint(client: FlaskClient) -> None:
    """Test health check endpoint."""
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data is not None
    assert 'status' in data
    assert 'database' in data
    assert data['status'] == 'healthy'


def test_index_endpoint(client: FlaskClient) -> None:
    """Test root endpoint."""
    response = client.get('/')
    assert response.status_code == 200
    data = response.get_json()
    assert data is not None
    assert 'message' in data
    assert data['message'] == 'Life Scheduler API'

