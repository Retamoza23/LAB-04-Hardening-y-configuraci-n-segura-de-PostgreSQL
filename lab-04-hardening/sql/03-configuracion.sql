
ALTER SYSTEM SET password_encryption = 'scram-sha-256';


ALTER SYSTEM SET max_connections = '100';
ALTER SYSTEM SET superuser_reserved_connections = '3';
ALTER SYSTEM SET statement_timeout = '30000'; 
ALTER SYSTEM SET idle_in_transaction_session_timeout = '60000'; 


SELECT pg_reload_conf();