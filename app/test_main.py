import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_api_root():
    response = client.get("/api")
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to AppleBite API"}

def test_get_all_products():
    response = client.get("/products/")
    assert response.status_code == 200
    assert len(response.json()) >= 1
    assert isinstance(response.json(), list)

def test_get_product_by_id():
    response = client.get("/products/1")
    assert response.status_code == 200
    assert response.json()["id"] == 1
    assert "name" in response.json()
    assert "price" in response.json()

def test_get_nonexistent_product():
    response = client.get("/products/999")
    assert response.status_code == 404
    assert "not found" in response.json()["detail"].lower()

def test_get_products_by_category():
    response = client.get("/products/category/Smartphones")
    assert response.status_code == 200
    assert len(response.json()) >= 1
    for product in response.json():
        assert product["category"] == "Smartphones"

def test_get_products_with_filters():
    response = client.get("/products/?max_price=1000")
    assert response.status_code == 200
    for product in response.json():
        assert product["price"] <= 1000

def test_search_products():
    response = client.get("/products/search/?q=iphone")
    assert response.status_code == 200
    assert len(response.json()) >= 1
    assert "iphone" in response.json()[0]["name"].lower() or "iphone" in response.json()[0].get("description", "").lower()