# Nutrition & Wellness Tracker - Product Requirements Document

## 1. Product Overview

### 1.1 Product Vision
A comprehensive wellness tracking application that enables users to monitor their nutrition, sleep patterns, and daily habits in a simple, intuitive interface.

### 1.2 Product Goals
- Provide users with an easy-to-use platform for tracking food intake, sleep, and habits
- Enable data-driven insights into personal wellness patterns
- Maintain user data privacy and security through JWT authentication
- Deliver a seamless multi-platform experience (mobile and web)
- Ensure consistent functionality across all platforms with adaptive UI

### 1.3 Target Audience
- Health-conscious individuals seeking to monitor their daily wellness habits
- Users looking for a simple, consolidated tracking solution
- People wanting to establish and maintain healthy routines

## 2. Technical Architecture

### 2.1 Technology Stack
- **Backend**: FastAPI (Python)
- **Frontend Mobile**: Flutter (Cross-platform mobile app for iOS and Android)
- **Frontend Web**: Flutter Web (Progressive Web App)
- **Authentication**: JWT (JSON Web Tokens)
- **Database**: MySQL
- **API Documentation**: Automatic OpenAPI/Swagger documentation via FastAPI
- **Deployment**: Web app deployment on cloud platforms (Vercel, Netlify, or similar)

### 2.2 System Architecture
- **Single Module**: User module handling all functionality
- **RESTful API**: Backend services exposed via REST endpoints
- **Token-based Authentication**: Secure user sessions using JWT
- **Multi-platform Client**: 
  - Flutter mobile app for iOS and Android
  - Flutter web app for desktop/browser access
  - Responsive design adapting to different screen sizes

## 3. Core Features & Requirements

### 3.1 User Authentication
**Requirements:**
- User registration with email and password
- Secure login/logout functionality
- JWT token generation and validation
- Password reset capability
- Token refresh mechanism

**Technical Specifications:**
- JWT tokens with 24-hour expiration
- Refresh tokens with 30-day expiration
- Password hashing using bcrypt
- Email validation during registration

### 3.2 Tab 1: Food Tracking
**Core Features:**
- Log food items with portion sizes
- Search and select from food database
- View daily caloric intake
- Categorize meals (breakfast, lunch, dinner, snacks)
- Add custom food items
- Daily nutrition summary

**Data Fields:**
- Food name
- Quantity/portion size
- Calories per serving
- Meal category
- Timestamp
- Nutritional information (carbs, protein, fat)

**User Interface:**
- Quick add buttons for common foods
- Barcode scanner integration (future enhancement)
- Meal history and favorites
- Visual progress indicators

### 3.3 Tab 2: Sleep Tracking
**Core Features:**
- Log bedtime and wake time
- Calculate total sleep duration
- Track sleep quality rating (1-10 scale)
- Weekly sleep pattern visualization
- Set sleep goals and reminders

**Data Fields:**
- Bedtime timestamp
- Wake time timestamp
- Sleep duration (calculated)
- Sleep quality rating
- Date
- Sleep notes (optional)

**User Interface:**
- Simple time picker interface
- Sleep pattern charts
- Average sleep duration display
- Sleep goal progress tracking

### 3.4 Tab 3: Habit & Todo Management
**Core Features:**
- Create and manage up to 3 active habits
- Simple todo list with 3 priority items
- Mark habits as complete for the day
- Track habit streaks and completion rates
- Check off todo items

**Data Fields:**
**Habits:**
- Habit name
- Description
- Target frequency (daily)
- Current streak
- Completion status per day

**Todos:**
- Task description
- Priority level (1-3)
- Completion status
- Creation date
- Due date (optional)

**User Interface:**
- Habit completion checkboxes
- Streak counters
- Simple todo list with checkboxes
- Progress indicators

## 4. API Specifications

### 4.1 Authentication Endpoints
```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/refresh-token
POST /api/auth/reset-password
```

### 4.2 Food Tracking Endpoints
```
GET /api/food/entries
POST /api/food/entries
PUT /api/food/entries/{id}
DELETE /api/food/entries/{id}
GET /api/food/search
GET /api/food/daily-summary
```

