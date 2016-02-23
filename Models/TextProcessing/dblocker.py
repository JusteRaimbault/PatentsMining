import sqlite3,time

conn = sqlite3.connect('bootstrap/run_kw1000_csize2000_b20/bootstrap.sqlite3')
c = conn.cursor()
c.execute('PRAGMA locking_mode = EXCLUSIVE')
c.execute('BEGIN EXCLUSIVE')

while True :
    time.sleep(5000)
    c.execute('COMMIT')



