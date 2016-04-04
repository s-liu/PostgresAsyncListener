import sys

dbname = 'mytestdb'
host = 'localhost'
user = 'xiaochen'
password = ''

dsn = 'dbname=%s host=%s user=%s password=%s' % (dbname, host, user, password)

class AsyncListner():

    def __init__(self, dsn):
        import psycopg2
        self.conn = psycopg2.connect(dsn)
        self.conn.set_isolation_level(0)
        self.curs = self.conn.cursor()
        self._listening = False

    def _listen(self):
        print 'start listening...'
        from select import select
        while True:
            if select([self.conn],[],[],60) != ([],[],[]):
                self.conn.poll()
                while self.curs.connection.notifies:
                    notify = self.curs.connection.notifies.pop()
                    self.gotNotify(notify)

    def addNotify(self, channel):
        sql = "LISTEN %s" % channel
        self.curs.execute(sql)

    def removeNotify(self, channel):
        sql = "UNLISTEN %s" % channel
        self.curs.execute(sql)

    def run(self):
        self._listen()

    def gotNotify(self, notify):
        print 'Gotcha!'
        if notify.payload:
            print notify.payload

if __name__ == '__main__':
    channels = sys.argv[1:]
    print 'initializing async listener'
    listener = AsyncListner(dsn)
    listener.addNotify('channel')
    for channel in channels:
        print 'subscribing to', channel
        listener.addNotify(channel)
    print 'done subscribing!'
    listener.run()
