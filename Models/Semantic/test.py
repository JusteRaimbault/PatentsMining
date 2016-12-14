
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
    window=int(utils.get_parameter('window-size'))
    for year in range(1976+window-1,2013):
	print(year)
        years=map(lambda y:str(y),range(int(year-window+1),int(year+1)))
        patents = mongo['patent']['keywords'].find({"app_year":{"$in":years}},no_cursor_timeout=True)
        npatents = patents.count()
        yearrange = str(years[0])+"-"+str(years[len(years)-1])
        data.append([yearrange,npatents])
    utils.export_csv(data,'data/patentcount_window'+str(window)+'.csv',";","yearrange;count")

def test_patent_measure():
    mongo = pymongo.MongoClient(utils.get_parameter('mongopath',True,True))
    years = ['1976','1977','1978','1979','1980']
    patents = mongo['patent']['keywords'].find({"app_year":{"$in":years}},no_cursor_timeout=True)
    measures=[]
    nmeasures = 10# len(kwattrsdico[graph.vs['name'][0]])
    i=0
    for currentpatent in patents:
        #if i%10000==0 : print('patent measures : '+str(100*i/npatents))
        print('patent measures : '+currentpatent['id'])#+' : '+str(100*i/npatents))
        currentmeasures = [0.0]*nmeasures
        kwnum=0
        for kw in currentpatent['keywords']:
            print(kw)
	    #if kw in kwattrsdico :
                #currentmeasures = [currentmeasures[i]+kwattrsdico[kw][i] for i in range(len(currentmeasures))]
            #    kwnum=kwnum+1
        nk=len(currentpatent['keywords'])
        if sum(currentmeasures)!=0 :
            measures.append([currentpatent['id'],nk,kwnum]+currentmeasures)
        i=i+1


npatent_years()
#test_patent_measure()
