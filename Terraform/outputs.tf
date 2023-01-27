output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

# Output Jenkins IP address to connect to 
output "jenkins_ip_address" {
  value = "${aws_instance.jenkins-instance.public_ip}"
}