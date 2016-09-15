
import pymongo,pickle
#import igraph
from igraph import *
import utils

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


##
#  construct patent probas at a given clustering level
def export_probas_matrices(years,kwLimit,ncoms):
    print("Constructing patent probas for years "+str(years))
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    # load keywords
    patents = mongo['patent']['keywords'].find({"app_year":{"$in":years}})
    npatents = patents.count()

    # load graph and communities
    yearrange = years[0]+"-"+years[len(years)-1]
    graph=pickle.load(open('pickled/graph_'+yearrange+'_'+str(kwLimit)+'_eth10.pkl','rb'))
    coms=pickle.load(open('pickled/coms_'+yearrange+'_'+str(kwLimit)+'_eth10.pkl','rb'))

    # clustering
    clustering = coms.as_clustering(ncoms)

    #construct dico kw -> community
    dico = {}
    for n in range(graph.vcount()):
        name = graph.vs['name'][n]
        dico[name] = clustering.membership[n]

    probas = [] #([0.0]*n)*k
    rownames = []

    for i in range(1000):#npatents):
        if i%10000==0 : print(100*i/npatents)
        currentpatent = patents.next()
        currentprobas = [0.0]*n
        for kw in currentpatent['keywords']:
            if kw in dico :
                currentprobas[dico[kw]]=currentprobas[dico[kw]]+1
            nk=len(currentpatent['keywords'])
        currentprobas = list(map(lambda x: x /nk,currentprobas))
        probas.append(currentprobas)
        rownames.append(currentpatent['id'])

    # export the matrix proba as csv
    utils.export_matrix_csv(probas,rownames,'probas/probas_'+yearrange+'_ncoms'+str(ncoms)+'_kwLimit'+kwLimit+'.csv',";")

    # export the kw;com dico as csv
    utils.export_dico_csv(dico,'probas/keywords_'+yearrange+'_ncoms'+str(ncoms)+'_kwLimit'+kwLimit+'.csv',";")
