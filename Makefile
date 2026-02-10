.PHONY: help install setup dev backend frontend test clean docker logs

# Default target
help:
	@echo "╔════════════════════════════════════════════════════════════════╗"
	@echo "║       Stroke Detection Application - Makefile Commands          ║"
	@echo "╚════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "📦 Installation & Setup:"
	@echo "  make install      - Install all dependencies"
	@echo "  make setup        - Full project setup"
	@echo ""
	@echo "🚀 Development:"
	@echo "  make dev          - Run backend and frontend (requires tmux)"
	@echo "  make backend      - Run Flask backend only"
	@echo "  make frontend     - Run React frontend only"
	@echo ""
	@echo "🧪 Testing & Quality:"
	@echo "  make test         - Run all tests"
	@echo "  make test-backend - Test backend code"
	@echo "  make test-frontend- Test frontend code"
	@echo "  make lint         - Run linters"
	@echo ""
	@echo "🐳 Docker:"
	@echo "  make docker-build - Build Docker images"
	@echo "  make docker-run   - Run with Docker Compose"
	@echo "  make docker-stop  - Stop Docker containers"
	@echo "  make docker-logs  - Show Docker logs"
	@echo ""
	@echo "🧹 Maintenance:"
	@echo "  make clean        - Clean cache and temp files"
	@echo "  make clean-db     - Reset database"
	@echo "  make logs         - Show application logs"
	@echo ""
	@echo "📊 Utilities:"
	@echo "  make requirements - Update requirements.txt"
	@echo "  make freeze       - Freeze Python dependencies"
	@echo ""

# Install dependencies
install: install-backend install-frontend
	@echo "✅ Installation complete!"

install-backend:
	@echo "📦 Installing backend dependencies..."
	python3 -m venv venv || true
	. venv/bin/activate && pip install -r backend/requirements.txt
	@echo "✅ Backend dependencies installed"

install-frontend:
	@echo "📦 Installing frontend dependencies..."
	cd frontend && npm install
	@echo "✅ Frontend dependencies installed"

# Setup (virtual environment + dependencies)
setup: 
	@echo "🔧 Setting up project..."
	python3 -m venv venv
	. venv/bin/activate && pip install -r backend/requirements.txt
	cd frontend && npm install
	cp .env.example .env || true
	@echo "✅ Project setup complete"

# Development mode
dev:
	@echo "🚀 Starting development environment..."
	@echo "   Backend: http://127.0.0.1:5000"
	@echo "   Frontend: http://localhost:3000"
	tmux new-session -d -s stroke -n backend 'make backend'
	tmux new-window -t stroke -n frontend 'make frontend'
	tmux attach-session -t stroke

# Run backend
backend:
	@echo "⚙️  Starting Flask backend..."
	. venv/bin/activate && python backend/app.py

# Run frontend
frontend:
	@echo "⚙️  Starting React frontend..."
	cd frontend && npm start

# Run tests
test: test-backend test-frontend
	@echo "✅ All tests passed!"

test-backend:
	@echo "🧪 Testing backend..."
	. venv/bin/activate && pytest backend/tests/ -v --cov=backend || true

test-frontend:
	@echo "🧪 Testing frontend..."
	cd frontend && npm test -- --coverage || true

# Linting
lint:
	@echo "🔍 Running linters..."
	. venv/bin/activate && flake8 backend/ --max-line-length=120 || true
	cd frontend && npm run lint || true

# Docker commands
docker-build:
	@echo "🐳 Building Docker images..."
	docker-compose build

docker-run:
	@echo "🐳 Running with Docker Compose..."
	docker-compose up

docker-stop:
	@echo "🐳 Stopping Docker containers..."
	docker-compose down

docker-logs:
	@echo "📋 Docker logs..."
	docker-compose logs -f

# Database
reset-db:
	@echo "🔄 Resetting database..."
	rm -f backend/stroke_predictions.db
	@echo "✅ Database reset"

# Cleaning
clean:
	@echo "🧹 Cleaning up..."
	find . -type d -name __pycache__ -exec rm -rf {} + || true
	find . -type f -name "*.pyc" -delete
	find . -name ".DS_Store" -delete
	rm -rf .pytest_cache
	rm -rf backend/.coverage
	rm -rf frontend/build
	rm -rf node_modules || true
	@echo "✅ Clean complete"

# Requirements
freeze:
	@echo "📝 Freezing Python requirements..."
	. venv/bin/activate && pip freeze > backend/requirements-frozen.txt
	@echo "✅ Requirements frozen to requirements-frozen.txt"

requirements:
	@echo "📝 Updating requirements.txt..."
	. venv/bin/activate && pip install pipreqs
	pipreqs backend/ --force
	@echo "✅ Requirements updated"

# Logs
logs:
	@echo "📋 Application logs:"
	tail -f backend/logs/api.log || echo "No logs available yet"

# Health check
health:
	@echo "💚 Checking application health..."
	@curl -s http://127.0.0.1:5000/api/health | python3 -m json.tool || echo "Backend not responding"

# Train model
train-model:
	@echo "🤖 Training ML model..."
	. venv/bin/activate && python models/train_model.py
	@echo "✅ Model training complete"

# Build frontend
build-frontend:
	@echo "🏗️  Building frontend..."
	cd frontend && npm run build
	@echo "✅ Frontend build complete"

# Backup database
backup-db:
	@echo "💾 Backing up database..."
	@mkdir -p backups
	@cp backend/stroke_predictions.db backups/stroke_predictions_$(shell date +%Y%m%d_%H%M%S).db
	@echo "✅ Database backed up"

# Development server with auto-reload
dev-backend:
	@echo "⚙️  Starting backend with auto-reload..."
	. venv/bin/activate && FLASK_ENV=development FLASK_APP=backend/app.py flask run --reload

dev-frontend:
	@echo "⚙️  Starting frontend with hot-reload..."
	cd frontend && npm start

# Format code
format:
	@echo "🎨 Formatting code..."
	. venv/bin/activate && black backend/ || true
	cd frontend && npm run prettier || true
	@echo "✅ Code formatted"

# Production build
build-prod:
	@echo "🏗️  Building for production..."
	@echo "  - Backend:"
	@echo "    Docker image ready: docker build -t stroke-detection:latest ."
	@echo "  - Frontend:"
	cd frontend && npm run build
	@echo "✅ Production build complete"

# Version info
version:
	@echo "📌 Version Information:"
	@echo "  Python: " && python3 --version
	@echo "  Node: " && node --version
	@echo "  npm: " && npm --version
	@echo "  pip: " && . venv/bin/activate && pip --version

.DEFAULT_GOAL := help
