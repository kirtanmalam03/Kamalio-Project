
 
USE kamailio;

CREATE TABLE IF NOT EXISTS version (
  table_name VARCHAR(32) NOT NULL,
  table_version INT UNSIGNED NOT NULL DEFAULT 0,
  CONSTRAINT table_name_idx UNIQUE (table_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO version (table_name, table_version) VALUES
  ('subscriber', 7),
  ('location', 9)
ON DUPLICATE KEY UPDATE table_version = VALUES(table_version);

CREATE TABLE IF NOT EXISTS subscriber (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(64) NOT NULL DEFAULT '',
  domain VARCHAR(64) NOT NULL DEFAULT '',
  password VARCHAR(64) NOT NULL DEFAULT '',
  ha1 VARCHAR(128) NOT NULL DEFAULT '',
  ha1b VARCHAR(128) NOT NULL DEFAULT '',
  email_address VARCHAR(128) DEFAULT NULL,
  rpid VARCHAR(128) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY account_idx (username, domain),
  KEY username_idx (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS location (
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  ruid VARCHAR(64) NOT NULL DEFAULT '',
  username VARCHAR(64) NOT NULL DEFAULT '',
  domain VARCHAR(64) DEFAULT NULL,
  contact VARCHAR(512) NOT NULL DEFAULT '',
  received VARCHAR(128) DEFAULT NULL,
  path VARCHAR(512) DEFAULT NULL,
  expires DATETIME NOT NULL DEFAULT '2030-05-28 21:32:15',
  q FLOAT(10,2) NOT NULL DEFAULT 1.00,
  callid VARCHAR(255) NOT NULL DEFAULT 'Default-Call-ID',
  cseq INT(11) NOT NULL DEFAULT 1,
  last_modified DATETIME NOT NULL DEFAULT '2000-01-01 00:00:01',
  flags INT(11) NOT NULL DEFAULT 0,
  cflags INT(11) NOT NULL DEFAULT 0,
  user_agent VARCHAR(255) NOT NULL DEFAULT '',
  socket VARCHAR(64) DEFAULT NULL,
  methods INT(11) DEFAULT NULL,
  instance VARCHAR(255) DEFAULT NULL,
  reg_id INT(11) NOT NULL DEFAULT 0,
  server_id INT(11) NOT NULL DEFAULT 0,
  connection_id INT(11) NOT NULL DEFAULT 0,
  keepalive INT(11) NOT NULL DEFAULT 0,
  `partition` INT(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY ruid_idx (ruid),
  KEY account_contact_idx (username, domain, contact),
  KEY expires_idx (expires)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO subscriber (username, domain, password, ha1, ha1b) VALUES
  (
    '1001',
    'kamailio.local',
    'password1001',
    MD5(CONCAT('1001', ':', 'kamailio.local', ':', 'password1001')),
    MD5(CONCAT('1001', '@', 'kamailio.local', ':', 'kamailio.local', ':', 'password1001'))
  ),
  (
    '1002',
    'kamailio.local',
    'password1002',
    MD5(CONCAT('1002', ':', 'kamailio.local', ':', 'password1002')),
    MD5(CONCAT('1002', '@', 'kamailio.local', ':', 'kamailio.local', ':', 'password1002'))
  )
ON DUPLICATE KEY UPDATE
  password = VALUES(password),
  ha1 = VALUES(ha1),
  ha1b = VALUES(ha1b);

SELECT id, username, domain FROM subscriber;
