 

INSERT INTO subscriber (username, domain, password, ha1, ha1b) VALUES
  (
    '1003',
    'kamailio.local',
    'password1003',
    MD5(CONCAT('1003', ':', 'kamailio.local', ':', 'password1003')),
    MD5(CONCAT('1003', '@', 'kamailio.local', ':', 'kamailio.local', ':', 'password1003'))
  )
ON DUPLICATE KEY UPDATE
  password = VALUES(password),
  ha1 = VALUES(ha1),
  ha1b = VALUES(ha1b);

SELECT id, username, domain, password FROM subscriber ORDER BY username;
