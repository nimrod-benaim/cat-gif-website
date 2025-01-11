-- Use the target database
CREATE DATABASE IF NOT EXISTS catnip_db;
USE catnip_db;

-- Create the images table
CREATE TABLE IF NOT EXISTS images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    url VARCHAR(255) NOT NULL
);

-- Insert initial data
INSERT INTO images (url) VALUES 
("https://th.bing.com/th/id/R.69bc0dd23ecbc52186c9f8226db663f6?rik=%2fkEH7eUmt7QsUQ&pid=ImgRaw&r=0"),
("https://th.bing.com/th/id/R.2ac93011db01822e89a9b98bfb94b119?rik=39LlswP7qM2GAQ&pid=ImgRaw&r=0"),
("https://media.tenor.com/nV-ot7JwmmoAAAAM/you-so-funny.gif"),
("https://www.gifcen.com/wp-content/uploads/2022/04/pop-cat-gif-9.gif"),
("https://media.tenor.com/97sD3prHJcoAAAAC/funny-memes.gif"),
("https://www.gifcen.com/wp-content/uploads/2021/06/meme-gif-9.gif");