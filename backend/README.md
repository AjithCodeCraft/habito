# Habito Backend - FastAPI Application

## Overview
Production-ready FastAPI backend for the Habito Wellness Tracker application with JWT authentication, MySQL database, and comprehensive API endpoints for food tracking, sleep monitoring, habit management, and todo lists.

## Architecture
```
backend/
├── app/
│   ├── api/
│   │   └── v1/
│   │       ├── endpoints/     # API endpoint modules
│   │       │   ├── auth.py    # Authentication endpoints
│   │       │   ├── food.py    # Food tracking endpoints
│   │       │   ├── sleep.py   # Sleep tracking endpoints
│   │       │   ├── habits.py  # Habit management endpoints
│   │       │   └── todos.py   # Todo management endpoints
│   │       └── api.py         # API router aggregation
│   ├── core/
│   │   ├── config.py         # Application configuration
│   │   ├── security.py       # JWT and password utilities
│   │   └── dependencies.py   # FastAPI dependencies
│   ├── db/
│   │   └── base.py          # Database configuration
│   ├── models/               # SQLAlchemy models
│   │   ├── user.py
│   │   ├── food.py
│   │   ├── sleep.py
│   │   ├── habit.py
│   │   └── todo.py
│   ├── schemas/              # Pydantic schemas
│   │   ├── user.py
│   │   ├── food.py
│   │   ├── sleep.py
│   │   ├── habit.py
│   │   └── todo.py
│   └── main.py              # FastAPI application entry point
├── alembic/                  # Database migrations
├── tests/                    # Test files
├── .env                      # Environment variables
├── alembic.ini              # Alembic configuration
└── requirements.txt         # Python dependencies
```

## Prerequisites
- Python 3.10+
- MySQL 8.0+
- Virtual environment tool (venv)

## Setup Instructions

### 1. Database Setup
```bash
# Install MySQL if not already installed
# Create database
mysql -u root -p
CREATE DATABASE habito;
EXIT;
```

### 2. Environment Configuration
Update the `.env` file with your database credentials:
```env
DATABASE_URL=mysql+pymysql://root:your_password@localhost:3306/habito
DB_PASSWORD=your_password
SECRET_KEY=generate-a-secure-secret-key-here
```

To generate a secure secret key:
```python
import secrets
print(secrets.token_urlsafe(32))
```

### 3. Virtual Environment Setup
```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows (Git Bash/PowerShell)
source venv/Scripts/activate
# On Windows (Command Prompt)
venv\Scripts\activate
# On macOS/Linux
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 4. Database Migrations
```bash
# Initialize Alembic (first time only)
alembic init alembic

# Create initial migration
alembic revision --autogenerate -m "Initial migration"

# Apply migrations
alembic upgrade head
```

### 5. Running the Application
```bash
# Development mode with auto-reload
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Production mode
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

The API will be available at: `http://localhost:8000`

## API Documentation

### Interactive Documentation
- **Swagger UI**: http://localhost:8000/api/docs
- **ReDoc**: http://localhost:8000/api/redoc

### Authentication Flow
1. **Register**: POST `/api/v1/auth/register`
2. **Login**: POST `/api/v1/auth/login` (returns access & refresh tokens)
3. **Use Token**: Include in headers: `Authorization: Bearer <token>`
4. **Refresh**: POST `/api/v1/auth/refresh-token`

### API Endpoints

#### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login user
- `POST /api/v1/auth/logout` - Logout user
- `POST /api/v1/auth/refresh-token` - Refresh access token
- `POST /api/v1/auth/reset-password` - Request password reset
- `POST /api/v1/auth/reset-password/confirm` - Confirm password reset

#### Food Tracking
- `GET /api/v1/food/entries` - Get food entries
- `POST /api/v1/food/entries` - Create food entry
- `GET /api/v1/food/entries/{id}` - Get specific entry
- `PUT /api/v1/food/entries/{id}` - Update entry
- `DELETE /api/v1/food/entries/{id}` - Delete entry
- `GET /api/v1/food/daily-summary` - Get daily summary
- `GET /api/v1/food/search` - Search food database

