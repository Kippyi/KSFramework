-- KSFramework Database Installation Script
-- Run this script on your MySQL database before starting the framework

CREATE DATABASE IF NOT EXISTS `ksframework` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `ksframework`;

-- Users table
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(50) NOT NULL,
    `name` VARCHAR(50) NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Player characters table
CREATE TABLE IF NOT EXISTS `player_characters` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(50) NOT NULL,
    `firstname` VARCHAR(50) NOT NULL,
    `lastname` VARCHAR(50) NOT NULL,
    `dateofbirth` DATE NOT NULL,
    `gender` VARCHAR(10) NOT NULL,
    `nationality` VARCHAR(50) DEFAULT 'American',
    `height` INT(11) DEFAULT 180,
    `skin` JSON DEFAULT NULL,
    `job` VARCHAR(50) DEFAULT 'unemployed',
    `job_grade` INT(11) DEFAULT 0,
    `level` INT(11) DEFAULT 1,
    `xp` INT(11) DEFAULT 0,
    `cash` INT(11) DEFAULT 0,
    `bank` INT(11) DEFAULT 0,
    `bank_debt` INT(11) DEFAULT 0,
    `position` JSON DEFAULT '{"x": 0.0, "y": 0.0, "z": 0.0}',
    `inventory` JSON DEFAULT '{}',
    `metadata` JSON DEFAULT '{}',
    `is_dead` TINYINT(1) DEFAULT 0,
    `last_seen` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `identifier` (`identifier`),
    INDEX `job` (`job`),
    INDEX `job_grade` (`job_grade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Player jobs table
CREATE TABLE IF NOT EXISTS `player_jobs` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `character_id` INT(11) NOT NULL,
    `job_name` VARCHAR(50) NOT NULL,
    `job_grade` INT(11) DEFAULT 0,
    `on_duty` TINYINT(1) DEFAULT 0,
    `employed_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (character_id) REFERENCES player_characters(id) ON DELETE CASCADE,
    INDEX `character_id` (character_id),
    INDEX `job_name` (job_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Items / Inventory table
CREATE TABLE IF NOT EXISTS `items` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `character_id` INT(11) NOT NULL,
    `name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `weight` FLOAT DEFAULT 1.0,
    `count` INT(11) DEFAULT 1,
    `info` JSON DEFAULT NULL,
    `type` VARCHAR(20) DEFAULT 'item',
    `unique` TINYINT(1) DEFAULT 0,
    `usable` TINYINT(1) DEFAULT 0,
    `rare` TINYINT(1) DEFAULT 0,
    `can_remove` TINYINT(1) DEFAULT 1,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (character_id) REFERENCES player_characters(id) ON DELETE CASCADE,
    INDEX `character_id` (character_id),
    INDEX `name` (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Properties table
CREATE TABLE IF NOT EXISTS `properties` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `type` VARCHAR(20) DEFAULT 'house',
    `price` INT(11) NOT NULL DEFAULT 0,
    `rent` INT(11) DEFAULT 0,
    `owned` TINYINT(1) DEFAULT 0,
    `owner` INT(11) DEFAULT NULL,
    `price_rent` INT(11) DEFAULT 0,
    `position` JSON DEFAULT NULL,
    `interior` JSON DEFAULT NULL,
    `exterior` JSON DEFAULT NULL,
    `gateway` JSON DEFAULT NULL,
    `room` JSON DEFAULT NULL,
    `menu` JSON DEFAULT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `owned` (`owned`),
    INDEX `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Society accounts table
CREATE TABLE IF NOT EXISTS `society_accounts` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `money` INT(11) DEFAULT 0,
    `bank` INT(11) DEFAULT 0,
    `type` VARCHAR(20) DEFAULT 'society',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Bank transactions log
CREATE TABLE IF NOT EXISTS `bank_transactions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `character_id` INT(11) NOT NULL,
    `transaction_type` VARCHAR(20) NOT NULL,
    `amount` INT(11) NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `character_id` (character_id),
    INDEX `transaction_type` (transaction_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default society accounts
INSERT IGNORE INTO `society_accounts` (`name`, `label`, `type`, `money`, `bank`) VALUES
('society_police', 'Police Department', 'society', 0, 50000),
('society_ambulance', 'Ambulance Service', 'society', 0, 30000),
('society_mechanic', 'Mechanic Shop', 'society', 0, 20000),
('society_taxi', 'Taxi Company', 'society', 0, 15000);

-- Insert default items
INSERT IGNORE INTO `items` (`character_id`, `name`, `label`, `weight`, `count`, `type`, `usable`, `rare`, `can_remove`) VALUES
(0, 'water', 'Water Bottle', 0.5, 0, 'item', 1, 0, 1),
(0, 'burger', 'Burger', 0.3, 0, 'item', 1, 0, 1),
(0, 'bandage', 'Bandage', 0.2, 0, 'item', 1, 0, 1),
(0, 'phone', 'Phone', 0.3, 0, 'item', 0, 0, 0),
(0, 'id_card', 'ID Card', 0.1, 0, 'item', 0, 0, 0),
(0, 'radio', 'Radio', 0.5, 0, 'item', 0, 0, 1),
(0, 'lockpick', 'Lockpick', 0.2, 0, 'item', 0, 0, 1),
(0, 'firstaid', 'First Aid Kit', 1.0, 0, 'item', 1, 0, 1);

-- Insert sample properties
INSERT IGNORE INTO `properties` (`name`, `label`, `type`, `price`, `rent`, `owned`, `position`) VALUES
('apt_downtown_1', 'Downtown Apartment 1', 'apartment', 150000, 500, 0, '{"x": 291.5, "y": -588.0, "z": 43.0}'),
('apt_downtown_2', 'Downtown Apartment 2', 'apartment', 175000, 550, 0, '{"x": 312.0, "y": -601.0, "z": 43.0}'),
('house_vinewood_1', 'Vinewood House', 'house', 500000, 1500, 0, '{"x": -1288.0, "y": 440.0, "z": 97.0}'),
('house_sandy_1', 'Sandy Shores House', 'house', 200000, 700, 0, '{"x": 1798.0, "y": 3672.0, "z": 34.0}'),
('garage_downtown_1', 'Downtown Garage', 'garage', 75000, 250, 0, '{"x": 230.0, "y": -1141.0, "z": 29.0}');
