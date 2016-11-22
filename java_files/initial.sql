
USE `abc123`;

DROP TABLE IF EXISTS `revisions`;
DROP TABLE IF EXISTS `articles`;


CREATE TABLE IF NOT EXISTS `articles` (
  `_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `url` varchar(1024) NOT NULL,
  `lastSeen` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `resource` varchar(1024) NOT NULL,
  `processed` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `counter` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `creationTime` datetime DEFAULT NULL,
  `title` text CHARACTER SET utf8mb4,
  `authors` varchar(1024) CHARACTER SET utf8mb4 DEFAULT NULL,
  `category` varchar(1024) CHARACTER SET utf8mb4 DEFAULT NULL,
  `content` mediumtext CHARACTER SET utf8mb4,
  PRIMARY KEY (`_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE IF NOT EXISTS `revisions` (
  `_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `articleId` int(11) unsigned NOT NULL,
  `loadedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `rawContent` mediumtext CHARACTER SET utf8mb4 NOT NULL,
  `resource` varchar(1024) NOT NULL,
  `processed` tinyint(1) NOT NULL DEFAULT '0',
  `valid` tinyint(1) NOT NULL DEFAULT '0',
  `likes` int(11) NOT NULL DEFAULT '0',
  `reposts` int(11) NOT NULL DEFAULT '0',
  `comments` int(11) NOT NULL DEFAULT '0',
  `views` int(11) NOT NULL DEFAULT '0',
  `sharableWith` varchar(1024) NOT NULL,
  PRIMARY KEY (`_id`),
  KEY `FK_revisions_articles` (`articleId`),
  CONSTRAINT `FK_revisions_articles` FOREIGN KEY (`articleId`) REFERENCES `articles` (`_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
