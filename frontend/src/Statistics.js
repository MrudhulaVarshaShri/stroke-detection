import React from 'react';
import './Statistics.css';

function Statistics({ stats }) {
  if (!stats) {
    return (
      <div className="statistics-container">
        <div className="loading">
          <p>⏳ Loading statistics...</p>
        </div>
      </div>
    );
  }

  if (stats.total_predictions === 0) {
    return (
      <div className="statistics-container">
        <div className="empty-state">
          <p>📊 No data available yet</p>
          <p>Make some predictions to see statistics</p>
        </div>
      </div>
    );
  }

  const highRiskPercent = (stats.risk_distribution.high / stats.total_predictions) * 100;
  const mediumRiskPercent = (stats.risk_distribution.medium / stats.total_predictions) * 100;
  const lowRiskPercent = (stats.risk_distribution.low / stats.total_predictions) * 100;

  return (
    <div className="statistics-container">
      <h2>📊 Prediction Statistics</h2>

      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-title">Total Predictions</div>
          <div className="stat-value">{stats.total_predictions}</div>
        </div>

        <div className="stat-card">
          <div className="stat-title">Average Patient Age</div>
          <div className="stat-value">{stats.average_age.toFixed(1)} years</div>
        </div>

        <div className="stat-card">
          <div className="stat-title">Last Updated</div>
          <div className="stat-value">{new Date(stats.timestamp).toLocaleTimeString()}</div>
        </div>
      </div>

      <div className="risk-distribution">
        <h3>🎯 Risk Distribution</h3>

        <div className="risk-item">
          <div className="risk-header">
            <span className="risk-label high-risk">High Risk</span>
            <span className="risk-count">{stats.risk_distribution.high} patients</span>
          </div>
          <div className="risk-bar-container">
            <div
              className="risk-bar high-risk"
              style={{ width: `${highRiskPercent}%` }}
            >
              {highRiskPercent > 5 && <span>{highRiskPercent.toFixed(1)}%</span>}
            </div>
          </div>
        </div>

        <div className="risk-item">
          <div className="risk-header">
            <span className="risk-label medium-risk">Medium Risk</span>
            <span className="risk-count">{stats.risk_distribution.medium} patients</span>
          </div>
          <div className="risk-bar-container">
            <div
              className="risk-bar medium-risk"
              style={{ width: `${mediumRiskPercent}%` }}
            >
              {mediumRiskPercent > 5 && <span>{mediumRiskPercent.toFixed(1)}%</span>}
            </div>
          </div>
        </div>

        <div className="risk-item">
          <div className="risk-header">
            <span className="risk-label low-risk">Low Risk</span>
            <span className="risk-count">{stats.risk_distribution.low} patients</span>
          </div>
          <div className="risk-bar-container">
            <div
              className="risk-bar low-risk"
              style={{ width: `${lowRiskPercent}%` }}
            >
              {lowRiskPercent > 5 && <span>{lowRiskPercent.toFixed(1)}%</span>}
            </div>
          </div>
        </div>
      </div>

      <div className="stats-summary">
        <h3>📈 Summary</h3>
        <ul>
          <li>
            <strong>{((stats.risk_distribution.high / stats.total_predictions) * 100).toFixed(1)}%</strong> of
            patients fall into the high-risk category
          </li>
          <li>
            <strong>{((stats.risk_distribution.low / stats.total_predictions) * 100).toFixed(1)}%</strong> of
            patients fall into the low-risk category
          </li>
          <li>
            Average patient age: <strong>{stats.average_age.toFixed(1)} years</strong>
          </li>
          <li>
            Total assessments performed: <strong>{stats.total_predictions}</strong>
          </li>
        </ul>
      </div>

      <div className="stats-disclaimer">
        <p>⚠️ These statistics are generated from assessments made in this session and are for informational purposes only.</p>
      </div>
    </div>
  );
}

export default Statistics;
