
# tests

import pymongo,pickle
from igraph import *
import graph,utils


def test_construct_graph() :
    years = ['1976','1977','1978','1979','1980']
    kwLimit=100000.0
    min_edge_th=10.0

    graph.construct_graph(years,kwLimit,min_edge_th)


def npatent_years():
    mongo = pymongo.MongoClient(utils.get_parameter('mongopath',True,True))
    data = []
    for year in range(1980,2013):
        years=range()
        patents = mongo['patent']['keywords'].find({"app_year":{"$in":years}},no_cursor_timeout=True)
        npatents = patents.count()
        yearrange = years[0]+"-"+years[len(years)-1]
        data.append([yearrange,npatents])
    window=utils.get_parameter('window-size')
    utils.export_csv(data,'data/patentcount_window'+str(window)+'.csv',";","yearrange;count")

npatent_years()
