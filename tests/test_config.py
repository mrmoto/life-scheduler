"""
Life Scheduler - Configuration Tests
"""
import pytest
from app.config import DevelopmentConfig, ProductionConfig, TestingConfig, config


def test_development_config():
    """Test development configuration settings."""
    assert DevelopmentConfig.DEBUG is True
    assert DevelopmentConfig.TESTING is False


def test_production_config():
    """Test production configuration settings."""
    assert ProductionConfig.DEBUG is False
    assert ProductionConfig.TESTING is False


def test_testing_config():
    """Test testing configuration settings."""
    assert TestingConfig.TESTING is True


def test_config_dictionary():
    """Test configuration dictionary contains all configs."""
    assert 'development' in config
    assert 'production' in config
    assert 'testing' in config
    assert 'default' in config
    
    assert config['development'] == DevelopmentConfig
    assert config['production'] == ProductionConfig
    assert config['testing'] == TestingConfig
    assert config['default'] == DevelopmentConfig






