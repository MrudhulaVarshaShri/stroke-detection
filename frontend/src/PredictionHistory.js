import React from 'react';
import './PredictionHistory.css';

function PredictionHistory({ predictions }) {
  if (predictions.length === 0) {
    return (
      <div className="history-container">
        <div className="empty-state">
          <p>📭 No predictions yet</p>
          <p>Start by making a prediction in the "New Prediction" tab</p>
        </div>
      </div>
    );
  }

  const getRiskColor = (riskLevel) => {
    switch (riskLevel) {
      case 'High': return '#f44336';
      case 'Medium': return '#ff9800';
      case 'Low': return '#4caf50';
      default: return '#2196f3';
    }
  };

  return (
    <div className="history-container">
      <h2>📋 Prediction History</h2>
      <p className="history-count">Total Predictions: {predictions.length}</p>

      <div className="history-list">
        {predictions.map((prediction, index) => (
          <div key={index} className="history-card">
            <div className="history-header">
              <div className="history-info">
                <span className="history-index">#{index + 1}</span>
                <span className="history-time">
                  ⏰ {new Date(prediction.timestamp).toLocaleString()}
                </span>
              </div>
              <div
                className="risk-badge"
                style={{ backgroundColor: getRiskColor(prediction.risk_level) }}
              >
                {prediction.risk_level}
              </div>
            </div>

            <div className="history-details">
              <div className="detail-row">
                <span className="detail-label">Age:</span>
                <span className="detail-value">{prediction.patient_data.age} years</span>
              </div>
              <div className="detail-row">
                <span className="detail-label">BMI:</span>
                <span className="detail-value">{prediction.patient_data.bmi} kg/m²</span>
              </div>
              <div className="detail-row">
                <span className="detail-label">Glucose Level:</span>
                <span className="detail-value">{prediction.patient_data.avg_glucose_level} mg/dL</span>
              </div>
              <div className="detail-row">
                <span className="detail-label">Hypertension:</span>
                <span className="detail-value">{prediction.patient_data.hypertension ? '✓ Yes' : '✗ No'}</span>
              </div>
              <div className="detail-row">
                <span className="detail-label">Heart Disease:</span>
                <span className="detail-value">{prediction.patient_data.heart_disease ? '✓ Yes' : '✗ No'}</span>
              </div>
            </div>

            <div className="history-probabilities">
              <div className="prob-item">
                <span>Stroke Risk:</span>
                <span className="prob-value">{(prediction.stroke_probability * 100).toFixed(1)}%</span>
              </div>
              <div className="prob-item">
                <span>No Stroke:</span>
                <span className="prob-value">{(prediction.no_stroke_probability * 100).toFixed(1)}%</span>
              </div>
              <div className="prob-item">
                <span>Confidence:</span>
                <span className="prob-value">{(prediction.confidence * 100).toFixed(1)}%</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default PredictionHistory;
