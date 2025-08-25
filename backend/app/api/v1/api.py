from fastapi import APIRouter
from app.api.v1.endpoints import auth, food, sleep, habits, todos

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(food.router, prefix="/food", tags=["Food Tracking"])
api_router.include_router(sleep.router, prefix="/sleep", tags=["Sleep Tracking"])
api_router.include_router(habits.router, prefix="/habits", tags=["Habits"])
api_router.include_router(todos.router, prefix="/todos", tags=["Todos"])