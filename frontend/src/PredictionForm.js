import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './PredictionForm.css';

function PredictionForm({ onPredictionMade }) {
  const [formData, setFormData] = useState({
    age: '',
    hypertension: 0,
    heart_disease: 0,
    avg_glucose_level: '',
    bmi: '',
    smoking_status: 0
  });

  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [modelInfo, setModelInfo] = useState(null);

  const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';

  useEffect(() => {
    fetchModelInfo();
  }, []);

  const fetchModelInfo = async () => {
    try {
      const response = await axios.get(`${API_URL}/api/model-info`);
      setModelInfo(response.data);
    } catch (err) {
      console.error('Error fetching model info:', err);
    }
  };

  const handleInputChange = (e) => {
    const { name, value, type } = e.target;
    const numericValue = type === 'number' ? (value === '' ? '' : parseFloat(value)) : 
                         type === 'select-one' ? parseInt(value) : value;
    
    setFormData(prev => ({
      ...prev,
      [name]: numericValue
    }));
    setError('');
  };

  const validateForm = () => {
    const errors = [];

    if (!formData.age || formData.age < 18 || formData.age > 120) {
      errors.push('Age must be between 18 and 120');
    }
    if (!formData.avg_glucose_level || formData.avg_glucose_level < 50 || formData.avg_glucose_level > 300) {
      errors.push('Glucose level must be between 50 and 300 mg/dL');
    }
    if (!formData.bmi || formData.bmi < 10 || formData.bmi > 50) {
      errors.push('BMI must be between 10 and 50');
    }

    if (errors.length > 0) {
      setError(errors.join(', '));
      return false;
    }
    return true;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    setLoading(true);
    setError('');
    setResult(null);
    
    try {
      const response = await axios.post(`${API_URL}/api/predict`, formData);
      
      if (response.status === 200) {
        setResult(response.data);
        onPredictionMade(response.data);
      }
    } catch (err) {
      const errorMessage = err.response?.data?.details?.join(', ') ||
                          err.response?.data?.error ||
                          'Failed to get prediction. Please try again.';
      setError(errorMessage);
      console.error('Prediction error:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setFormData({
      age: '',
      hypertension: 0,
      heart_disease: 0,
      avg_glucose_level: '',
      bmi: '',
      smoking_status: 0
    });
    setResult(null);
    setError('');
  };

  const getRiskColor = (riskLevel) => {
    switch (riskLevel) {
      case 'High':
        return '#f44336';
      case 'Medium':
        return '#ff9800';
      case 'Low':
        return '#4caf50';
      default:
        return '#2196f3';
    }
  };

  return (
    <div className="prediction-form-container">
      <div className="form-section">
        <h2>📋 Patient Information</h2>
        <form onSubmit={handleSubmit}>
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="age">Age (years) *</label>
              <input
                id="age"
                type="number"
                name="age"
                value={formData.age}
                onChange={handleInputChange}
                placeholder="Enter age (18-120)"
                min="18"
                max="120"
                required
              />
              <small>Range: 18-120 years</small>
            </div>

            <div className="form-group">
              <label htmlFor="bmi">BMI *</label>
              <input
                id="bmi"
                type="number"
                name="bmi"
                value={formData.bmi}
                onChange={handleInputChange}
                placeholder="Enter BMI"
                step="0.1"
                min="10"
                max="50"
                required
              />
              <small>Range: 10-50 kg/m²</small>
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label htmlFor="avg_glucose_level">Glucose Level (mg/dL) *</label>
              <input
                id="avg_glucose_level"
                type="number"
                name="avg_glucose_level"
                value={formData.avg_glucose_level}
                onChange={handleInputChange}
                placeholder="Enter glucose level"
                step="0.1"
                min="50"
                max="300"
                required
              />
              <small>Range: 50-300 mg/dL</small>
            </div>

            <div className="form-group">
              <label htmlFor="smoking_status">Smoking Status</label>
              <select
                id="smoking_status"
                name="smoking_status"
                value={formData.smoking_status}
                onChange={handleInputChange}
              >
                <option value={0}>Never smoked</option>
                <option value={1}>Formerly smoked</option>
                <option value={2}>Smokes</option>
                <option value={3}>Unknown</option>
              </select>
            </div>
          </div>

          <div className="form-row">
            <div className="form-group checkbox">
              <label htmlFor="hypertension">
                <input
                  id="hypertension"
                  type="checkbox"
                  name="hypertension"
                  checked={formData.hypertension === 1}
                  onChange={(e) => setFormData(prev => ({
                    ...prev,
                    hypertension: e.target.checked ? 1 : 0
                  }))}
                />
                Have Hypertension?
              </label>
            </div>

            <div className="form-group checkbox">
              <label htmlFor="heart_disease">
                <input
                  id="heart_disease"
                  type="checkbox"
                  name="heart_disease"
                  checked={formData.heart_disease === 1}
                  onChange={(e) => setFormData(prev => ({
                    ...prev,
                    heart_disease: e.target.checked ? 1 : 0
                  }))}
                />
                Have Heart Disease?
              </label>
            </div>
          </div>

          <div className="form-actions">
            <button type="submit" className="btn btn-primary" disabled={loading}>
              {loading ? '⏳ Analyzing...' : '🔮 Get Risk Assessment'}
            </button>
            <button type="button" className="btn btn-secondary" onClick={handleReset}>
              🔄 Reset
            </button>
          </div>
        </form>

        {error && <div className="error-message">❌ {error}</div>}
      </div>

      {result && (
        <div className="result-section">
          <h3>📊 Assessment Results</h3>
          
          <div className="risk-level-display" style={{ borderColor: getRiskColor(result.risk_level) }}>
            <div className="risk-level-label">Risk Level</div>
            <div className="risk-level-value" style={{ color: getRiskColor(result.risk_level) }}>
              {result.risk_level}
            </div>
          </div>

          <div className="probabilities">
            <div className="probability-item">
              <span>Stroke Probability</span>
              <div className="probability-bar">
                <div className="probability-fill" style={{
                  width: `${result.stroke_probability * 100}%`,
                  backgroundColor: getRiskColor(result.risk_level)
                }}></div>
              </div>
              <span className="probability-value">{(result.stroke_probability * 100).toFixed(1)}%</span>
            </div>

            <div className="probability-item">
              <span>No Stroke Probability</span>
              <div className="probability-bar">
                <div className="probability-fill" style={{
                  width: `${result.no_stroke_probability * 100}%`,
                  backgroundColor: '#4caf50'
                }}></div>
              </div>
              <span className="probability-value">{(result.no_stroke_probability * 100).toFixed(1)}%</span>
            </div>

            <div className="confidence">
              <span>Confidence Score</span>
              <span className="confidence-value">{(result.confidence * 100).toFixed(1)}%</span>
            </div>
          </div>

          <div className="assessment-meta">
            <p>⏰ Assessment Time: {new Date(result.timestamp).toLocaleString()}</p>
            <p className="disclaimer">
              ⚠️ This assessment is for informational purposes only and should not replace professional medical advice.
            </p>
          </div>
        </div>
      )}

      {modelInfo && (
        <div className="model-info">
          <h4>ℹ️ Model Information</h4>
          <p>Type: {modelInfo.model?.model_type}</p>
          <p>Accuracy: {(modelInfo.model?.accuracy * 100).toFixed(1)}%</p>
          <p>Features: {modelInfo.features?.join(', ')}</p>
        </div>
      )}
    </div>
  );
}

export default PredictionForm;
