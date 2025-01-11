from flask import Flask, render_template
import os
import random
import mysql.connector
from dotenv import load_dotenv  # Import dotenv

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)

# Database configuration
db_config = {
    "host": os.environ.get("DATABASE_HOST", "localhost"),
    "user": os.environ.get("DATABASE_USER", "root"),
    "password": os.environ.get("DATABASE_PASSWORD", ""),
    "database": os.environ.get("DATABASE_NAME", "catnip_db"),
    "port": int(os.environ.get("DATABASE_PORT", 3306)),  # Add port to db_config
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
    image_url = fetch_random_image()
    print(f"URL sent to template: {image_url}")  # Debug log
    return render_template("index.html", url=image_url)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))  # Default to 5000 if PORT is not set
    app.run(host="0.0.0.0", port=port, debug=True)