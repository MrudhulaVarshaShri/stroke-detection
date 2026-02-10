#!/bin/bash
# Stroke Detection Application - Installation Script for Linux/Mac

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   Stroke Detection Application - Installation                  ║"
echo "║   For Linux/Mac                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check Python
echo -e "${YELLOW}1️⃣  Checking Python installation...${NC}"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}   ✅ $PYTHON_VERSION${NC}"
else
    echo -e "${RED}   ❌ Python 3 not found!${NC}"
    echo -e "${YELLOW}   Install: sudo apt install python3 python3-pip${NC}"
    exit 1
fi

# Check pip
echo -e "${YELLOW}2️⃣  Checking pip...${NC}"
if command -v pip3 &> /dev/null; then
    echo -e "${GREEN}   ✅ pip is installed${NC}"
else
    echo -e "${RED}   ❌ pip not found!${NC}"
    exit 1
fi

# Create virtual environment
echo -e "${YELLOW}3️⃣  Setting up Python virtual environment...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}   ✅ Virtual environment created${NC}"
else
    echo -e "${CYAN}   ℹ️  Virtual environment already exists${NC}"
fi

# Activate virtual environment
echo -e "${YELLOW}4️⃣  Activating virtual environment...${NC}"
source venv/bin/activate
echo -e "${GREEN}   ✅ Virtual environment activated${NC}"

# Install backend dependencies
echo -e "${YELLOW}5️⃣  Installing Python dependencies...${NC}"
pip install -r backend/requirements.txt > /dev/null
pip install gunicorn > /dev/null
echo -e "${GREEN}   ✅ Dependencies installed${NC}"

# Check Node.js
echo -e "${YELLOW}6️⃣  Checking Node.js installation...${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}   ✅ $NODE_VERSION${NC}"
    
    echo -e "${YELLOW}7️⃣  Installing Node.js dependencies...${NC}"
    cd frontend
    npm install > /dev/null
    cd ..
    echo -e "${GREEN}   ✅ Frontend dependencies installed${NC}"
else
    echo -e "${YELLOW}   ⚠️  Node.js not found (optional)${NC}"
    echo -e "${CYAN}   Install: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -${NC}"
    echo -e "${CYAN}           sudo apt install nodejs${NC}"
fi

# Verify structure
echo -e "${YELLOW}8️⃣  Verifying project structure...${NC}"
FILES=("backend/app.py" "backend/requirements.txt" "models/stroke_model.pkl" "frontend/package.json" "data/sample_data.csv")

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}   ✅ $file${NC}"
    else
        echo -e "${RED}   ❌ Missing: $file${NC}"
        exit 1
    fi
done

# Create .env file if doesn't exist
echo -e "${YELLOW}9️⃣  Checking environment configuration...${NC}"
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${GREEN}   ✅ Created .env from template${NC}"
else
    echo -e "${CYAN}   ℹ️  .env already exists${NC}"
fi

# Create logs directory
echo -e "${YELLOW}🔟 Setting up logging...${NC}"
mkdir -p backend/logs
echo -e "${GREEN}   ✅ Logs directory ready${NC}"

# Final summary
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                   ✅ Installation Complete!                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${CYAN}📋 Next Steps:${NC}"
echo ""
echo -e "${YELLOW}1️⃣  Activate virtual environment (each new terminal):${NC}"
echo -e "${GREEN}   source venv/bin/activate${NC}"
echo ""
echo -e "${YELLOW}2️⃣  Start Flask Backend:${NC}"
echo -e "${GREEN}   ./RUN_BACKEND.sh${NC}"
echo ""
echo -e "${YELLOW}3️⃣  Start React Frontend (in another terminal):${NC}"
echo -e "${GREEN}   ./RUN_FRONTEND.sh${NC}"
echo ""
echo -e "${YELLOW}4️⃣  Access the application:${NC}"
echo -e "${GREEN}   Frontend: http://localhost:3000${NC}"
echo -e "${GREEN}   Backend API: http://127.0.0.1:5000${NC}"
echo ""
echo -e "${YELLOW}5️⃣  Documentation:${NC}"
echo -e "${GREEN}   - SETUP_GUIDE.md${NC}"
echo -e "${GREEN}   - API_DOCUMENTATION.md${NC}"
echo -e "${GREEN}   - DEPLOYMENT.md${NC}"
echo ""

echo -e "${CYAN}📚 Try the API:${NC}"
echo -e "${GREEN}   curl http://127.0.0.1:5000/api/health${NC}"
echo ""
