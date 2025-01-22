provider "aws" {
  region = "us-east-1" # Adjust to your desired AWS region
}

# Security group for allowing traffic to Flask and MySQL
resource "aws_security_group" "docker_sg" {
  name        = "docker_security_group"
  description = "Allow traffic for Docker containers"

  # Allow HTTP (Flask app)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }
   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ssh
  }

  # Egress rules (allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DockerSG"
  }
}

# EC2 instance for Docker
resource "aws_instance" "docker_host" {
  ami           = "ami-0df8c184d5f6ae949" # Amazon Linux 2 AMI (replace if needed)
  instance_type = "t2.micro"
  key_name      = "cicd_catgif_key"       # Replace with your AWS key pair name
  security_groups = [aws_security_group.docker_sg.name]

  # User data script to install Docker and Docker Compose
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras enable docker
              sudo yum install -y docker
              sudo yum install -y libxcrypt-compat
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              echo "Docker and Docker Compose installed."

              # Clone your project repository
              sudo yum install -y git
              git clone https://github.com/nimrod-benaim/cat-gif-website.git /home/ec2-user/cat-gif-website

              # Change directory and run Docker Compose
              cd /home/ec2-user/cat-gif-website
              docker-compose up -d --no-build
              EOF

  tags = {
    Name = "DockerHost"
  }
}

# Output the public IP of the instance
output "instance_public_ip" {
  value = aws_instance.docker_host.public_ip
}

# Local file to store the public IP
resource "local_file" "public_ip_file" {
  content  = aws_instance.docker_host.public_ip
  filename = "docker_host_public_ip.txt"
}
