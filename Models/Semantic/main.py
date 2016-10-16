import time,graph
import sys


def run():
    f=open(sys.argv[2])
    kwLimit = 100000
    #ncoms=80
    dispth=0.06
    ethunit=4.5e-5
    task = sys.argv[1]
    for years in f.readlines():
        #currentyears = years.decode('utf-8').replace('\n','').split(";")
        currentyears = years.replace('\n','').split(";")
        print(currentyears)
        if task == '--graph' :
            graph.construct_graph(currentyears,kwLimit)
        if task == '--probas' :
            graph.export_probas_matrices(currentyears,kwLimit,dispth,ethunit)
        if task == '--custom' :
            #graph.export_filtered_graphs(currentyears,kwLimit,dispth,ethunit)
            graph.export_kws_with_attrs(currentyears,kwLimit,dispth,ethunit)


def main():

        start = time.time()

        run()

        print('Ellapsed Time : '+str(time.time() - start))


main()
