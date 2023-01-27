#Gets the most recent Ubuntu image to use for the instances
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Creating Jenkins machine
resource "aws_instance" "jenkins-instance" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.medium"
  key_name        = "${var.keyname}"
  security_groups = [aws_security_group.sg_allow_ssh_jenkins.name]
  user_data = "${file("install_jenkins.sh")}"
  associate_public_ip_address = true
  tags = {
    Name = "Jenkins-Instance"
  }
}

# Creating Docker Manager
resource "aws_instance" "docker_manager" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name = "${var.keyname}"
  vpc_security_group_ids = [aws_security_group.sg_allow_ssh_jenkins.name]
  provisioner "file" {
    source      = "~/.ssh/GroupExercise.pem"
    destination = "~/.ssh/GroupExercise.pem"
  }
  # Runs a script to install Ansible and Docker, so that next an Ansible playbook can be run using the private IP inventory file created later
  user_data = "${file("install_ansible_and_docker.sh")}"
  tags = {
    Name = "Docker Manager"
    }
}

#Creating two Docker Swarm servers
resource "aws_instance" "docker_worker" {
  count = 2
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  key_name = "${var.keyname}"
  vpc_security_group_ids = [aws_security_group.sg_allow_ssh_jenkins.name]
  tags = {
    Name = "Docker Worker"
    }
}

# Generate Private IP inventory file
resource "local_file" "private_inventory" {
 filename = "./inventory/hosts.ini"
 content = <<EOF
[docker_manager]
${aws_instance.docker_manager.private_ip}
[docker_worker]
${aws_instance.docker_worker[0].private_ip}
${aws_instance.docker_worker[1].private_ip}
[jenkins-instance]
${aws_instance.jenkins-instance.private_ip}
EOF
}

# Generate public IPs when resources are destroyed and recreated
resource "local_file" "public_inventory" {
 filename = "./inventory/publicIPs.ini"
 content = <<EOF
[docker_manager]
${aws_instance.docker_manager.public_ip}
[docker_worker]
${aws_instance.docker_worker[0].public_ip}
${aws_instance.docker_worker[1].public_ip}
[jenkins-instance]
${aws_instance.jenkins-instance.public_ip}
EOF
}