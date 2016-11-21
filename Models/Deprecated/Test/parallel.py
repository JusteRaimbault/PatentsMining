
# test python multiprocessing

from multiprocessing import Pool
import math,time

def f(x):
    return(math.sqrt(x)*math.cos(x))

start = time.time()

pool = Pool(4)
#print(pool.map(f,range(1000000)))
res = map(f,range(100000000))
#res = pool.map(f,range(10000000))

print('Ellapsed Time : '+str(time.time() - start))
