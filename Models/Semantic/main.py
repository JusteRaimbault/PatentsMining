import time,sys
import relevant,graph,postprocessing,utils


def run():
    task = sys.argv[1]
    f=open(sys.argv[2])

    # parameters
    kwLimit = utils.get_parameter('kwLimit')
    edge_th = utils.get_parameter('edge_th')
    dispth=utils.get_parameter('dispth')
    ethunit=utils.get_parameter('ethunit')

    for years in f.readlines():
        currentyears = years.replace('\n','').split(";")
        print('--> running '+task+'for'+str(currentyears))
        if task=='--raw-network':
            # keywords relevance
            relevant.relevant_full_corpus(currentyears,kwLimit,edge_th)
            # full network
            graph.construct_graph(currentyears,kwLimit,edge_th)
            # sensitivity
            graph.sensitivity(currentyears,kwLimit,edge_th)

        if task == '--classification' :
            # construct communities
            graph.construct_communities(currentyears,kwLimit,edge_th,dispth,ethunit)
            # post processing
            postprocessing.export_classification(currentyears,kwLimit,edge_th,dispth,ethunit)

        if task == '--custom' :
            print("custom")

def main():

        start = time.time()

        run()

        print('Ellapsed Time : '+str(time.time() - start))


main()
