# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Habito is a comprehensive wellness tracking application that enables users to monitor their nutrition, sleep patterns, and daily habits. The project uses a multi-platform architecture with FastAPI backend and Flutter for both mobile and web frontends.

## Technology Stack

- **Backend**: FastAPI (Python) with JWT authentication
- **Database**: MySQL
- **Frontend Mobile**: Flutter (iOS/Android)
- **Frontend Web**: Flutter Web (PWA)
- **API Documentation**: OpenAPI/Swagger via FastAPI

## Project Structure

The codebase should be organized as follows:
```
Habito/
├── backend/           # FastAPI backend
│   ├── api/          # API endpoints
│   ├── models/       # Database models
│   ├── auth/         # JWT authentication
│   └── services/     # Business logic
├── mobile/           # Flutter mobile app
├── web/              # Flutter web app
└── shared/           # Shared Flutter code between mobile/web
```

## Development Commands

### Backend (FastAPI)
```bash
# Setup virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run development server
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Run tests
pytest

# Database migrations
alembic upgrade head
```

### Flutter (Mobile & Web)
```bash
# Install dependencies
flutter pub get

# Run mobile app
flutter run

# Run web app
flutter run -d chrome

# Build mobile app
flutter build apk  # Android
flutter build ios  # iOS

# Build web app
flutter build web

# Run tests
flutter test
```

## Core Features Implementation

### 1. Authentication System
- Implement JWT authentication with 24-hour token expiration
- Use bcrypt for password hashing
- Include refresh token mechanism (30-day expiration)
- All endpoints except auth require valid JWT token

### 2. API Endpoints Structure
Each feature module should implement standard CRUD operations:
- GET /api/{module}/entries - List entries
- POST /api/{module}/entries - Create entry
- PUT /api/{module}/entries/{id} - Update entry
- DELETE /api/{module}/entries/{id} - Delete entry

### 3. Database Models
Use SQLAlchemy ORM with the following core models:
- User (id, email, password_hash, created_at, updated_at)
- FoodEntry (id, user_id, food_name, quantity, calories, meal_category, logged_at, nutritional_info)
- SleepEntry (id, user_id, bedtime, wake_time, duration_hours, quality_rating, notes, date)
- Habit (id, user_id, name, description, current_streak, created_at, is_active)
- Todo (id, user_id, description, priority, is_completed, created_at, due_date)

### 4. Flutter UI Architecture
- **Mobile**: Use bottom tab navigation with 3 tabs (Food, Sleep, Habits)
- **Web**: Use left sidebar navigation (collapsible)
- Implement responsive design with breakpoints:
  - Mobile: < 768px
  - Tablet: 768px - 1024px
  - Desktop: > 1024px

## Development Phases

### Phase 1 (MVP) - Start Here
1. Set up FastAPI backend with basic project structure
2. Implement JWT authentication system
3. Create database models and MySQL connection
4. Build basic CRUD APIs for all modules
5. Create Flutter project with navigation structure
6. Implement responsive UI layouts
7. Connect Flutter to backend APIs

### Phase 2 - Platform Optimization
- Add data visualization charts
- Implement offline capability
- Add PWA features for web
- Optimize performance for each platform

## API Response Format
Standardize all API responses:
```json
{
  "success": true,
  "data": {},
  "message": "Operation successful",
  "errors": []
}
```

## Security Considerations
- Always validate and sanitize inputs
- Use parameterized queries to prevent SQL injection
- Implement rate limiting on all endpoints
- Store sensitive configuration in environment variables
- Enable CORS only for trusted origins

## Testing Requirements
- Write unit tests for all API endpoints
- Include integration tests for authentication flow
- Test Flutter widgets and state management
- Ensure cross-platform compatibility testing

## Performance Goals
- API response time < 200ms
- Mobile app startup < 3 seconds
- Web app initial load < 5 seconds
- Support 1000 concurrent users