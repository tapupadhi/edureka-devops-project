output "jenkins_master_public_ip" {
  description = "Public IP address of the Jenkins master"
  value       = aws_instance.jenkins_master.public_ip
}

output "jenkins_slave_test_public_ip" {
  description = "Public IP address of the Jenkins test slave"
  value       = aws_instance.jenkins_slave_test.public_ip
}

output "jenkins_slave_prod_public_ip" {
  description = "Public IP address of the Jenkins production slave"
  value       = aws_instance.jenkins_slave_prod.public_ip
}

output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://${aws_instance.jenkins_master.public_ip}:8080"
}

output "test_app_url" {
  description = "URL to access the test environment application"
  value       = "http://${aws_instance.jenkins_slave_test.public_ip}:8000"
}

output "prod_app_url" {
  description = "URL to access the production environment application"
  value       = "http://${aws_instance.jenkins_slave_prod.public_ip}"
}