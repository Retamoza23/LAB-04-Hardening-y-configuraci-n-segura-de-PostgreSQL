
SHOW password_encryption;

SHOW max_connections;
SHOW statement_timeout;
SHOW idle_in_transaction_session_timeout;

SELECT
    pid,
    usename,
    client_addr,
    ssl,
    version,
    cipher
FROM pg_stat_ssl;

SELECT
    rolname,
    rolsuper,
    rolcreaterole,
    rolcreatedb,
    rolcanlogin
FROM pg_roles
WHERE rolsuper = TRUE OR rolcreaterole = TRUE;