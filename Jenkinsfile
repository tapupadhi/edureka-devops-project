pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'fastapi-app'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        TEST_SERVER = 'jenkins-slave-test'
        PROD_SERVER = 'jenkins-slave-prod'
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
                sshagent(['jenkins-ssh-key']) {
                    sh """
                        # Stop and remove existing container if it exists
                        ssh ubuntu@${TEST_SERVER} "sudo docker stop ${DOCKER_CONTAINER_TEST} || true"
                        ssh ubuntu@${TEST_SERVER} "sudo docker rm ${DOCKER_CONTAINER_TEST} || true"
                        
                        # Save and transfer the Docker image
                        docker save ${DOCKER_IMAGE}:${DOCKER_TAG} | ssh ubuntu@${TEST_SERVER} "sudo docker load"
                        
                        # Run new container
                        ssh ubuntu@${TEST_SERVER} "sudo docker run -d --name ${DOCKER_CONTAINER_TEST} -p 8000:8000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        
                        # Verify container is running
                        ssh ubuntu@${TEST_SERVER} "sudo docker ps | grep ${DOCKER_CONTAINER_TEST}"
                    """
                }
            }
            post {
                failure {
                    sshagent(['jenkins-ssh-key']) {
                        sh """
                            # Cleanup if deployment fails
                            ssh ubuntu@${TEST_SERVER} "sudo docker stop ${DOCKER_CONTAINER_TEST} || true"
                            ssh ubuntu@${TEST_SERVER} "sudo docker rm ${DOCKER_CONTAINER_TEST} || true"
                        """
                    }
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
                sshagent(['jenkins-ssh-key']) {
                    sh """
                        # Stop and remove existing container if it exists
                        ssh ubuntu@${PROD_SERVER} "sudo docker stop ${DOCKER_CONTAINER_PROD} || true"
                        ssh ubuntu@${PROD_SERVER} "sudo docker rm ${DOCKER_CONTAINER_PROD} || true"
                        
                        # Save and transfer the Docker image
                        docker save ${DOCKER_IMAGE}:${DOCKER_TAG} | ssh ubuntu@${PROD_SERVER} "sudo docker load"
                        
                        # Run new container
                        ssh ubuntu@${PROD_SERVER} "sudo docker run -d --name ${DOCKER_CONTAINER_PROD} -p 80:8000 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        
                        # Verify container is running
                        ssh ubuntu@${PROD_SERVER} "sudo docker ps | grep ${DOCKER_CONTAINER_PROD}"
                    """
                }
            }
            post {
                failure {
                    sshagent(['jenkins-ssh-key']) {
                        sh """
                            # Cleanup if deployment fails
                            ssh ubuntu@${PROD_SERVER} "sudo docker stop ${DOCKER_CONTAINER_PROD} || true"
                            ssh ubuntu@${PROD_SERVER} "sudo docker rm ${DOCKER_CONTAINER_PROD} || true"
                        """
                    }
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