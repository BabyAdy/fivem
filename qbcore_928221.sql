-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 29, 2026 at 08:16 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `qbcore_928221`
--

-- --------------------------------------------------------

--
-- Table structure for table `apartments`
--

CREATE TABLE `apartments` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `citizenid` varchar(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `apartments`
--

INSERT INTO `apartments` (`id`, `name`, `type`, `label`, `citizenid`) VALUES
(1, 'apartment2717196', 'apartment2', 'Morningwood Blvd 717196', 'MYD72564');

-- --------------------------------------------------------

--
-- Table structure for table `bank_accounts`
--

CREATE TABLE `bank_accounts` (
  `id` int(11) NOT NULL,
  `citizenid` varchar(11) DEFAULT NULL,
  `account_name` varchar(50) DEFAULT NULL,
  `account_balance` int(11) NOT NULL DEFAULT 0,
  `account_type` enum('shared','job','gang') NOT NULL,
  `users` longtext DEFAULT '[]'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bank_accounts`
--

INSERT INTO `bank_accounts` (`id`, `citizenid`, `account_name`, `account_balance`, `account_type`, `users`) VALUES
(1, NULL, 'beeker', 0, 'job', '[]'),
(2, NULL, 'mechanic2', 0, 'job', '[]'),
(3, NULL, 'realestate', 0, 'job', '[]'),
(4, NULL, 'lawyer', 0, 'job', '[]'),
(5, NULL, 'ambulance', 0, 'job', '[]'),
(6, NULL, 'cardealer', 0, 'job', '[]'),
(7, NULL, 'trucker', 0, 'job', '[]'),
(8, NULL, 'police', 0, 'job', '[]'),
(9, NULL, 'taxi', 0, 'job', '[]'),
(10, NULL, 'judge', 0, 'job', '[]'),
(11, NULL, 'hotdog', 0, 'job', '[]'),
(12, NULL, 'bus', 0, 'job', '[]'),
(13, NULL, 'mechanic', 0, 'job', '[]'),
(14, NULL, 'unemployed', 0, 'job', '[]'),
(15, NULL, 'garbage', 0, 'job', '[]'),
(16, NULL, 'mechanic3', 0, 'job', '[]'),
(17, NULL, 'vineyard', 0, 'job', '[]'),
(18, NULL, 'bennys', 0, 'job', '[]'),
(19, NULL, 'reporter', 0, 'job', '[]'),
(20, NULL, 'tow', 0, 'job', '[]');

-- --------------------------------------------------------

--
-- Table structure for table `bank_statements`
--

CREATE TABLE `bank_statements` (
  `id` int(11) NOT NULL,
  `citizenid` varchar(11) DEFAULT NULL,
  `account_name` varchar(50) DEFAULT 'checking',
  `amount` int(11) DEFAULT NULL,
  `reason` varchar(50) DEFAULT NULL,
  `statement_type` enum('deposit','withdraw') DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bans`
--

CREATE TABLE `bans` (
  `id` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `license` varchar(50) DEFAULT NULL,
  `discord` varchar(50) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `expire` int(11) DEFAULT NULL,
  `bannedby` varchar(255) NOT NULL DEFAULT 'LeBanhammer'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `crypto`
--

CREATE TABLE `crypto` (
  `crypto` varchar(50) NOT NULL DEFAULT 'qbit',
  `worth` int(11) NOT NULL DEFAULT 0,
  `history` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `crypto`
--

INSERT INTO `crypto` (`crypto`, `worth`, `history`) VALUES
('qbit', 982, '[{\"PreviousWorth\":985,\"NewWorth\":978},{\"PreviousWorth\":985,\"NewWorth\":978},{\"PreviousWorth\":985,\"NewWorth\":978},{\"PreviousWorth\":978,\"NewWorth\":982}]');

-- --------------------------------------------------------

--
-- Table structure for table `crypto_transactions`
--

CREATE TABLE `crypto_transactions` (
  `id` int(11) NOT NULL,
  `citizenid` varchar(11) DEFAULT NULL,
  `title` varchar(50) DEFAULT NULL,
  `message` varchar(50) DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dealers`
--

CREATE TABLE `dealers` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL DEFAULT '0',
  `coords` longtext DEFAULT NULL,
  `time` longtext DEFAULT NULL,
  `createdby` varchar(50) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `houselocations`
--

CREATE TABLE `houselocations` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `coords` text DEFAULT NULL,
  `owned` tinyint(1) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `tier` tinyint(4) DEFAULT NULL,
  `garage` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `house_plants`
--

CREATE TABLE `house_plants` (
  `id` int(11) NOT NULL,
  `building` varchar(50) DEFAULT NULL,
  `stage` int(11) DEFAULT 1,
  `sort` varchar(50) DEFAULT NULL,
  `gender` varchar(50) DEFAULT NULL,
  `food` int(11) DEFAULT 100,
  `health` int(11) DEFAULT 100,
  `progress` int(11) DEFAULT 0,
  `coords` text DEFAULT NULL,
  `plantid` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventories`
--

CREATE TABLE `inventories` (
  `id` int(11) NOT NULL,
  `identifier` varchar(50) NOT NULL,
  `items` longtext DEFAULT '[]'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lapraces`
--

CREATE TABLE `lapraces` (
  `id` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `checkpoints` text DEFAULT NULL,
  `records` text DEFAULT NULL,
  `creator` varchar(50) DEFAULT NULL,
  `distance` int(11) DEFAULT NULL,
  `raceid` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `occasion_vehicles`
--

CREATE TABLE `occasion_vehicles` (
  `id` int(11) NOT NULL,
  `seller` varchar(50) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `plate` varchar(50) DEFAULT NULL,
  `model` varchar(50) DEFAULT NULL,
  `mods` text DEFAULT NULL,
  `occasionid` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `phone_gallery`
--

CREATE TABLE `phone_gallery` (
  `citizenid` varchar(11) NOT NULL,
  `image` varchar(255) NOT NULL,
  `date` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `phone_invoices`
--

CREATE TABLE `phone_invoices` (
  `id` int(10) NOT NULL,
  `citizenid` varchar(11) DEFAULT NULL,
  `amount` int(11) NOT NULL DEFAULT 0,
  `society` tinytext DEFAULT NULL,
  `sender` varchar(50) DEFAULT NULL,
  `sendercitizenid` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `phone_messages`
--

CREATE TABLE `phone_messages` (
  `id` int(11) NOT NULL,
  `citizenid` varchar(11) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `messages` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `phone_tweets`
--

CREATE TABLE `phone_tweets` (
  `id` int(11) NOT NULL,
  `citizenid` varchar(11) DEFAULT NULL,
  `firstName` varchar(25) DEFAULT NULL,
  `lastName` varchar(25) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `date` datetime DEFAULT current_timestamp(),
  `url` text DEFAULT NULL,
  `picture` varchar(512) DEFAULT './img/default.png',
  `tweetId` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE `players` (
  `id` int(11) NOT NULL,
  `citizenid` varchar(11) NOT NULL,
  `cid` int(11) DEFAULT NULL,
  `license` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `money` text NOT NULL,
  `charinfo` text DEFAULT NULL,
  `job` text NOT NULL,
  `gang` text DEFAULT NULL,
  `position` text NOT NULL,
  `metadata` text NOT NULL,
  `inventory` longtext DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `players`
--

INSERT INTO `players` (`id`, `citizenid`, `cid`, `license`, `name`, `money`, `charinfo`, `job`, `gang`, `position`, `metadata`, `inventory`, `last_updated`) VALUES
(1, 'MYD72564', 1, 'license:bb3e769bb5388839da0f3730a66e9ac0e2042971', 'BabyAdy', '{\"cash\":500,\"crypto\":0,\"bank\":5000}', '{\"account\":\"US02QBCore4213714565\",\"phone\":\"5563328702\",\"lastname\":\"Test\",\"gender\":0,\"cid\":1,\"nationality\":\"Romania\",\"firstname\":\"BabyAdy\",\"birthdate\":\"2026-08-29\"}', '{\"payment\":10,\"isboss\":false,\"onduty\":true,\"type\":\"none\",\"grade\":{\"level\":0,\"name\":\"Freelancer\"},\"label\":\"Civilian\",\"name\":\"unemployed\"}', '{\"grade\":{\"level\":0,\"name\":\"none\"},\"isboss\":false,\"label\":\"No Gang Affiliation\",\"name\":\"none\"}', '{\"x\":-779.024169921875,\"y\":326.1758117675781,\"z\":196.076171875}', '{\"criminalrecord\":{\"hasRecord\":false},\"phonedata\":{\"InstalledApps\":[],\"SerialNumber\":23302710},\"ishandcuffed\":false,\"inlaststand\":false,\"hunger\":95.8,\"inside\":{\"apartment\":[]},\"status\":[],\"injail\":0,\"phone\":[],\"fingerprint\":\"sP724d25pPR3879\",\"thirst\":96.2,\"isdead\":false,\"tracker\":false,\"walletid\":\"QB-36049437\",\"stress\":0,\"jailitems\":[],\"callsign\":\"NO CALLSIGN\",\"rep\":[],\"licences\":{\"business\":false,\"driver\":true,\"weapon\":false},\"bloodtype\":\"B-\",\"armor\":0}', '[{\"name\":\"phone\",\"slot\":1,\"type\":\"item\",\"info\":[],\"amount\":1},{\"name\":\"driver_license\",\"slot\":2,\"type\":\"item\",\"info\":{\"lastname\":\"Test\",\"birthdate\":\"2026-08-29\",\"firstname\":\"BabyAdy\",\"type\":\"Class C Driver License\"},\"amount\":1},{\"name\":\"id_card\",\"slot\":3,\"type\":\"item\",\"info\":{\"gender\":0,\"nationality\":\"Romania\",\"lastname\":\"Test\",\"birthdate\":\"2026-08-29\",\"firstname\":\"BabyAdy\",\"citizenid\":\"MYD72564\"},\"amount\":1}]', '2026-08-29 08:49:20'),
(3, 'UJC01590', 1, 'license:bb3e769bb5388839da0f3730a66e9ac0e2042971', 'BabyAdy', '{\"cash\":500,\"bank\":5040,\"crypto\":0}', '{\"firstname\":\"BabyAdy\",\"lastname\":\"\",\"phone\":\"7726747146\",\"nationality\":\"România\",\"account\":\"US06QBCore7954700571\",\"gender\":1,\"birthdate\":\"2000-01-01\"}', '{\"onduty\":true,\"label\":\"Civilian\",\"type\":\"none\",\"name\":\"unemployed\",\"grade\":{\"name\":\"Freelancer\",\"level\":0,\"isboss\":false,\"payment\":10},\"isboss\":false,\"payment\":10}', '{\"name\":\"none\",\"grade\":{\"name\":\"Unaffiliated\",\"level\":0,\"isboss\":false},\"isboss\":false,\"label\":\"No Gang\"}', '{\"x\":-736.03515625,\"y\":-2198.597900390625,\"z\":5.993408203125}', '{\"fingerprint\":\"UH163y55CQE8125\",\"ishandcuffed\":false,\"jailitems\":[],\"phonedata\":{\"InstalledApps\":[],\"SerialNumber\":20903366},\"stress\":3,\"tracker\":false,\"walletid\":\"QB-72271414\",\"injail\":0,\"bloodtype\":\"A+\",\"phone\":[],\"criminalrecord\":{\"hasRecord\":false},\"rep\":[],\"armor\":0,\"inlaststand\":false,\"isdead\":false,\"licences\":{\"driver\":true,\"weapon\":false,\"business\":false},\"inside\":{\"apartment\":[]},\"status\":[],\"callsign\":\"NO CALLSIGN\",\"hunger\":95.8,\"thirst\":96.2}', '[{\"info\":[],\"name\":\"phone\",\"slot\":1,\"amount\":1,\"type\":\"item\"},{\"info\":{\"ammo\":76,\"quality\":96.25,\"serie\":\"10Yfh1ZA277WoqJ\"},\"name\":\"weapon_pumpshotgun\",\"slot\":2,\"amount\":1,\"type\":\"weapon\"},{\"info\":[],\"name\":\"lockpick\",\"slot\":3,\"amount\":8,\"type\":\"item\"}]', '2026-08-29 13:19:26');

-- --------------------------------------------------------

--
-- Table structure for table `playerskins`
--

CREATE TABLE `playerskins` (
  `id` int(11) NOT NULL,
  `citizenid` varchar(11) NOT NULL,
  `model` varchar(255) NOT NULL,
  `skin` text NOT NULL,
  `active` tinyint(4) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `playerskins`
--

INSERT INTO `playerskins` (`id`, `citizenid`, `model`, `skin`, `active`) VALUES
(1, 'MYD72564', '1382414087', '{\"bag\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"shoes\":{\"item\":1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":1},\"hair\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"eye_color\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1},\"t-shirt\":{\"item\":1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":1},\"moles\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1},\"blush\":{\"item\":-1,\"texture\":1,\"defaultTexture\":1,\"defaultItem\":-1},\"chimp_bone_width\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"pants\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"facemix\":{\"defaultShapeMix\":0.0,\"skinMix\":0,\"shapeMix\":0,\"defaultSkinMix\":0.0},\"vest\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"nose_3\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"hat\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1},\"neck_thikness\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"bracelet\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1},\"eyebrows\":{\"item\":-1,\"texture\":1,\"defaultTexture\":1,\"defaultItem\":-1},\"arms\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"mask\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"ear\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1},\"chimp_hole\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"chimp_bone_lenght\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"chimp_bone_lowering\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"eye_opening\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"accessory\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"glass\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"beard\":{\"item\":-1,\"texture\":1,\"defaultTexture\":1,\"defaultItem\":-1},\"jaw_bone_width\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"nose_0\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"lips_thickness\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"cheek_3\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"cheek_2\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"cheek_1\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"face\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"lipstick\":{\"item\":-1,\"texture\":1,\"defaultTexture\":1,\"defaultItem\":-1},\"nose_5\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"nose_1\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"torso2\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"decals\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"nose_4\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"makeup\":{\"item\":-1,\"texture\":1,\"defaultTexture\":1,\"defaultItem\":-1},\"eyebrown_high\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"nose_2\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"jaw_bone_back_lenght\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"face2\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0},\"watch\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1},\"ageing\":{\"item\":-1,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":-1},\"eyebrown_forward\":{\"item\":0,\"texture\":0,\"defaultTexture\":0,\"defaultItem\":0}}', 1),
(5, 'UJC01590', '-1667301416', '{\"eye_opening\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"arms\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":4},\"shoes\":{\"texture\":9,\"defaultItem\":1,\"defaultTexture\":0,\"item\":103},\"blush\":{\"texture\":1,\"defaultItem\":-1,\"defaultTexture\":1,\"item\":-1},\"eye_color\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":14},\"ageing\":{\"texture\":0,\"defaultItem\":-1,\"defaultTexture\":0,\"item\":-1},\"chimp_bone_lowering\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"torso2\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":537},\"jaw_bone_back_lenght\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"beard\":{\"texture\":0,\"defaultItem\":-1,\"defaultTexture\":0,\"item\":-1},\"chimp_bone_width\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"nose_2\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"cheek_1\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"face2\":{\"texture\":6,\"defaultItem\":0,\"defaultTexture\":0,\"item\":6},\"eyebrown_high\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"accessory\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"decals\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"lipstick\":{\"texture\":1,\"defaultItem\":-1,\"defaultTexture\":1,\"item\":-1},\"nose_1\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"eyebrows\":{\"texture\":45,\"defaultItem\":-1,\"defaultTexture\":0,\"item\":12},\"cheek_3\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"moles\":{\"texture\":0,\"defaultItem\":-1,\"defaultTexture\":0,\"item\":-1},\"hair\":{\"texture\":13,\"defaultItem\":0,\"defaultTexture\":0,\"item\":42},\"eyebrown_forward\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"watch\":{\"texture\":0,\"defaultItem\":-1,\"defaultTexture\":0,\"item\":-1},\"neck_thikness\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"facemix\":{\"defaultSkinMix\":0.5,\"shapeMix\":0.3,\"skinMix\":0.83,\"defaultShapeMix\":0.5},\"bag\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"mask\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"hat\":{\"texture\":0,\"defaultItem\":-1,\"defaultTexture\":0,\"item\":-1},\"chimp_hole\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"pants\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":27},\"nose_3\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"face\":{\"texture\":31,\"defaultItem\":0,\"defaultTexture\":0,\"item\":31},\"ear\":{\"texture\":0,\"defaultItem\":-1,\"defaultTexture\":0,\"item\":-1},\"vest\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"bracelet\":{\"texture\":0,\"defaultItem\":-1,\"defaultTexture\":0,\"item\":-1},\"chimp_bone_lenght\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"glass\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"cheek_2\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"makeup\":{\"texture\":1,\"defaultItem\":-1,\"defaultTexture\":1,\"item\":-1},\"nose_5\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"t-shirt\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":23},\"lips_thickness\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"nose_0\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"jaw_bone_width\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0},\"nose_4\":{\"texture\":0,\"defaultItem\":0,\"defaultTexture\":0,\"item\":0}}', 1);

-- --------------------------------------------------------

--
-- Table structure for table `player_contacts`
--

CREATE TABLE `player_contacts` (
  `id` int(11) NOT NULL,
  `citizenid` varchar(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `iban` varchar(50) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_houses`
--

CREATE TABLE `player_houses` (
  `id` int(255) NOT NULL,
  `house` varchar(50) NOT NULL,
  `identifier` varchar(50) DEFAULT NULL,
  `citizenid` varchar(11) DEFAULT NULL,
  `keyholders` text DEFAULT NULL,
  `decorations` text DEFAULT NULL,
  `stash` text DEFAULT NULL,
  `outfit` text DEFAULT NULL,
  `logout` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_mails`
--

CREATE TABLE `player_mails` (
  `id` int(11) NOT NULL,
  `citizenid` varchar(11) DEFAULT NULL,
  `sender` varchar(50) DEFAULT NULL,
  `subject` varchar(50) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `read` tinyint(4) DEFAULT 0,
  `mailid` int(11) DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `button` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_outfits`
--

CREATE TABLE `player_outfits` (
  `id` int(11) NOT NULL,
  `citizenid` varchar(11) DEFAULT NULL,
  `outfitname` varchar(50) NOT NULL,
  `model` varchar(50) DEFAULT NULL,
  `skin` text DEFAULT NULL,
  `outfitId` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_vehicles`
--

CREATE TABLE `player_vehicles` (
  `id` int(11) NOT NULL,
  `license` varchar(50) DEFAULT NULL,
  `citizenid` varchar(11) DEFAULT NULL,
  `vehicle` varchar(50) DEFAULT NULL,
  `hash` varchar(50) DEFAULT NULL,
  `mods` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `plate` varchar(8) NOT NULL,
  `fakeplate` varchar(8) DEFAULT NULL,
  `garage` varchar(50) DEFAULT NULL,
  `fuel` int(11) DEFAULT 100,
  `engine` float DEFAULT 1000,
  `body` float DEFAULT 1000,
  `state` int(11) DEFAULT 1,
  `depotprice` int(11) NOT NULL DEFAULT 0,
  `drivingdistance` int(50) DEFAULT NULL,
  `status` text DEFAULT NULL,
  `balance` int(11) NOT NULL DEFAULT 0,
  `paymentamount` int(11) NOT NULL DEFAULT 0,
  `paymentsleft` int(11) NOT NULL DEFAULT 0,
  `financetime` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `player_warns`
--

CREATE TABLE `player_warns` (
  `id` int(11) NOT NULL,
  `senderIdentifier` varchar(50) DEFAULT NULL,
  `targetIdentifier` varchar(50) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `warnId` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `license` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `citizenid` varchar(11) DEFAULT NULL,
  `staff` varchar(20) NOT NULL DEFAULT 'none',
  `subscription` varchar(20) NOT NULL DEFAULT 'none',
  `money` bigint(20) NOT NULL DEFAULT 0,
  `bank` bigint(20) NOT NULL DEFAULT 0,
  `pp` bigint(20) NOT NULL DEFAULT 0,
  `paycheck` int(11) NOT NULL DEFAULT 3599,
  `food` tinyint(4) NOT NULL DEFAULT 100,
  `water` tinyint(4) NOT NULL DEFAULT 100
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `license`, `username`, `email`, `password`, `created_at`, `citizenid`, `staff`, `subscription`, `money`, `bank`, `pp`, `paycheck`, `food`, `water`) VALUES
(1, 'license:bb3e769bb5388839da0f3730a66e9ac0e2042971', 'BabyAdy', 'test@gmail.com', 'pbkdf2$sha256$2500$68d021a4af2d74353f12bde5aaecfb7e$f2a31bb3457e6ac23d58ab972a0bcf8aea25bc7f25b39ff5da50d9678bd8a9df', '2026-08-29 10:38:32', 'UJC01590', 'owner', 'none', 500, 5040, 0, 3050, 95, 96);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `apartments`
--
ALTER TABLE `apartments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `citizenid` (`citizenid`),
  ADD KEY `name` (`name`);

--
-- Indexes for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD UNIQUE KEY `account_name` (`account_name`);

--
-- Indexes for table `bank_statements`
--
ALTER TABLE `bank_statements`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `citizenid` (`citizenid`);

--
-- Indexes for table `bans`
--
ALTER TABLE `bans`
  ADD PRIMARY KEY (`id`),
  ADD KEY `license` (`license`),
  ADD KEY `discord` (`discord`),
  ADD KEY `ip` (`ip`);

--
-- Indexes for table `crypto`
--
ALTER TABLE `crypto`
  ADD PRIMARY KEY (`crypto`);

--
-- Indexes for table `crypto_transactions`
--
ALTER TABLE `crypto_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `citizenid` (`citizenid`);

--
-- Indexes for table `dealers`
--
ALTER TABLE `dealers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `houselocations`
--
ALTER TABLE `houselocations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`);

--
-- Indexes for table `house_plants`
--
ALTER TABLE `house_plants`
  ADD PRIMARY KEY (`id`),
  ADD KEY `building` (`building`),
  ADD KEY `plantid` (`plantid`);

--
-- Indexes for table `inventories`
--
ALTER TABLE `inventories`
  ADD PRIMARY KEY (`identifier`),
  ADD KEY `id` (`id`);

--
-- Indexes for table `lapraces`
--
ALTER TABLE `lapraces`
  ADD PRIMARY KEY (`id`),
  ADD KEY `raceid` (`raceid`);

--
-- Indexes for table `occasion_vehicles`
--
ALTER TABLE `occasion_vehicles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `occasionId` (`occasionid`);

--
-- Indexes for table `phone_invoices`
--
ALTER TABLE `phone_invoices`
  ADD PRIMARY KEY (`id`),
  ADD KEY `citizenid` (`citizenid`);

--
-- Indexes for table `phone_messages`
--
ALTER TABLE `phone_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `citizenid` (`citizenid`),
  ADD KEY `number` (`number`);

--
-- Indexes for table `phone_tweets`
--
ALTER TABLE `phone_tweets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `citizenid` (`citizenid`);

--
-- Indexes for table `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`citizenid`),
  ADD KEY `id` (`id`),
  ADD KEY `last_updated` (`last_updated`),
  ADD KEY `license` (`license`);

--
-- Indexes for table `playerskins`
--
ALTER TABLE `playerskins`
  ADD PRIMARY KEY (`id`),
  ADD KEY `citizenid` (`citizenid`),
  ADD KEY `active` (`active`);

--
-- Indexes for table `player_contacts`
--
ALTER TABLE `player_contacts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `citizenid` (`citizenid`);

--
-- Indexes for table `player_houses`
--
ALTER TABLE `player_houses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `house` (`house`),
  ADD KEY `citizenid` (`citizenid`),
  ADD KEY `identifier` (`identifier`);

--
-- Indexes for table `player_mails`
--
ALTER TABLE `player_mails`
  ADD PRIMARY KEY (`id`),
  ADD KEY `citizenid` (`citizenid`);

--
-- Indexes for table `player_outfits`
--
ALTER TABLE `player_outfits`
  ADD PRIMARY KEY (`id`),
  ADD KEY `citizenid` (`citizenid`),
  ADD KEY `outfitId` (`outfitId`);

--
-- Indexes for table `player_vehicles`
--
ALTER TABLE `player_vehicles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `plate` (`plate`),
  ADD KEY `citizenid` (`citizenid`),
  ADD KEY `license` (`license`);

--
-- Indexes for table `player_warns`
--
ALTER TABLE `player_warns`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `citizenid` (`citizenid`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `apartments`
--
ALTER TABLE `apartments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `bank_statements`
--
ALTER TABLE `bank_statements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bans`
--
ALTER TABLE `bans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `crypto_transactions`
--
ALTER TABLE `crypto_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dealers`
--
ALTER TABLE `dealers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `houselocations`
--
ALTER TABLE `houselocations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `house_plants`
--
ALTER TABLE `house_plants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventories`
--
ALTER TABLE `inventories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lapraces`
--
ALTER TABLE `lapraces`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `occasion_vehicles`
--
ALTER TABLE `occasion_vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `phone_invoices`
--
ALTER TABLE `phone_invoices`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `phone_messages`
--
ALTER TABLE `phone_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `phone_tweets`
--
ALTER TABLE `phone_tweets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `players`
--
ALTER TABLE `players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `playerskins`
--
ALTER TABLE `playerskins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `player_contacts`
--
ALTER TABLE `player_contacts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `player_houses`
--
ALTER TABLE `player_houses`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `player_mails`
--
ALTER TABLE `player_mails`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `player_outfits`
--
ALTER TABLE `player_outfits`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `player_vehicles`
--
ALTER TABLE `player_vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `player_warns`
--
ALTER TABLE `player_warns`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
