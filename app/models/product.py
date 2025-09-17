from pydantic import BaseModel, Field
from typing import Optional

class Product(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    price: float = Field(..., gt=0)
    category: str
    image_url: Optional[str] = None
    stock: int = Field(..., ge=0)
    
    class Config:
        schema_extra = {
            "example": {
                "id": 1,
                "name": "iPhone 15 Pro",
                "description": "The latest iPhone with A17 Pro chip",
                "price": 999.99,
                "category": "Electronics",
                "image_url": "/static/images/iphone15.jpg",
                "stock": 100
            }
        }