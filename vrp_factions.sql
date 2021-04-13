ALTER TABLE `vrp_users` ADD (
  `faction` varchar(128) NULL DEFAULT 'user',
  `factionRank` varchar(128) NULL DEFAULT 'none',
  `isFactionLeader` tinyint NOT NULL DEFAULT '0',
  `isFactionCoLeader` int NOT NULL DEFAULT '0'
);
