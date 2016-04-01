# PostgresAsyncListener

## To Run
Run `./init_test_db` to set a test database with tables

Run `python async_listener.py` to run the listener process


`psql mytestdb`

Insert values to test_table_1 and test_table_2.

Watch the listener process catch the updates.

## Table schemas
test_table_1 ( msg text )

test_table_2 ( id int, msg text )
