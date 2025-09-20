import pytest
from fastapi.testclient import TestClient
import json
from app.main import app
from app.models.product import Product

client = TestClient(app)

# Basic Endpoint Tests
def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_api_root():
    response = client.get("/api")
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to AppleBite API"}

def test_homepage():
    response = client.get("/")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]

def test_products_page():
    response = client.get("/products")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]

# Product API Tests
def test_get_all_products():
    response = client.get("/api/products/")
    assert response.status_code == 200
    products = response.json()
    assert len(products) >= 1
    assert isinstance(products, list)
    
    # Validate product structure
    for product in products:
        assert "id" in product
        assert "name" in product
        assert "price" in product
        assert "category" in product
        assert isinstance(product["id"], int)
        assert isinstance(product["price"], (int, float))

def test_get_product_by_id():
    response = client.get("/api/products/1")
    assert response.status_code == 200
    product = response.json()
    assert product["id"] == 1
    assert "name" in product
    assert "price" in product
    assert "category" in product
    assert "description" in product
    assert "image" in product

def test_get_nonexistent_product():
    response = client.get("/api/products/999")
    assert response.status_code == 404
    assert "not found" in response.json()["detail"].lower()

def test_get_product_with_invalid_id():
    response = client.get("/api/products/invalid")
    assert response.status_code == 422  # Validation error

def test_get_products_by_category():
    response = client.get("/api/products/category/Smartphones")
    assert response.status_code == 200
    products = response.json()
    assert len(products) >= 1
    for product in products:
        assert product["category"] == "Smartphones"

def test_get_products_by_nonexistent_category():
    response = client.get("/api/products/category/NonexistentCategory")
    assert response.status_code == 200
    assert len(response.json()) == 0

def test_get_products_with_price_filter():
    response = client.get("/api/products/?max_price=1000")
    assert response.status_code == 200
    products = response.json()
    for product in products:
        assert product["price"] <= 1000
    
    response = client.get("/api/products/?min_price=500&max_price=1000")
    assert response.status_code == 200
    products = response.json()
    for product in products:
        assert 500 <= product["price"] <= 1000

def test_search_products():
    # Search by name
    response = client.get("/api/products/search/?q=iphone")
    assert response.status_code == 200
    products = response.json()
    assert len(products) >= 1
    for product in products:
        assert "iphone" in product["name"].lower() or "iphone" in product.get("description", "").lower()
    
    # Search with no results
    response = client.get("/api/products/search/?q=nonexistentproduct12345")
    assert response.status_code == 200
    assert len(response.json()) == 0

# Parameterized Tests
@pytest.mark.parametrize("category", ["Smartphones", "Tablets", "Laptops", "Accessories"])
def test_product_categories(category):
    response = client.get(f"/api/products/category/{category}")
    assert response.status_code == 200

@pytest.mark.parametrize("min_price,max_price", [(0, 500), (500, 1000), (1000, 2000)])
def test_price_range_filters(min_price, max_price):
    response = client.get(f"/api/products/?min_price={min_price}&max_price={max_price}")
    assert response.status_code == 200
    products = response.json()
    for product in products:
        assert min_price <= product["price"] <= max_price

# Integration Tests
def test_full_product_workflow():
    # Step 1: Get all products
    all_products_response = client.get("/api/products/")
    assert all_products_response.status_code == 200
    all_products = all_products_response.json()
    
    # Step 2: Filter by category
    category = all_products[0]["category"]
    category_response = client.get(f"/api/products/category/{category}")
    assert category_response.status_code == 200
    category_products = category_response.json()
    
    # Step 3: Get specific product details
    product_id = category_products[0]["id"]
    product_response = client.get(f"/api/products/{product_id}")
    assert product_response.status_code == 200
    product = product_response.json()
    
    # Step 4: Verify product data consistency
    assert product["id"] == product_id
    assert product["category"] == category

# Error handling tests
def test_error_handling():
    # Test 404 - resource not found
    response = client.get("/nonexistent-endpoint")
    assert response.status_code == 404
    
    # Test 422 - validation error
    response = client.get("/api/products/?min_price=invalid")
    assert response.status_code == 422