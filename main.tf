provider "aws" {
  region = "us-east-1" # Adjust to your desired AWS region
}


variable "database_host" {
  description = "The host of the database"
  type        = string
}

variable "database_port" {
  description = "The port of the database"
  type        = string
}

variable "database_user" {
  description = "The database username"
  type        = string
}

variable "database_password" {
  description = "The database password"
  type        = string
}

variable "database_name" {
  description = "The name of the database"
  type        = string
}

variable "mysql_root_password" {
  description = "The root password for MySQL"
  type        = string
}

variable "key_pair_name" {
  description = "The AWS key pair name"
  type        = string
}

variable "iam_user_name" {
  description = "The IAM user name"
  type        = string
}

variable "port" {
  description = "The port number the application will use."
  type        = number
  default     = 5000 # Default to Flask's standard port; modify if needed
}


# Check if the security group already exists
data "aws_security_group" "existing" {
  filter {
    name   = "group-name"
    values = ["docker_security_group"]
  }

  vpc_id = "vpc-02e271a136364ae89" # Replace with your VPC ID
}

# Security group for allowing traffic to Flask and MySQL
resource "aws_security_group" "docker_sg" {
  count = data.aws_security_group.existing.id != "" ? 0 : 1

  name        = "docker_security_group"
  description = "Allow traffic for Docker containers"

  # Allow HTTP (Flask app)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  key_name      = var.key_pair_name

  # Conditionally assign the correct security group
  security_groups = data.aws_security_group.existing.id != "" ? [data.aws_security_group.existing.name] : [aws_security_group.docker_sg[0].name]

  # User data script to install Docker and Docker Compose
  user_data = <<-EOF
    #!/bin/bash
    export DATABASE_HOST=${var.database_host}
    export DATABASE_PORT=${var.database_port}
    export DATABASE_USER=${var.database_user}
    export DATABASE_PASSWORD=${var.database_password}
    export DATABASE_NAME=${var.database_name}
    export MYSQL_ROOT_PASSWORD=${var.mysql_root_password}
    export PORT=${var.port}

    # Update and install required packages
    sudo yum update -y
    sudo amazon-linux-extras enable docker
    sudo yum install -y docker git
    sudo yum install -y libxcrypt-compat
    sudo service docker start
    sudo usermod -a -G docker ec2-user

      echo "Docker and Docker Compose installed."

    # Create the .env file with environment variables
    ls
    cd /home/ec2-user/cat-gif-website/
    touch .env
    echo "DATABASE_HOST=${var.database_host}" > /home/ec2-user/cat-gif-website/.env
    echo "DATABASE_PORT=${var.database_port}" >> /home/ec2-user/cat-gif-website/.env
    echo "DATABASE_USER=${var.database_user}" >> /home/ec2-user/cat-gif-website/.env
    echo "DATABASE_PASSWORD=${var.database_password}" >> /home/ec2-user/cat-gif-website/.env
    echo "DATABASE_NAME=${var.database_name}" >> /home/ec2-user/cat-gif-website/.env
    echo "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}" >> /home/ec2-user/cat-gif-website/.env
    echo "PORT=${var.port}" >> /home/ec2-user/cat-gif-website/.env

    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Clone the project repository
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
