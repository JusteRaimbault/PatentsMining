
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
    window=utils.get_parameter('window-size')
    for year in range(1980,2013):
	print(year)
        years=map(lambda y:str(y),range(int(year-window+1),int(year+1)))
        patents = mongo['patent']['keywords'].find({"app_year":{"$in":years}},no_cursor_timeout=True)
        npatents = patents.count()
        yearrange = str(years[0])+"-"+str(years[len(years)-1])
        data.append([yearrange,npatents])
    utils.export_csv(data,'data/patentcount_window'+str(window)+'.csv',";","yearrange;count")

#npatent_years()
