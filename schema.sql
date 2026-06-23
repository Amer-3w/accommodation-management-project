CREATE DATABASE IF NOT EXISTS EduStay CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE EduStay;

CREATE TABLE users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(30) NULL UNIQUE,
  whatsapp VARCHAR(30) NULL,
  date_of_birth DATE NULL,
  gender VARCHAR(50) NULL,
  university VARCHAR(255) NULL,
  governorate VARCHAR(255) NULL,
  city VARCHAR(255) NULL,
  address VARCHAR(255) NULL,
  bio TEXT NULL,
  profile_photo_path VARCHAR(255) NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin','owner','user') NOT NULL DEFAULT 'user',
  remember_token VARCHAR(100) NULL,
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  INDEX users_role_index (role)
);

CREATE TABLE user_whatsapp_numbers (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  country_code VARCHAR(8) NOT NULL,
  number VARCHAR(24) NOT NULL,
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  UNIQUE KEY user_whatsapp_numbers_unique (user_id, country_code, number),
  CONSTRAINT user_whatsapp_numbers_user_id_foreign FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE properties (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  owner_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  price_duration ENUM('day','week','month') NOT NULL DEFAULT 'month',
  stay_duration SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  weekly_discount DECIMAL(5,2) NOT NULL DEFAULT 10,
  monthly_discount DECIMAL(5,2) NOT NULL DEFAULT 20,
  long_stay_discount DECIMAL(5,2) NOT NULL DEFAULT 25,
  location VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  rooms TINYINT UNSIGNED NOT NULL DEFAULT 1,
  bathrooms TINYINT UNSIGNED NOT NULL DEFAULT 1,
  beds TINYINT UNSIGNED NOT NULL DEFAULT 1,
  property_type VARCHAR(60) NULL,
  governorate VARCHAR(255) NULL,
  city VARCHAR(255) NULL,
  university VARCHAR(255) NULL,
  address VARCHAR(255) NULL,
  latitude DECIMAL(10,7) NULL,
  longitude DECIMAL(10,7) NULL,
  amenities JSON NULL,
  rules JSON NULL,
  availability JSON NULL,
  contact_email VARCHAR(255) NULL,
  contact_whatsapp_country_code VARCHAR(8) NULL,
  contact_whatsapp_number VARCHAR(24) NULL,
  contact_type ENUM('email','whatsapp','both') NOT NULL DEFAULT 'email',
  status ENUM('draft','active','archived') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  INDEX properties_location_index (location),
  INDEX properties_price_rooms_index (price, rooms),
  CONSTRAINT properties_owner_id_foreign FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE property_images (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  path VARCHAR(255) NOT NULL,
  sort_order SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  CONSTRAINT property_images_property_id_foreign FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
);

CREATE TABLE bookings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NOT NULL,
  date_from DATE NOT NULL,
  date_to DATE NOT NULL,
  guests TINYINT UNSIGNED NOT NULL DEFAULT 1,
  notes TEXT NULL,
  base_price DECIMAL(10,2) NOT NULL DEFAULT 0,
  price_period VARCHAR(16) NOT NULL DEFAULT 'month',
  number_of_days INT UNSIGNED NOT NULL DEFAULT 1,
  base_total DECIMAL(10,2) NOT NULL DEFAULT 0,
  discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
  discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  service_fee DECIMAL(10,2) NOT NULL DEFAULT 50,
  security_deposit DECIMAL(10,2) NOT NULL DEFAULT 0,
  final_total DECIMAL(10,2) NOT NULL DEFAULT 0,
  status ENUM('pending','approved','rejected','cancelled','completed','paid','confirmed') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  INDEX bookings_property_dates_index (property_id, date_from, date_to),
  CONSTRAINT bookings_user_id_foreign FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT bookings_property_id_foreign FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
);

CREATE TABLE messages (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sender_id BIGINT UNSIGNED NOT NULL,
  receiver_id BIGINT UNSIGNED NOT NULL,
  message TEXT NOT NULL,
  status ENUM('sent','delivered','seen') NOT NULL DEFAULT 'sent',
  attachment_path VARCHAR(255) NULL,
  read_at TIMESTAMP NULL,
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  INDEX messages_thread_index (sender_id, receiver_id, created_at),
  CONSTRAINT messages_sender_id_foreign FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT messages_receiver_id_foreign FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE reviews (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NOT NULL,
  rating TINYINT UNSIGNED NOT NULL,
  comment TEXT NULL,
  owner_reply TEXT NULL,
  owner_replied_at TIMESTAMP NULL,
  moderated_at TIMESTAMP NULL,
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  UNIQUE KEY reviews_user_property_unique (user_id, property_id),
  CONSTRAINT reviews_user_id_foreign FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT reviews_property_id_foreign FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
);

CREATE TABLE favorites (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  UNIQUE KEY favorites_user_property_unique (user_id, property_id),
  CONSTRAINT favorites_user_id_foreign FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT favorites_property_id_foreign FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
);

CREATE TABLE payments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  booking_id BIGINT UNSIGNED NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  method ENUM('cash','card') NOT NULL,
  status ENUM('pending','paid','failed','refunded') NOT NULL DEFAULT 'pending',
  reference VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  INDEX payments_status_index (status),
  CONSTRAINT payments_booking_id_foreign FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
);

CREATE TABLE notifications (
  id CHAR(36) PRIMARY KEY,
  type VARCHAR(255) NOT NULL,
  notifiable_type VARCHAR(255) NOT NULL,
  notifiable_id BIGINT UNSIGNED NOT NULL,
  data TEXT NOT NULL,
  read_at TIMESTAMP NULL,
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  INDEX notifications_notifiable_index (notifiable_type, notifiable_id)
);

CREATE TABLE support_messages (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NULL,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NULL,
  phone VARCHAR(30) NULL,
  subject VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'open',
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  CONSTRAINT support_messages_user_id_foreign FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE personal_access_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tokenable_type VARCHAR(255) NOT NULL,
  tokenable_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(255) NOT NULL,
  token VARCHAR(64) NOT NULL UNIQUE,
  abilities TEXT NULL,
  last_used_at TIMESTAMP NULL,
  expires_at TIMESTAMP NULL,
  created_at TIMESTAMP NULL,
  updated_at TIMESTAMP NULL,
  INDEX personal_access_tokens_tokenable_index (tokenable_type, tokenable_id)
);
