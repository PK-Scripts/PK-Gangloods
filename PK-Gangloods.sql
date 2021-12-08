CREATE TABLE IF NOT EXISTS `pk-gangloods` (
  `gang` varchar(255) DEFAULT NULL,
  `gangloods` varchar(255) DEFAULT NULL,
  `garagespawnpoint` varchar(255) DEFAULT NULL,
  `garagedeletepoint` varchar(255) DEFAULT NULL,
  `stash` varchar(10000) DEFAULT '{}',
  `ingang` varchar(1000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;