CREATE TABLE IF NOT EXISTS `zp_players` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `nick` varchar(32) character set utf8 NOT NULL,
  `ip` varchar(32) character set utf8 NOT NULL,
  `steam_id` varchar(32) character set utf8 NOT NULL,
  `last_leave` int(10) unsigned NOT NULL default '0',
  `first_zombie` int(11) NOT NULL default '0',
  `infect` int(11) NOT NULL default '0',
  `zombiekills` int(11) NOT NULL default '0',
  `humankills` int(11) NOT NULL default '0',
  `suicide` int(11) NOT NULL default '0',
  `death` int(11) NOT NULL default '0',
  `infected` int(11) NOT NULL default '0',
  PRIMARY KEY  (`id`),
  KEY `nick` (`nick`,`ip`,`steam_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8;