#### Sleep Tracking
- `GET /api/v1/sleep/entries` - Get sleep entries
- `POST /api/v1/sleep/entries` - Create sleep entry
- `GET /api/v1/sleep/entries/{id}` - Get specific entry
- `PUT /api/v1/sleep/entries/{id}` - Update entry
- `DELETE /api/v1/sleep/entries/{id}` - Delete entry
- `GET /api/v1/sleep/weekly-summary` - Get weekly summary

#### Habits
- `GET /api/v1/habits` - Get habits
- `POST /api/v1/habits` - Create habit (max 3 active)
- `GET /api/v1/habits/{id}` - Get specific habit
- `PUT /api/v1/habits/{id}` - Update habit
- `DELETE /api/v1/habits/{id}` - Delete habit
- `POST /api/v1/habits/{id}/complete` - Mark as complete
- `DELETE /api/v1/habits/{id}/complete` - Remove completion

#### Todos
- `GET /api/v1/todos` - Get todos
- `POST /api/v1/todos` - Create todo (max 3 priority)
- `GET /api/v1/todos/{id}` - Get specific todo
- `PUT /api/v1/todos/{id}` - Update todo
- `DELETE /api/v1/todos/{id}` - Delete todo
- `POST /api/v1/todos/{id}/complete` - Mark as complete
- `POST /api/v1/todos/{id}/uncomplete` - Mark as incomplete

## Testing

### Run Tests
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app tests/

# Run specific test file
pytest tests/test_auth.py
```

### Test with cURL
```bash
# Register user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123456"}'

# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123456"}'

# Use authenticated endpoint
curl -X GET http://localhost:8000/api/v1/food/entries \
  -H "Authorization: Bearer <your-access-token>"
```

## Development Commands

### Database Commands
```bash
# Create new migration
alembic revision --autogenerate -m "Description"

# Apply migrations
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# View migration history
alembic history
```

### Code Quality
```bash
# Format code with black
black app/

# Sort imports
isort app/

# Type checking
mypy app/

# Linting
flake8 app/
```

## Security Features
- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: BCrypt with salt
- **CORS Protection**: Configurable allowed origins
- **Rate Limiting**: Configurable per-minute limits
- **Input Validation**: Pydantic schemas
- **SQL Injection Prevention**: SQLAlchemy ORM
- **Environment Variables**: Sensitive data in .env

## Performance Optimizations
- **Database Connection Pooling**: 10 connections, 20 overflow
- **Pagination**: Default 20 items, max 100
- **Indexed Database Fields**: Email, dates, foreign keys
- **Async Endpoints**: Non-blocking I/O operations
- **Redis Caching**: Optional caching layer

## Deployment

### Production Checklist
1. Set `DEBUG=False` in .env
2. Generate strong `SECRET_KEY`
3. Configure production database
4. Set up HTTPS/SSL
5. Configure firewall rules
6. Set up monitoring/logging
7. Configure backup strategy

### Docker Deployment
```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Environment Variables for Production
```env
ENVIRONMENT=production
DEBUG=False
SECRET_KEY=<strong-secret-key>
DATABASE_URL=mysql+pymysql://user:pass@host:3306/db
BACKEND_CORS_ORIGINS=["https://your-domain.com"]
```

## Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Check MySQL is running: `sudo service mysql status`
   - Verify credentials in .env
   - Check database exists: `mysql -u root -p -e "SHOW DATABASES;"`

2. **Import Errors**
   - Ensure virtual environment is activated
   - Reinstall dependencies: `pip install -r requirements.txt`

3. **Migration Errors**
   - Drop and recreate database if needed
   - Check model definitions match database schema

4. **JWT Token Errors**
   - Ensure SECRET_KEY is set
   - Check token expiration settings
   - Verify token format in Authorization header

## API Response Format
All API responses follow this structure:
```json
{
  "success": true,
  "data": {},
  "message": "Operation successful",
  "errors": []
}
```

## Contact & Support
For issues or questions, refer to the Product Requirements Document or create an issue in the repository.