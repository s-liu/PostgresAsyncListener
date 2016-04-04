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
DECLARE
	row RECORD;
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    	row = NEW;
  	ELSE
    	row = OLD;
  	END IF;
	PERFORM pg_notify('$channel', json_build_object('table', TG_TABLE_NAME, 'type', TG_OP, 'row', row_to_json(row))::text);
	return NEW;
END;
\$notify_trigger\$ LANGUAGE plpgsql;

CREATE TRIGGER notify_trigger AFTER INSERT OR UPDATE OR DELETE ON test_table_1
	FOR EACH ROW EXECUTE PROCEDURE notify_trigger();
CREATE TRIGGER notify_trigger AFTER INSERT OR UPDATE OR DELETE ON test_table_2
	FOR EACH ROW EXECUTE PROCEDURE notify_trigger();
EOF
