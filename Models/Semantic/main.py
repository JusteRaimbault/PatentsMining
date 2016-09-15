import time,graph
import sys


def run():
    f=open(sys.argv[2])
    kwLimit = 100000
    ncoms=80
    task = sys.argv[1]
    for years in f.readlines():
        #currentyears = years.decode('utf-8').replace('\n','').split(";")
        currentyears = years.replace('\n','').split(";")
        print(currentyears)
        if task == '--graph' :
            graph.construct_graph(currentyears,kwLimit)
        if task == '--probas' :
            graph.export_probas_matrices(currentyears,kwLimit,ncoms)



def main():

        start = time.time()

        run()

        print('Ellapsed Time : '+str(time.time() - start))


main()
