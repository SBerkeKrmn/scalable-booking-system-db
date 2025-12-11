-- ---------------------------------------------------------
-- Project: Generic Booking & Reservation System Database
-- Description: A scalable database schema for booking venues, 
-- managing providers, and handling community groups.
-- ---------------------------------------------------------

CREATE DATABASE IF NOT EXISTS generic_booking_db;
USE generic_booking_db;

-- 1. USERS (Standard App Users)
CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(30) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_email_verified BOOLEAN DEFAULT FALSE,
    avatar_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. SERVICE PROVIDERS (Business Owners)
CREATE TABLE ServiceProviders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(11) NOT NULL,
    verification_doc_url VARCHAR(255),
    is_verified BOOLEAN DEFAULT FALSE, -- Admin approval status
    is_phone_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. VENUES (Resource to be booked)
CREATE TABLE Venues (
    id INT AUTO_INCREMENT PRIMARY KEY,
    provider_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    district VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    price_per_hour DECIMAL(10, 2) NOT NULL,
    deposit_amount DECIMAL(10, 2) NOT NULL,
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    cover_image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES ServiceProviders(id) ON DELETE CASCADE
);

-- 4. VENUE IMAGES
CREATE TABLE VenueImages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    venue_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (venue_id) REFERENCES Venues(id) ON DELETE CASCADE
);

-- 5. VENUE BLOCKED HOURS (Recurring unavailability)
CREATE TABLE VenueBlockedHours (
    id INT AUTO_INCREMENT PRIMARY KEY,
    venue_id INT NOT NULL,
    day_of_week TINYINT NOT NULL, -- 1: Monday ... 7: Sunday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    reason VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (venue_id) REFERENCES Venues(id) ON DELETE CASCADE
);

-- 6. COMMUNITY GROUPS (Groups specific to Venues)
CREATE TABLE CommunityGroups (
    id INT AUTO_INCREMENT PRIMARY KEY,
    venue_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    avatar_url VARCHAR(255),
    activity_score INT DEFAULT 0, -- Generic metric (instead of wins)
    reputation_score INT DEFAULT 0, -- Generic metric (instead of losses)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (venue_id) REFERENCES Venues(id) ON DELETE CASCADE,
    UNIQUE (venue_id, name) -- Business Rule: Group names must be unique per venue
);

-- 7. GROUP MEMBERS (Many-to-Many Relationship)
CREATE TABLE GroupMembers (
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    role ENUM('ADMIN', 'MODERATOR', 'MEMBER') DEFAULT 'MEMBER',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (group_id, user_id),
    FOREIGN KEY (group_id) REFERENCES CommunityGroups(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- 8. BOOKINGS (Reservation Transactions)
CREATE TABLE Bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    venue_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    price_at_booking DECIMAL(10, 2) NOT NULL, -- Snapshot of price
    deposit_paid DECIMAL(10, 2) NOT NULL, -- Snapshot of deposit
    contact_phone VARCHAR(11) NOT NULL,
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (venue_id) REFERENCES Venues(id) ON DELETE CASCADE
);

-- 9. REVIEWS (Verified feedback)
CREATE TABLE Reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    rating TINYINT NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES Bookings(id) ON DELETE CASCADE,
    UNIQUE (booking_id), -- One review per booking
    CHECK (rating >= 1 AND rating <= 5)
);