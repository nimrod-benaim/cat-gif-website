from flask import Flask, render_template, Response
import os
import random
import mysql.connector
from dotenv import load_dotenv
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)

# Prometheus Counter for tracking visitors
VISITOR_COUNT = Counter('visitor_count', 'Total number of visitors')

# Database configuration
db_config = {
    "host": os.environ.get("DATABASE_HOST", "localhost"),
    "user": os.environ.get("DATABASE_USER", "root"),
    "password": os.environ.get("DATABASE_PASSWORD", ""),
    "database": os.environ.get("DATABASE_NAME", "catgif_db"),
    "port": os.environ.get("DATABASE_PORT", 3306),
}

def get_db_connection():
    """Establish a database connection."""
    try:
        connection = mysql.connector.connect(**db_config)
        print("Database connection successful.")
        return connection
    except mysql.connector.Error as err:
        print(f"Error connecting to database: {err}")
        return None

def fetch_random_image():
    """Fetch a random image URL from the database."""
    connection = get_db_connection()
    if connection:
        cursor = connection.cursor()
        try:
            cursor.execute("SELECT url FROM images")
            images = cursor.fetchall()
            print(f"Fetched images from DB: {images}")  # Debug log
            if images:
                selected_image = random.choice(images)[0]
                print(f"Selected image URL: {selected_image}")  # Debug log
                return selected_image
            else:
                print("No images found in database.")
                return "https://via.placeholder.com/150"
        finally:
            cursor.close()
            connection.close()
    else:
        print("Database connection failed.")
        return "https://via.placeholder.com/150"

@app.route("/")
def index():
    """Main route for displaying a random image."""
    VISITOR_COUNT.inc()  # Increment visitor count
    image_url = fetch_random_image()
    print(f"URL sent to template: {image_url}")  # Debug log
    return render_template("index.html", url=image_url)

@app.route("/metrics")
def metrics():
    """Expose Prometheus metrics."""
    return Response(generate_latest(), mimetype='text/plain')
    #return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    port = os.environ.get("PORT", 5000)  # Default to 5000 if PORT is not set
    app.run(host="0.0.0.0", port=int(port), debug=True)
