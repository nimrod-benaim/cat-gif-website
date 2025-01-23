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
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH
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
              mkdir -p /home/ec2-user/.ssh
              echo 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
 > /home/ec2-user/.ssh/id_rsa
              chmod 600 /home/ec2-user/.ssh/id_rsa
              git clone git@github.com:nimrod-benaim/cat-gif-website.git /home/ec2-user/cat-gif-website

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
