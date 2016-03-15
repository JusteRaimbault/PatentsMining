import sqlite3,time

conn = sqlite3.connect('bootstrap/run_year2005_limit-1_kw2000_csize20000_b10_runs10/bootstrap.sqlite3')
c = conn.cursor()
c.execute('PRAGMA locking_mode = EXCLUSIVE')
c.execute('BEGIN EXCLUSIVE')

while True :
    time.sleep(5000)
    c.execute('COMMIT')



