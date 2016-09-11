import time,graph
import sys


def run():
    f=open(sys.argv[1])
    kwLimit = 100000
    for years in f.readlines():
        currentyears = years.decode('utf-8').replace('\n','').split(";")
        print currentyears
        graph.construct_graph(print currentyears,kwLimit)




def main():

        start = time.time()

        run()

        print('Ellapsed Time : '+str(time.time() - start))


main()
