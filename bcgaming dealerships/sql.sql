-- BCGAMING Dealership Database Setup
-- Run this SQL script in your database

CREATE TABLE IF NOT EXISTS `owned_vehicles` (
  `owner` varchar(60) NOT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext,
  `type` varchar(20) NOT NULL DEFAULT 'car',
  `job` varchar(20) DEFAULT NULL,
  `stored` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`plate`),
  KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Financing table
CREATE TABLE IF NOT EXISTS `vehicle_finances` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(60) NOT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` varchar(50) NOT NULL,
  `total_price` int(11) NOT NULL,
  `down_payment` int(11) NOT NULL,
  `monthly_payment` int(11) NOT NULL,
  `remaining_payments` int(11) NOT NULL,
  `total_payments` int(11) NOT NULL,
  `next_payment_date` bigint(20) NOT NULL,
  `paid_amount` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `owner` (`owner`),
  KEY `plate` (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Display vehicles table (for showroom)
CREATE TABLE IF NOT EXISTS `dealership_display_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dealership_id` int(11) NOT NULL,
  `slot_id` int(11) NOT NULL,
  `vehicle_model` varchar(50) NOT NULL,
  `vehicle_data` longtext,
  `coords_x` float NOT NULL,
  `coords_y` float NOT NULL,
  `coords_z` float NOT NULL,
  `heading` float NOT NULL,
  PRIMARY KEY (`id`),
  KEY `dealership_id` (`dealership_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
