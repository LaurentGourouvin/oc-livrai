USE livrai;

CREATE TABLE IF NOT EXISTS user (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(64) NOT NULL,
  password VARCHAR(255) NOT NULL,
  admin BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS delivery (
  id INT NOT NULL AUTO_INCREMENT,
  userId INT NOT NULL,
  volume INT NOT NULL,
  weight INT NOT NULL,
  price DECIMAL(10,2),
  status VARCHAR(255),
  PRIMARY KEY (id),
  FOREIGN KEY (userId) REFERENCES user(id)
);

INSERT INTO user (email, name, password, admin) VALUES
    ('admin@livrai.com', 'Livrai', 'admin', TRUE);