# Production Deployment Guide

This guide covers deploying the Stroke Detection application to a production environment.

## Table of Contents
1. [Server Preparation](#server-preparation)
2. [Docker Deployment](#docker-deployment)
3. [Traditional Deployment (Linux)](#traditional-deployment-linux)
4. [NGINX Configuration](#nginx-configuration)
5. [SSL/TLS Setup](#ssltls-setup)
6. [Database Management](#database-management)
7. [Monitoring](#monitoring)
8. [Troubleshooting](#troubleshooting)

---

## Server Preparation

### System Requirements
- Ubuntu 20.04 LTS or newer (or equivalent Linux distribution)
- 2+ CPU cores
- 4GB+ RAM
- 20GB+ SSD storage
- Docker (optional, for containerized deployment)

### Install System Dependencies
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git build-essential python3-pip python3-venv
sudo apt install -y nginx certbot python3-certbot-nginx
```

---

## Docker Deployment

### Quick Start
```bash
# Clone repository
git clone <repository-url>
cd stroke-detection

# Build and run
docker-compose up -d

# Verify
curl http://localhost:5000/api/health
```

### Production Docker Setup
```bash
# Build images
docker-compose build

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f backend
docker-compose logs -f frontend

# Stop services
docker-compose down
```

### Docker Environment Variables
Create `.env.docker`:
```
FLASK_ENV=production
DEBUG=0
WORKERS=4
TIMEOUT=120
LOG_LEVEL=info
```

---

## Traditional Deployment (Linux)

### 1. Clone and Setup Repository
```bash
cd /opt
sudo git clone <repository-url> stroke-detection
cd stroke-detection
```

### 2. Set Up Backend
```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r backend/requirements.txt
pip install gunicorn

# Test
python backend/app.py
```

### 3. Set Up Frontend
```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Build frontend
cd frontend
npm install
npm run build
cd ..
```

### 4. Configure Systemd Service
Create `/etc/systemd/system/stroke-detection.service`:
```ini
[Unit]
Description=Stroke Detection API
After=network.target

[Service]
User=www-data
WorkingDirectory=/opt/stroke-detection
Environment="PATH=/opt/stroke-detection/venv/bin"
ExecStart=/opt/stroke-detection/venv/bin/gunicorn \
    --workers 4 \
    --worker-class sync \
    --bind 127.0.0.1:5000 \
    --timeout 120 \
    backend.app:app

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 5. Enable and Start Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable stroke-detection
sudo systemctl start stroke-detection
sudo systemctl status stroke-detection
```

---

## NGINX Configuration

### 1. Create Configuration
```bash
sudo cp nginx.conf /etc/nginx/sites-available/stroke-detection
sudo ln -s /etc/nginx/sites-available/stroke-detection /etc/nginx/sites-enabled/
```

### 2. Update Domain
Edit `/etc/nginx/sites-available/stroke-detection`:
- Replace `stroke-detection.example.com` with your domain

### 3. Test and Reload
```bash
sudo nginx -t
sudo systemctl reload nginx
```

### 4. Configure Logging (optional)
```bash
sudo mkdir -p /var/log/stroke-detection
sudo chown www-data:www-data /var/log/stroke-detection
```

---

## SSL/TLS Setup

### 1. Install Certbot
```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 2. Generate Certificate
```bash
sudo certbot certonly --nginx -d stroke-detection.example.com
```

### 3. Auto-Renewal
```bash
sudo certbot renew --dry-run
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

### 4. Verify Certificate
```bash
curl https://stroke-detection.example.com
```

---

## Database Management

### SQLite Maintenance
```bash
# Backup database
cp backend/stroke_predictions.db backend/stroke_predictions.db.backup

# Check database integrity
sqlite3 backend/stroke_predictions.db "PRAGMA integrity_check;"

# Optimize database
sqlite3 backend/stroke_predictions.db "VACUUM;"
```

### PostgreSQL (Optional for Large Scale)
```bash
# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Create database and user
sudo -u postgres createdb stroke_detection
sudo -u postgres createuser stroke_user
sudo -u postgres psql -c "ALTER USER stroke_user WITH PASSWORD 'strong_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE stroke_detection TO stroke_user;"
```

---

## Monitoring

### 1. Application Health Check
```bash
# Check every 5 minutes
*/5 * * * * curl -f http://localhost:5000/api/health || systemctl restart stroke-detection
```

### 2. Log Monitoring
```bash
# View backend logs
tail -f /var/log/stroke-detection/api.log

# View NGINX logs
tail -f /var/log/nginx/stroke-detection-access.log
tail -f /var/log/nginx/stroke-detection-error.log
```

### 3. System Monitoring with Prometheus
```bash
sudo apt install -y prometheus grafana-server

# Configure Prometheus to scrape metrics
# Add stroke-detection endpoints to prometheus.yml
```

### 4. Uptimerobot Monitoring
- Register at https://uptimerobot.com/
- Monitor `https://stroke-detection.example.com/api/health`
- Set up alerts

---

## Performance Tuning

### NGINX
```nginx
# Increase worker connections
worker_connections 2048;

# Enable caching
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=stroke_cache:10m;
```

### Gunicorn Workers
```bash
# Formula: (2 × CPU cores) + 1
# For 4-core server: 9 workers
gunicorn --workers 9 --worker-class sync backend.app:app
```

### Backend Optimization
- Use connection pooling for database
- Implement caching for predictions
- Enable gzip compression

---

## Backup and Recovery

### Daily Backup
```bash
#!/bin/bash
BACKUP_DIR="/backups/stroke-detection"
mkdir -p $BACKUP_DIR
DATE=$(date +%Y%m%d_%H%M%S)

# Backup database
cp backend/stroke_predictions.db "$BACKUP_DIR/db_$DATE.backup"

# Backup code (if needed)
# tar -czf "$BACKUP_DIR/code_$DATE.tar.gz" --exclude='.venv' --exclude='__pycache__' .

# Keep only last 30 days
find $BACKUP_DIR -name "*.backup" -mtime +30 -delete
```

Schedule with cron:
```bash
0 2 * * * /opt/stroke-detection/backup.sh
```

---

## Troubleshooting

### Backend Not Starting
```bash
# Check logs
journalctl -u stroke-detection -n 50

# Check port
sudo lsof -i :5000

# Test gunicorn
/opt/stroke-detection/venv/bin/gunicorn --bind 127.0.0.1:5000 backend.app:app
```

### NGINX Connection Issues
```bash
# Check NGINX logs
sudo tail -f /var/log/nginx/stroke-detection-error.log

# Test NGINX config
sudo nginx -t

# Reload NGINX
sudo systemctl reload nginx
```

### Database Locked
```bash
# Check if process is running
lsof | grep stroke_predictions.db

# Restart service
sudo systemctl restart stroke-detection
```

### High Memory Usage
```bash
# Check running processes
top -p $(pgrep -f gunicorn)

# Reduce workers
systemctl edit stroke-detection
# Change --workers to fewer
```

---

## Security Checklist

- [ ] SSL/TLS certificate installed
- [ ] HTTPS-only configured (redirect HTTP to HTTPS)
- [ ] Firewall rules configured (close unused ports)
- [ ] API rate limiting enabled
- [ ] Authentication/authorization implemented
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention
- [ ] CORS properly configured
- [ ] Security headers set (HSTS, CSP, etc.)
- [ ] Regular security updates applied
- [ ] Backups automated and tested
- [ ] Monitoring and alerting enabled

---

## Load Balancing (Multi-Server)

### HAProxy Configuration
```
global
    maxconn 4096

frontend frontend
    bind *:80
    bind *:443 ssl crt /path/to/cert.pem
    
    acl api_path path_beg /api/
    acl static_path path_beg /static/
    
    use_backend backend_api if api_path
    use_backend backend_static if static_path
    default_backend backend_frontend

backend backend_api
    balance roundrobin
    server server1 10.0.0.1:5000
    server server2 10.0.0.2:5000
    server server3 10.0.0.3:5000
    
backend backend_frontend
    balance roundrobin
    server server1 10.0.0.1:3000
    server server2 10.0.0.2:3000
    server server3 10.0.0.3:3000
```

---

## Deployment Checklist

- [ ] Server provisioned and configured
- [ ] Dependencies installed
- [ ] Application cloned and set up
- [ ] Virtual environment created
- [ ] Backend tested locally
- [ ] Frontend built
- [ ] Systemd service configured
- [ ] NGINX configured
- [ ] SSL certificate installed
- [ ] Database initialized
- [ ] Backups configured
- [ ] Monitoring set up
- [ ] Security hardened
- [ ] Performance tuned
- [ ] Documentation reviewed

---

**Last Updated:** February 10, 2026  
**Version:** 1.0.0
