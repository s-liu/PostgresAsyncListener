#!/bin/sh
dbname='mytestdb'
channel='channel'

dropdb $dbname
createdb $dbname
psql $dbname << EOF

CREATE TABLE test_table_1 (
	msg text
);
CREATE TABLE test_table_2 (
	id int,
	msg text
);

CREATE FUNCTION notify_trigger() RETURNS trigger AS \$notify_trigger\$
BEGIN
	PERFORM pg_notify('$channel', CAST(NEW AS text));
	return NEW;
END;
\$notify_trigger\$ LANGUAGE plpgsql;

CREATE TRIGGER notify_trigger AFTER INSERT OR UPDATE OR DELETE ON test_table_1
	FOR EACH ROW EXECUTE PROCEDURE notify_trigger();
CREATE TRIGGER notify_trigger AFTER INSERT OR UPDATE OR DELETE ON test_table_2
	FOR EACH ROW EXECUTE PROCEDURE notify_trigger();
EOF
