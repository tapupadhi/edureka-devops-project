from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
from app.routers import products
import uvicorn

app = FastAPI(
    title="AppleBite Store",
    description="FastAPI application for AppleBite Co. with a web UI",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files
app.mount("/static", StaticFiles(directory="app/static"), name="static")

# Setup Jinja2 templates
templates = Jinja2Templates(directory="app/templates")

# Include routers
app.include_router(products.router)

@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    """Render the home page"""
    return templates.TemplateResponse("index.html", {"request": request, "title": "AppleBite Store"})

@app.get("/api")
async def api_root():
    """API welcome endpoint"""
    return {"message": "Welcome to AppleBite API"}

@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)