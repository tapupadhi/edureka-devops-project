from fastapi import APIRouter, HTTPException, Query, Path
from typing import List, Dict, Optional
from app.models.product import Product

router = APIRouter(prefix="/products", tags=["products"])

# Sample product data
products = [
    {
        "id": 1,
        "name": "iPhone 15 Pro",
        "description": "The latest iPhone with A17 Pro chip",
        "price": 999.99,
        "category": "Smartphones",
        "image_url": "/static/images/iphone15.jpg",
        "stock": 100
    },
    {
        "id": 2,
        "name": "MacBook Pro 16",
        "description": "Powerful laptop with M2 Pro chip",
        "price": 2499.99,
        "category": "Laptops",
        "image_url": "/static/images/macbook.jpg",
        "stock": 50
    },
    {
        "id": 3,
        "name": "iPad Pro",
        "description": "Professional tablet with M2 chip",
        "price": 799.99,
        "category": "Tablets",
        "image_url": "/static/images/ipad.jpg",
        "stock": 75
    },
    {
        "id": 4,
        "name": "Apple Watch Series 9",
        "description": "Advanced health and fitness companion",
        "price": 399.99,
        "category": "Wearables",
        "image_url": "/static/images/watch.jpg",
        "stock": 120
    },
    {
        "id": 5,
        "name": "AirPods Pro 2",
        "description": "Wireless earbuds with active noise cancellation",
        "price": 249.99,
        "category": "Audio",
        "image_url": "/static/images/airpods.jpg",
        "stock": 200
    }
]

@router.get("/", response_model=List[Dict])
async def get_all_products(category: Optional[str] = None, max_price: Optional[float] = None):
    """Get all products with optional filtering"""
    filtered_products = products
    
    if category:
        filtered_products = [p for p in filtered_products if p["category"].lower() == category.lower()]
    
    if max_price:
        filtered_products = [p for p in filtered_products if p["price"] <= max_price]
        
    return filtered_products

@router.get("/{product_id}", response_model=Dict)
async def get_product(product_id: int = Path(..., gt=0)):
    """Get a specific product by ID"""
    for product in products:
        if product["id"] == product_id:
            return product
    raise HTTPException(status_code=404, detail=f"Product with ID {product_id} not found")

@router.get("/category/{category}", response_model=List[Dict])
async def get_products_by_category(category: str):
    """Get products by category"""
    filtered_products = [product for product in products if product["category"].lower() == category.lower()]
    if not filtered_products:
        raise HTTPException(status_code=404, detail=f"No products found in category: {category}")
    return filtered_products

@router.get("/search/", response_model=List[Dict])
async def search_products(q: str = Query(..., min_length=2)):
    """Search for products by name or description"""
    q = q.lower()
    matching_products = [
        product for product in products 
        if q in product["name"].lower() or 
        (product.get("description") and q in product["description"].lower())
    ]
    return matching_products