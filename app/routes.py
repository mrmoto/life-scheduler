"""
Life Scheduler - Route Handlers
"""
from flask import Blueprint, jsonify, Response
from typing import Tuple
from . import db

bp = Blueprint('main', __name__)


@bp.route('/')
def index() -> str:
    """
    Root endpoint - API identification.
    
    Returns:
        Simple identification string
    """
    return 'Life Scheduler API'


@bp.route('/health')
def health() -> Tuple[Response, int]:
    """
    Health check endpoint for container monitoring.
    
    Tests:
    - Flask application is running
    - Database connection is functional
    
    Returns:
        JSON response with health status
    """
    try:
        # Test database connection
        db.session.execute(db.text('SELECT 1'))
        db_status = 'connected'
        status_code = 200
    except Exception as e:
        db_status = f'error: {str(e)}'
        status_code = 503
    
    response_data = {
        'status': 'ok' if status_code == 200 else 'error',
        'database': db_status
    }
    
    return jsonify(response_data), status_code






