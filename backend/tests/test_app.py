import sys
import os
import pytest
from datetime import datetime

# Add parent directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

# Basic smoke tests
class TestApp:
    """Test cases for the Flask application"""
    
    def test_imports(self):
        """Test that the app module can be imported"""
        try:
            import app
            assert app is not None
        except ImportError as e:
            pytest.fail(f"Failed to import app: {e}")
    
    def test_validation_rules_exist(self):
        """Test that validation rules are properly defined"""
        from app import VALIDATION_RULES
        required_fields = ['age', 'hypertension', 'heart_disease', 
                          'avg_glucose_level', 'bmi', 'smoking_status']
        for field in required_fields:
            assert field in VALIDATION_RULES, f"Missing validation rule for {field}"
    
    def test_model_info_exists(self):
        """Test that model info metadata is defined"""
        from app import MODEL_INFO
        assert 'model_type' in MODEL_INFO
        assert 'features' in MODEL_INFO
        assert len(MODEL_INFO['features']) == 6


class TestValidation:
    """Test cases for input validation"""
    
    def test_validate_input_function_exists(self):
        """Test that validate_input function exists"""
        from app import validate_input
        assert callable(validate_input)
