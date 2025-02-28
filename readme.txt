name: CI/CD Pipeline

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    env:
      MYSQL_ROOT_PASSWORD: yourpassword
      MYSQL_DATABASE: catgif_db
      DATABASE_USER: catgif_user
      DATABASE_PASSWORD: catgif_password


    steps:
    # Checkout the code
    - name: Checkout Code
      uses: actions/checkout@v3

    # Set up Docker
    - name: Set up Docker
      uses: docker/setup-buildx-action@v2

    # Install Docker Compose
    - name: Install Docker Compose
      run: |
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        docker-compose --version

    # Build the Docker image
    - name: Build Docker Image
      run: docker-compose build
      env:
        DOCKER_BUILDKIT: 1

    # Run the containers
    - name: Start Containers
      run: docker-compose up -d

    # Wait for services to be ready
    - name: Wait for Database
      run: |
        echo "Waiting for database to start..."
        for i in {1..30}; do
          nc -z mysql 3306 && echo "Database is ready!" && exit 0
          echo "Waiting..."
          sleep 5
        done
        exit 1

    # Run tests (replace with your actual test commands)
    - name: Run Tests
      run: |
        echo "Running tests..."
        curl -f http://localhost:5000 || exit 1
        echo "Tests passed!"

    # Deploy (example: push to Docker Hub)
    - name: Push Docker Image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: nimrod1/cat_gif_site_new:ver-2.0 # הנה #

    # Cleanup
    - name: Cleanup
      run: docker-compose down
