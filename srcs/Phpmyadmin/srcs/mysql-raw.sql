FLUSH PRIVILEGES;
CREATE DATABASE teste_php;
GRANT ALL PRIVILEGES ON *.* TO '__WORDPRESS_USER_NAME__'@'%' IDENTIFIED BY '__WORDPRESS_PASSWORD__' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO '__WORDPRESS_USER_NAME__'@'localhost' IDENTIFIED BY '__WORDPRESS_PASSWORD__' WITH GRANT OPTION;
FLUSH PRIVILEGES;
