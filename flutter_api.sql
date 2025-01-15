-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 15, 2025 at 02:44 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `flutter_api`
--

-- --------------------------------------------------------

--
-- Table structure for table `content`
--

CREATE TABLE `content` (
  `id_item` int(8) NOT NULL,
  `image_item` varchar(255) DEFAULT NULL,
  `item_name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `content`
--

INSERT INTO `content` (`id_item`, `image_item`, `item_name`, `description`) VALUES
(6, 'https://ae01.alicdn.com/kf/Sb3fdb23baae44ddeb8d45df4f55ac1526.png', 'Xiaomi Cyberdog', 'Xiaomi Cyberdog: A robotic dog developed by Xiaomi, featuring advanced AI, computer vision, and movement capabilities. It can perform tasks like following commands, obstacle avoidance, and carrying objects, designed for both entertainment and research.'),
(8, 'https://www.hiwonder.com/cdn/shop/files/3034a1133efe01daba919094b70c6310_3474adea-bc6a-4257-b3ba-45e8b8a9269c.jpg?v=1700745164%201200w', 'JetArm', 'JetArm JETSON NANO: A robotic arm powered by NVIDIA\'s Jetson Nano, designed for tasks like object manipulation and automation. It combines high-performance computing with deep learning to offer precise control and adaptability.'),
(9, 'https://lh5.googleusercontent.com/proxy/nzQ5YnIU7xtWhWvEAYG0Xsp2CqwpKmi7ciHIc8WgNSQDqhAELehmm_jqbGTSnwDrW0KtIHBgoXN6OaZrQkdfSIi79HyRRaiEe_ToAA_uZwuZKCyhcD8v5m6h_BSXaBPxFYqB53mLBw', 'Robotic Spider', 'Robotic Spider: A spider-inspired robot with multiple legs, capable of navigating complex terrains. Its design allows it to crawl, climb, and adapt to different surfaces, often used in exploration or educational purposes.'),
(10, 'https://down-id.img.susercontent.com/file/b2325c856ded70fd0d026573e00531ea', 'Transporter Robot', 'Transporter Robot: A mobile robot designed to transport goods or materials autonomously. It uses sensors and AI to navigate environments, offering efficient and safe solutions for warehouses, factories, or hospitals.'),
(14, 'https://1.bp.blogspot.com/-ssDaGZnNNiU/VCaeZrWixkI/AAAAAAAAAL4/SFiRHhKa000/s1600/Robot%2BBeroda%2B3%2Bkelas%2Brobot.jpg', 'Wheeled Robot', 'Wheeled Robot: A robot with wheels for movement, ideal for indoor navigation or simple tasks. Often used for educational purposes, it combines basic robotics with ease of control and mobility.'),
(19, 'https://images-cdn.ubuy.co.id/6408d1f1591f301731096433-dji-robomaster-s1-intelligent.jpg', 'Tank Robots', 'Tank Robots: Robots with tank-like tracks, designed for rough terrain. They are used in military, exploration, and research fields for their stability, durability, and ability to traverse challenging environments.'),
(20, 'https://miro.medium.com/v2/resize:fit:750/1*rWaq1hn09zg5KWgyQHaS4g.jpeg', 'Soccer Robot', 'Soccer Robot: A robot designed for playing soccer autonomously or in a team. It is equipped with sensors and algorithms to track the ball, avoid obstacles, and make decisions based on game dynamics.'),
(22, 'https://creatorset.com/cdn/shop/files/Screenshot_2024-04-24_173231_1114x.png?v=1713973029', 'aejdijeo', 'sjdnsdkakh');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(8) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `profile` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `username`, `password`, `profile`) VALUES
(20, 'tedysyh@gmail.com', 'tedy_firmansyah', '$2a$10$73WZZjMIyabao2BGwoiwMefWTXY23EESvRl4i3dL9as3ysqZUiG2u', 'https://avatars.githubusercontent.com/u/153618013?v=4');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `content`
--
ALTER TABLE `content`
  ADD PRIMARY KEY (`id_item`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `content`
--
ALTER TABLE `content`
  MODIFY `id_item` int(8) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(8) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