### 4.3 Sleep Tracking Endpoints
```
GET /api/sleep/entries
POST /api/sleep/entries
PUT /api/sleep/entries/{id}
DELETE /api/sleep/entries/{id}
GET /api/sleep/weekly-summary
```

### 4.4 Habits & Todos Endpoints
```
GET /api/habits
POST /api/habits
PUT /api/habits/{id}
DELETE /api/habits/{id}
POST /api/habits/{id}/complete

GET /api/todos
POST /api/todos
PUT /api/todos/{id}
DELETE /api/todos/{id}
```

## 5. Data Models

### 5.1 User Model
```python
{
  "id": "uuid",
  "email": "string",
  "password_hash": "string",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### 5.2 Food Entry Model
```python
{
  "id": "uuid",
  "user_id": "uuid",
  "food_name": "string",
  "quantity": "float",
  "calories": "integer",
  "meal_category": "enum",
  "logged_at": "datetime",
  "nutritional_info": "json"
}
```

### 5.3 Sleep Entry Model
```python
{
  "id": "uuid",
  "user_id": "uuid",
  "bedtime": "datetime",
  "wake_time": "datetime",
  "duration_hours": "float",
  "quality_rating": "integer",
  "notes": "string",
  "date": "date"
}
```

### 5.4 Habit Model
```python
{
  "id": "uuid",
  "user_id": "uuid",
  "name": "string",
  "description": "string",
  "current_streak": "integer",
  "created_at": "datetime",
  "is_active": "boolean"
}
```

### 5.5 Todo Model
```python
{
  "id": "uuid",
  "user_id": "uuid",
  "description": "string",
  "priority": "integer",
  "is_completed": "boolean",
  "created_at": "datetime",
  "due_date": "datetime"
}
```

## 6. User Interface Requirements

### 6.1 Navigation Architecture

#### 6.1.1 Mobile Navigation
- **Bottom Tab Navigation** with 3 tabs:
  - Food Tracking (Fork/Plate icon)
  - Sleep Tracking (Moon/Bed icon)
  - Habits & Todos (Checkmark/Target icon)
- Tab icons and labels for easy identification
- Active tab highlighting with color accent
- Swipe gesture support between tabs

#### 6.1.2 Web Navigation  
- **Left Sidebar Navigation** with collapsible menu:
  - Dashboard/Overview section
  - Food Tracking section
  - Sleep Tracking section
  - Habits & Todos section
  - User profile/settings at bottom
- Sidebar can be collapsed to icon-only view
- Active section highlighting
- Responsive design: sidebar converts to hamburger menu on smaller screens

#### 6.1.3 Responsive Breakpoints
- **Mobile**: < 768px (Bottom tab navigation)
- **Tablet**: 768px - 1024px (Collapsible sidebar)
- **Desktop**: > 1024px (Full sidebar navigation)

### 6.2 Platform-Specific Design Adaptations

#### 6.2.1 Mobile-First Features
- Touch-optimized input controls
- Swipe gestures for navigation
- Pull-to-refresh functionality
- Native mobile date/time pickers
- Optimized for one-handed use

#### 6.2.2 Web-Specific Features
- Keyboard navigation support
- Hover states for interactive elements
- Context menus (right-click)
- Drag-and-drop functionality for reordering
- Multi-select capabilities
- Larger clickable areas for desktop precision

### 6.3 Design Principles
- **Consistent Core Experience**: Same functionality across all platforms
- **Platform-Appropriate UI**: Navigation and interactions optimized per platform
- **Progressive Enhancement**: Web app works offline with service workers
- **Accessibility**: Keyboard navigation, screen reader support, proper contrast ratios
- **Visual Hierarchy**: Clear information architecture with intuitive layouts

### 6.4 Key UI Components

#### 6.4.1 Shared Components
- Date/time pickers adapted to platform
- Progress bars and charts with touch/click interactions
- Form validation with real-time feedback
- Loading states and error messages
- Search functionality with autocomplete

#### 6.4.2 Mobile-Specific Components
- Bottom sheets for detailed views
- Floating action buttons for quick entry
- Card-based layouts for easy scrolling
- Native-style alerts and confirmations

#### 6.4.3 Web-Specific Components
- Modal dialogs for detailed forms
- Tooltips for additional information
- Breadcrumb navigation
- Data tables with sorting/filtering
- Keyboard shortcuts display

## 7. Security Requirements

### 7.1 Authentication & Authorization
- JWT token-based authentication
- Secure password storage with hashing
- Token expiration and refresh mechanism
- User data isolation (users can only access their own data)

### 7.2 Data Protection
- HTTPS encryption for all API communications
- Input validation and sanitization
- SQL injection prevention
- Rate limiting on API endpoints

## 8. Performance Requirements

### 8.1 Response Times
- API response time: < 200ms for simple queries
- Mobile app startup time: < 3 seconds
- Web app initial load time: < 5 seconds
- Data sync time: < 5 seconds across all platforms
- Offline-to-online sync: < 10 seconds

### 8.2 Scalability & Platform Performance
- Support for up to 1000 concurrent users initially
- Database optimization for user data queries
- Efficient data pagination for historical entries
- **Mobile-specific**: App size < 25MB, smooth 60fps animations
- **Web-specific**: Progressive loading, lazy loading for large datasets, service worker caching

## 9. Development Phases

### Phase 1 (MVP)
**Mobile & Web Core Features:**
- User authentication system (responsive login/register)
- Basic food logging functionality with platform-appropriate inputs
- Simple sleep tracking with native date/time pickers
- Core habit and todo features (3 habits, 3 todos limit)
- **Mobile**: Bottom tab navigation implementation
- **Web**: Sidebar navigation with responsive design
- Basic offline capability with local storage

### Phase 2 (Platform Optimization)
**Enhanced User Experience:**
- Advanced food database integration
- Sleep pattern analytics with interactive charts
- Habit streak visualizations
- Data export functionality (CSV/PDF)
- **Mobile**: Pull-to-refresh, swipe gestures, push notifications
- **Web**: Keyboard shortcuts, context menus, advanced filtering
- Progressive Web App (PWA) features for web version

### Phase 3 (Advanced Features)
**Future Enhancements:**
- **Mobile**: Barcode scanning for food items, camera integration
- **Web**: Bulk data import/export, advanced reporting dashboard
- Integration with fitness trackers and health APIs
- Nutritional goal setting with smart recommendations
- Social features and challenges
- Advanced analytics with machine learning insights
- Multi-language support

## 10. Success Metrics

### 10.1 Technical Metrics
- App crash rate: < 1%
- API uptime: > 99%
- Average response time: < 300ms

### 10.2 User Engagement Metrics
- Daily active users (mobile vs web breakdown)
- Feature adoption rates per platform
- Data entry consistency across platforms
- User retention rates (7-day, 30-day, 90-day)
- Platform preference and cross-platform usage patterns
- Session duration by platform type

## 11. Assumptions & Constraints

### 11.1 Assumptions
- Users have smartphones and/or computers with internet connectivity
- Users are willing to manually log their data across platforms
- Basic food database will be sufficient initially
- Flutter Web performance is acceptable for the target use cases
- Users may prefer different platforms for different use cases (mobile for quick logging, web for detailed analysis)

### 11.2 Constraints
- Single developer/small team development
- Limited initial budget for external services
- Multi-platform compatibility required (mobile + web)
- Simple, focused feature set to avoid complexity
- Flutter Web limitations compared to native web frameworks
- Need to maintain feature parity across platforms

## 12. Risk Assessment

### 12.1 Technical Risks
- JWT token security vulnerabilities
- Data synchronization issues between platforms
- Flutter Web performance limitations
- Offline-online data conflict resolution
- Cross-platform UI consistency challenges

### 12.2 Mitigation Strategies
- Regular security audits and token rotation
- Automated backup systems with conflict resolution
- Database indexing and optimization
- Comprehensive testing across all platforms and screen sizes
- Progressive enhancement approach for web features
- Platform-specific performance optimization