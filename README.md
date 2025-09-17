# AppleBite Co. CI/CD Pipeline Project

This project implements a complete CI/CD pipeline for a FastAPI application using Git, Jenkins, Docker, and Ansible. The pipeline automatically deploys code to test and production environments when code is pushed to the master branch.

## Project Components

- **Infrastructure**: AWS EC2 instances provisioned with Terraform
- **CI/CD**: Jenkins for continuous integration and deployment
- **Containerization**: Docker for application packaging
- **Configuration Management**: Ansible for server configuration
- **Application**: FastAPI-based web application with UI

## Application Features

- Modern responsive web interface
- Product catalog with filtering and search
- REST API endpoints
- Comprehensive test suite
- Shopping cart functionality (client-side)

## Project Structure

```
.
├── Dockerfile              # Docker configuration for FastAPI app
├── Jenkinsfile             # Jenkins pipeline definition
├── README.md               # Project documentation
├── requirements.txt        # Python dependencies
├── ansible/                # Ansible configuration
│   ├── install_docker.yml  # Playbook for Docker installation
│   └── inventory           # Inventory file for Ansible
├── app/                    # FastAPI application
│   ├── __init__.py
│   ├── main.py             # Main application entry point
│   ├── test_main.py        # Application tests
│   ├── models/             # Data models
│   │   └── product.py      # Product model definition
│   ├── routers/            # API route definitions
│   │   ├── __init__.py
│   │   └── products.py     # Product endpoints
│   ├── static/             # Static assets
│   │   ├── css/            # Stylesheets
│   │   │   └── styles.css  # Main CSS
│   │   └── js/             # JavaScript files
│   │       ├── main.js     # Main JS
│   │       └── products.js # Products page JS
│   └── templates/          # Jinja2 templates
│       ├── index.html      # Home page
│       └── products.html   # Products listing page
└── terraform/              # Infrastructure as Code
    ├── main.tf             # Main Terraform configuration
    ├── outputs.tf          # Terraform outputs
    ├── variables.tf        # Terraform variables
    └── scripts/            # Server setup scripts
        ├── setup-master.sh # Jenkins master setup
        └── setup-slave.sh  # Jenkins slave setup
```

## Setup Instructions

### Local Development

1. **Clone the repository**:
   ```bash
   git clone https://github.com/tapupadhi/edureka-devops-project.git
   cd edureka-devops-project
   ```

2. **Create a virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**:
   ```bash
   uvicorn app.main:app --reload
   ```

5. **Access the application**:
   - Web UI: http://localhost:8000
   - API documentation: http://localhost:8000/docs

### Docker Development

1. **Build the Docker image**:
   ```bash
   docker build -t fastapi-app .
   ```

2. **Run the container**:
   ```bash
   docker run -p 8000:8000 fastapi-app
   ```

3. **Access the application**:
   - Web UI: http://localhost:8000
   - API documentation: http://localhost:8000/docs

## Infrastructure Setup

### AWS Setup with Terraform

1. **Configure AWS Credentials**:
   ```bash
   aws configure
   ```

2. **Update Terraform Variables**:
   Edit `terraform/variables.tf` to set your SSH key name and other preferences.

3. **Initialize and Apply Terraform**:
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

### Jenkins Setup

1. **Access Jenkins**:
   After infrastructure is provisioned, access Jenkins at:
   ```
   http://<jenkins_master_public_ip>:8080
   ```

2. **Configure Jenkins**:
   - Follow the initial setup wizard
   - Install suggested plugins
   - Create admin user
   - Configure Jenkins credentials for SSH to slave nodes
   - Add GitHub webhook for automated builds

3. **Create Jenkins Pipeline**:
   - Create a new Pipeline job in Jenkins
   - Configure it to use the Jenkinsfile from your Git repository
   - Set up GitHub webhook for automatic triggers

### Ansible Deployment

1. **Update Inventory**:
   Edit `ansible/inventory` to include your server IPs.

2. **Run Ansible Playbook**:
   ```bash
   cd ansible
   ansible-playbook -i inventory install_docker.yml
   ```

## CI/CD Pipeline Flow

1. **Code Commit**: Developer pushes code to GitHub
2. **Build**: Jenkins pulls the code and builds a Docker image
3. **Test**: Automated tests are run against the Docker image
4. **Deploy to Test**: Application is deployed to test environment
5. **Approval**: Manual approval for production deployment
6. **Deploy to Production**: Application is deployed to production environment

## Application API Endpoints

### Web UI Endpoints
- `GET /`: Home page with product listing UI
- `GET /products`: Detailed products page with filtering

### REST API Endpoints
- `GET /api/products/`: List all products (JSON API)
- `GET /api/products/{id}`: Get a specific product by ID (JSON API)
- `GET /api/products/category/{category}`: Get products by category (JSON API)
- `GET /health`: Health check endpoint

## GitHub Repository Setup

1. **Create a new repository on GitHub**

2. **Initialize Git in your local project**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

3. **Add the remote repository**:
   ```bash
   git remote add origin https://github.com/your-username/applebite-cicd.git
   ```

4. **Push your code**:
   ```bash
   git push -u origin master
   ```

## License

This project is proprietary and confidential.

## Authors

- AppleBite Co. DevOps Team
