pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'fastapi-app'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        // Using localhost instead of remote servers since infrastructure was destroyed
        LOCAL_TEST_PORT = '8000'
        LOCAL_PROD_PORT = '80'
        DOCKER_CONTAINER_TEST = 'fastapi-test'
        DOCKER_CONTAINER_PROD = 'fastapi-prod'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
            }
        }
        
        stage('Run Tests') {
            steps {
                sh "docker run --rm ${DOCKER_IMAGE}:${DOCKER_TAG} python -m pytest app/test_main.py -v"
            }
        }
        
        stage('Deploy to Test Environment') {
            steps {
                sh """
                    # Stop and remove existing container if it exists
                    docker stop ${DOCKER_CONTAINER_TEST} || true
                    docker rm ${DOCKER_CONTAINER_TEST} || true
                    
                    # Run new container locally
                    docker run -d --name ${DOCKER_CONTAINER_TEST} -p ${LOCAL_TEST_PORT}:8000 ${DOCKER_IMAGE}:${DOCKER_TAG}
                    
                    # Verify container is running
                    docker ps | grep ${DOCKER_CONTAINER_TEST}
                """
            }
            post {
                failure {
                    sh """
                        # Cleanup if deployment fails
                        docker stop ${DOCKER_CONTAINER_TEST} || true
                        docker rm ${DOCKER_CONTAINER_TEST} || true
                    """
                }
            }
        }
        
        stage('Approve Production Deployment') {
            steps {
                timeout(time: 24, unit: 'HOURS') {
                    input message: 'Deploy to production?', ok: 'Yes'
                }
            }
        }
        
        stage('Deploy to Production Environment') {
            steps {
                sh """
                    # Stop and remove existing container if it exists
                    docker stop ${DOCKER_CONTAINER_PROD} || true
                    docker rm ${DOCKER_CONTAINER_PROD} || true
                    
                    # Run new container locally
                    docker run -d --name ${DOCKER_CONTAINER_PROD} -p ${LOCAL_PROD_PORT}:8000 ${DOCKER_IMAGE}:${DOCKER_TAG}
                    
                    # Verify container is running
                    docker ps | grep ${DOCKER_CONTAINER_PROD}
                """
            }
            post {
                failure {
                    sh """
                        # Cleanup if deployment fails
                        docker stop ${DOCKER_CONTAINER_PROD} || true
                        docker rm ${DOCKER_CONTAINER_PROD} || true
                    """
                }
            }
        }
    }
    
    post {
        always {
            sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true"
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline execution failed!'
        }
    }
}