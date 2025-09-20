# Automated Testing Guide

This project is configured for fully automated testing with no manual intervention required. The following guide explains how to use the automated testing features.

## GitHub Actions CI/CD Pipeline

The project includes a comprehensive GitHub Actions workflow that automatically runs on every push and pull request:

- **Unit Tests**: Automatically runs all unit and integration tests
- **Security Scanning**: Checks for security vulnerabilities in code and dependencies
- **Docker Build**: Builds and tests the Docker image
- **Test Deployment**: Simulates deployment to a test environment
- **Production Deployment**: Can be triggered for the master branch

You can also manually trigger the workflow with the "workflow_dispatch" event.

## Local Automated Testing

### Option 1: Docker Compose (Recommended)

The easiest way to test the entire application stack:

```bash
# Run all tests
docker-compose up tests

# Run test environment
docker-compose up app-test

# Run production environment
docker-compose up app-prod
```

### Option 2: Python Environment

For more granular testing during development:

```bash
# Setup
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
pip install pytest pytest-cov

# Run basic tests
pytest app/test_main.py -v

# Run comprehensive tests
pytest app/test_comprehensive.py -v

# Run with coverage report
pytest app/test_comprehensive.py -v --cov=app --cov-report=html
```

### Option 3: Pre-commit Hooks

The project includes pre-commit hooks for automated checks before committing:

```bash
# Install pre-commit
pip install pre-commit

# Set up the git hooks
pre-commit install

# Run all pre-commit hooks manually
pre-commit run --all-files
```

## Security Scanning

### Trivy Scanning for Docker Images

```bash
# Install Trivy
# On Ubuntu
sudo apt-get install trivy

# On macOS
brew install trivy

# Scan the Docker image
trivy image fastapi-app

# Scan with custom policy
trivy image --config .trivyignore.yaml fastapi-app
```

### Code Security Scanning

```bash
# Install bandit
pip install bandit

# Scan the code
bandit -r app/
```

## Continuous Integration

The GitHub Actions workflow will automatically run all these tests on every push and pull request. You can see the results in the "Actions" tab of your GitHub repository.

## Automated Test Reports

- **Coverage Reports**: Available in HTML format after running with --cov-report=html
- **GitHub Actions**: Test results displayed in the workflow summary
- **Pre-commit**: Results shown in the terminal during commit

For any questions about the automated testing setup, please open an issue in the repository.