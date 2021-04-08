ALTER TABLE `vrp_users` ADD (
  `faction` varchar(128) DEFAULT NULL,
  `factionRank` varchar(128) DEFAULT NULL,
  `isFactionLeader` tinyint NOT NULL DEFAULT '0',
  `isFactionCoLeader` int NOT NULL DEFAULT '0'
);
