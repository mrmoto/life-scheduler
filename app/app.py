"""
Life Scheduler - Application Entry Point
"""
from . import create_app, db
from .models import User

# Create Flask application
app = create_app()

# Create database tables (will be replaced by Alembic migrations)
with app.app_context():
    db.create_all()


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)






