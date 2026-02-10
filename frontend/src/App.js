import React, { useState, useEffect } from 'react';
import PredictionForm from './PredictionForm';
import PredictionHistory from './PredictionHistory';
import Statistics from './Statistics';
import './App.css';

function App() {
  const [currentPage, setCurrentPage] = useState('predict');
  const [predictions, setPredictions] = useState([]);
  const [stats, setStats] = useState(null);
  const [apiStatus, setApiStatus] = useState('checking');

  // Check API health on mount
  useEffect(() => {
    checkApi();
    const interval = setInterval(checkApi, 30000); // Check every 30s
    return () => clearInterval(interval);
  }, []);

  const checkApi = async () => {
    try {
      const response = await fetch(`${process.env.REACT_APP_API_URL || 'http://localhost:5000'}/api/health`);
      if (response.ok) {
        setApiStatus('healthy');
      } else {
        setApiStatus('unhealthy');
      }
    } catch (error) {
      setApiStatus('disconnected');
    }
  };

  const handlePredictionMade = (prediction) => {
    setPredictions([prediction, ...predictions]);
    fetchStats();
  };

  const fetchStats = async () => {
    try {
      const response = await fetch(`${process.env.REACT_APP_API_URL || 'http://localhost:5000'}/api/stats`);
      if (response.ok) {
        const data = await response.json();
        setStats(data);
      }
    } catch (error) {
      console.error('Error fetching stats:', error);
    }
  };

  useEffect(() => {
    if (currentPage === 'stats') {
      fetchStats();
    }
  }, [currentPage]);

  const getStatusColor = () => {
    switch (apiStatus) {
      case 'healthy': return '#4caf50';
      case 'unhealthy': return '#ff9800';
      case 'disconnected': return '#f44336';
      default: return '#2196f3';
    }
  };

  return (
    <div className="app">
      <header className="app-header">
        <div className="header-content">
          <div>
            <h1>🏥 Stroke Risk Detection</h1>
            <p>Using Machine Learning to Predict Stroke Risk</p>
          </div>
          <div className="api-status" style={{ borderColor: getStatusColor() }}>
            <span className="status-dot" style={{ backgroundColor: getStatusColor() }}></span>
            <span className="status-text">API: {apiStatus}</span>
          </div>
        </div>

        <nav className="app-nav">
          <button
            className={`nav-button ${currentPage === 'predict' ? 'active' : ''}`}
            onClick={() => setCurrentPage('predict')}
          >
            🔮 New Prediction
          </button>
          <button
            className={`nav-button ${currentPage === 'history' ? 'active' : ''}`}
            onClick={() => setCurrentPage('history')}
          >
            📋 History
          </button>
          <button
            className={`nav-button ${currentPage === 'stats' ? 'active' : ''}`}
            onClick={() => setCurrentPage('stats')}
          >
            📊 Statistics
          </button>
        </nav>
      </header>

      <main className="app-main">
        {currentPage === 'predict' && (
          <PredictionForm onPredictionMade={handlePredictionMade} />
        )}
        {currentPage === 'history' && (
          <PredictionHistory predictions={predictions} />
        )}
        {currentPage === 'stats' && (
          <Statistics stats={stats} />
        )}
      </main>

      <footer className="app-footer">
        <p>⚕️ Medical Application - For informational purposes only</p>
        <p>© 2026 Stroke Detection Application | v1.0.0</p>
      </footer>
    </div>
  );
}

export default App;
