"""Route handlers for the Flask application."""
from flask import Blueprint, jsonify
from app import db
from sqlalchemy import text
from typing import Dict, Any

bp = Blueprint('routes', __name__)


@bp.route('/health', methods=['GET'])
def health() -> Dict[str, Any]:
    """
    Health check endpoint.
    
    Returns:
        JSON response with status and database connection status
    """
    try:
        # Test database connection
        db.session.execute(text('SELECT 1'))
        db_status = 'connected'
    except Exception as e:
        db_status = f'error: {str(e)}'
    
    return jsonify({
        'status': 'healthy',
        'database': db_status
    }), 200


@bp.route('/', methods=['GET'])
def index() -> Dict[str, Any]:
    """
    Root endpoint.
    
    Returns:
        JSON response with API name
    """
    return jsonify({'message': 'Life Scheduler API'}), 200

