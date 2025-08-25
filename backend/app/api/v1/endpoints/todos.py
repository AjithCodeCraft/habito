from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import and_, func
from typing import List, Optional
from datetime import datetime
from app.db.base import get_db
from app.core.dependencies import get_current_user, PaginationParams
from app.models.user import User
from app.models.todo import Todo
from app.schemas.todo import TodoCreate, TodoUpdate, TodoResponse

router = APIRouter()


@router.get("/", response_model=List[TodoResponse])
async def get_todos(
    is_completed: Optional[bool] = None,
    priority: Optional[int] = None,
    pagination: PaginationParams = Depends(),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's todos with optional filters."""
    query = db.query(Todo).filter(Todo.user_id == current_user.id)
    
    if is_completed is not None:
        query = query.filter(Todo.is_completed == is_completed)
    
    if priority is not None:
        query = query.filter(Todo.priority == priority)
    
    todos = query.order_by(Todo.priority, Todo.created_at.desc())\
                 .offset(pagination.skip)\
                 .limit(pagination.limit)\
                 .all()
    
    return todos


@router.post("/", response_model=TodoResponse, status_code=status.HTTP_201_CREATED)
async def create_todo(
    todo_data: TodoCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new todo."""
    # Check if user has reached todo limit (3 priority todos)
    active_todos_count = db.query(func.count(Todo.id)).filter(
        and_(
            Todo.user_id == current_user.id,
            Todo.is_completed == False,
            Todo.priority <= 3
        )
    ).scalar()
    
    if active_todos_count >= 3:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Maximum of 3 active priority todos allowed"
        )
    
    new_todo = Todo(
        user_id=current_user.id,
        title=todo_data.title,
        description=todo_data.description,
        priority=todo_data.priority,
        due_date=todo_data.due_date
    )
    
    db.add(new_todo)
    db.commit()
    db.refresh(new_todo)
    
    return new_todo


@router.get("/{todo_id}", response_model=TodoResponse)
async def get_todo(
    todo_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get a specific todo."""
    todo = db.query(Todo).filter(
        and_(
            Todo.id == todo_id,
            Todo.user_id == current_user.id
        )
    ).first()
    
    if not todo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Todo not found"
        )
    
    return todo


@router.put("/{todo_id}", response_model=TodoResponse)
async def update_todo(
    todo_id: str,
    todo_data: TodoUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update a todo."""
    todo = db.query(Todo).filter(
        and_(
            Todo.id == todo_id,
            Todo.user_id == current_user.id
        )
    ).first()
    
    if not todo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Todo not found"
        )
    
    # If marking as completed, set completed_at
    if todo_data.is_completed is True and not todo.is_completed:
        todo.completed_at = datetime.utcnow()
    elif todo_data.is_completed is False and todo.is_completed:
        todo.completed_at = None
    
    # Update fields if provided
    update_data = todo_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if field != "is_completed":  # Already handled above
            setattr(todo, field, value)
    
    if "is_completed" in update_data:
        todo.is_completed = update_data["is_completed"]
    
    todo.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(todo)
    
    return todo


@router.delete("/{todo_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_todo(
    todo_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a todo."""
    todo = db.query(Todo).filter(
        and_(
            Todo.id == todo_id,
            Todo.user_id == current_user.id
        )
    ).first()
    
    if not todo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Todo not found"
        )
    
    db.delete(todo)
    db.commit()


@router.post("/{todo_id}/complete", response_model=TodoResponse)
async def complete_todo(
    todo_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark a todo as complete."""
    todo = db.query(Todo).filter(
        and_(
            Todo.id == todo_id,
            Todo.user_id == current_user.id
        )
    ).first()
    
    if not todo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Todo not found"
        )
    
    if todo.is_completed:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Todo already completed"
        )
    
    todo.is_completed = True
    todo.completed_at = datetime.utcnow()
    todo.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(todo)
    
    return todo


@router.post("/{todo_id}/uncomplete", response_model=TodoResponse)
async def uncomplete_todo(
    todo_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark a todo as incomplete."""
    todo = db.query(Todo).filter(
        and_(
            Todo.id == todo_id,
            Todo.user_id == current_user.id
        )
    ).first()
    
    if not todo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Todo not found"
        )
    
    if not todo.is_completed:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Todo is not completed"
        )
    
    todo.is_completed = False
    todo.completed_at = None
    todo.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(todo)
    
    return todo