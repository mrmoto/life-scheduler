"""
Life Scheduler - Flask Application Factory
"""
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Initialize SQLAlchemy
db = SQLAlchemy()


def create_app() -> Flask:
    """
    Application factory pattern for Flask app creation.
    
    Returns:
        Configured Flask application instance
    """
    app = Flask(__name__)
    
    # Load configuration
    app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')
    app.config['DEBUG'] = os.getenv('DEBUG', '0') == '1'
    
    # Initialize extensions
    db.init_app(app)
    
    # Register blueprints (routes will be added later)
    with app.app_context():
        from . import routes
        app.register_blueprint(routes.bp)
    
    return app






