
import pymongo,pickle
#import igraph
from igraph import *

##
# construct graph and dendogram communities, store in pickle
def construct_graph(years,kwLimit):
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    database = mongo['relevant']
    # get edges
    yearstr = str(years[0])+'-'+str(years[len(years)-1])
    edges = database['network_'+yearstr+'_full_'+str(kwLimit)+'_eth10'].find()
    n=edges.count()

    # construct edgelist
    edgelist = [None]*n
    for i in range(n):
        edge = edges.next()
        v=edge['edge'].split(';')
        edgelist[i]=(v[0],v[1],edge['weight'])

    # construct graph
    g = Graph.TupleList(edgelist,edge_attrs=["weight"])

    # simplify
    gg=g.simplify(combine_edges="first")

    # filter
    filt = open('data/filter.csv','rb').readlines()
    toremove=set()
    for f in filt:
        r = f.decode('utf-8').replace('\n','')
        if r in gg.vs['name']:
            toremove.add(gg.vs['name'].index(r))
    ids = list(set(range(len(gg.vs['name']))) - toremove)

    gf = gg.subgraph(ids)

    # get communities
    coms = gg.community_fastgreedy(weights="weight")

    # save everything
    pickle.dump(gf,open('pickled/graph_'+yearstr+'_'+str(kwLimit)+'_eth10.pkl','wb'))
    pickle.dump(coms,open('pickled/coms_'+yearstr+'_'+str(kwLimit)+'_eth10.pkl','wb'))
