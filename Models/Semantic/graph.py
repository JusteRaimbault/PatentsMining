
import pymongo,pickle,math
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
    #coms = gg.community_fastgreedy(weights="weight")

    # save everything
    pickle.dump(gf,open('pickled/graph_'+yearstr+'_'+str(kwLimit)+'_eth10.pkl','wb'))
    #pickle.dump(coms,open('pickled/coms_'+yearstr+'_'+str(kwLimit)+'_eth10.pkl','wb'))



def dispersion(x):
    s=sum(x)
    return(sum(list(map(lambda y:(y/s)*(y/s),x))))


##
#  construct filtered graph
def filtered_graph(yearrange,kwLimit,dispth,eth,mongo):
    graph=pickle.load(open('pickled/graph_'+yearrange+'_'+str(kwLimit)+'_eth10.pkl','rb'))
    kwstechno = list(mongo['keywords']['techno'].find({'keyword':{'$in':graph.vs['name']}}))
    disps = list(map(lambda d:(d['keyword'],len(d.keys())-1,dispersion([float(d[k]) for k in d.keys() if k!='keyword'and k!='_id'])),kwstechno))
    disp_dico={}
    for disp in disps :
        disp_dico[disp[0]]=disp[2]
    disp_list=[]
    for name in graph.vs['name']:
        disp_list.append(disp_dico[name])
    graph.vs['disp']=disp_list
    graph=graph.subgraph([i for i, d in enumerate(graph.vs['disp']) if d > dispth])
    graph.delete_edges([i for i, w in enumerate(graph.es['weight']) if w<eth])
    dd = graph.degree(range(graph.vcount()))
    graph=graph.subgraph([i for i, d in enumerate(dd) if d > 0])
    return(graph)


##
# load additional vertex attributes
def filtered_graph_with_attributes(yearrange,kwLimit,dispth,eth,mongo):
    currentgraph = filtered_graph(yearrange,kwLimit,dispth,eth,mongo)
    #
    vertices = mongo['relevant']['relevant_'+yearrange+'_full_100000'].find()
    nvertices = vertices.count()
    # dico kw -> vertex in mongo
    dico = {}
    for currentvertex in vertices:
        dico[currentvertex['keyword']]=currentvertex
    tfidf = [];docf = [];termhood = []
    for name in currentgraph.vs['name']:
        attrs = dico[name]
        tfidf.append(attrs['tidf']);docf.append(attrs['docfrequency']);termhood.append(attrs['cumtermhood'])
    currentgraph.vs['tfidf']=tfidf
    currentgraph.vs['docfreq']=docf
    currentgraph.vs['termhood']=termhood
    return(currentgraph)


##
#  get multilevel communities
def get_communities(yearrange,kwLimit,dispth,eth,mongo):
    print("Constructing communities : "+yearrange+" ; "+str(dispth)+" ; "+str(eth))
    graph = filtered_graph(yearrange,kwLimit,dispth,eth,mongo)
    com = graph.community_multilevel(weights="weight",return_levels=True)
    return([graph,com[len(com)-1]])


##
#  pickle filtered graphs with attributes
def export_filtered_graphs(years,kwLimit,dispth,ethunit):
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    patents = mongo['patent']['keywords'].find({"app_year":{"$in":years}},no_cursor_timeout=True)
    npatents = patents.count()
    yearrange = years[0]+"-"+years[len(years)-1]
    currentgraph=filtered_graph_with_attributes(yearrange,kwLimit,dispth,math.floor(ethunit*npatents),mongo)
    pickle.dump(currentgraph,open('pickled/filteredgraph_'+yearrange+'_'+str(kwLimit)+'_eth10_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.pkl','wb'))

    
##
# 
def export_kws_with_attrs(years,kwLimit,dispth,ethunit):
    # load the graph
    yearrange = years[0]+"-"+years[len(years)-1]
    currentgraph=pickle.load(open('pickled/filteredgraph_'+yearrange+'_'+str(kwLimit)+'_eth10_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.pkl','rb'))
    # reconstruct communities (!! repro test)
    com = currentgraph.community_multilevel(weights="weight",return_levels=True)
    membership = com[len(com)-1].membership
    dico = {}
    for n in range(currentgraph.vcount()):
        dico[currentgraph.vs['name'][n]] = [membership[n],currentgraph.vs['tfidf'][n],currentgraph.vs['docfreq'][n],currentgraph.vs['termhood'][n]]
    ##  !! export of dico is shuffled, but same words same communities
    utils.export_dico_csv(dico,'probas/test-'+yearrange+'.csv',';')
    
        
##
#  construct patent probas at a given clustering level
def export_probas_matrices(years,kwLimit,dispth,ethunit):
    print("Constructing patent probas for years "+str(years))
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    # load keywords
    patents = mongo['patent']['keywords'].find({"app_year":{"$in":years}},no_cursor_timeout=True)
    npatents = patents.count()
    yearrange = years[0]+"-"+years[len(years)-1]
    # load graph and construct communities
    [graph,clustering]=get_communities(yearrange,kwLimit,dispth,math.floor(ethunit*npatents),mongo)

    #construct dico kw -> community
    dico = {}
    for n in range(graph.vcount()):
        name = graph.vs['name'][n]
        dico[name] = clustering.membership[n]

    ncommunities = len(clustering.sizes())
    probas = [] #([0.0]*n)*k
    rownames = []
    counts = []
    
    i=0
    for currentpatent in patents:
        if i%10000==0 : print(100*i/npatents)
        #currentpatent = patents.next()
        currentprobas = [0.0]*ncommunities
        for kw in currentpatent['keywords']:
            if kw in dico :
                currentprobas[dico[kw]]=currentprobas[dico[kw]]+1
            nk=len(currentpatent['keywords'])
        #currentprobas = list(map(lambda x: x /nk,currentprobas))
        if sum(currentprobas)>0 :
            probas.append(currentprobas)
            rownames.append(currentpatent['id'])
            counts.append(nk)
        i=i+1

    patents.close()

    # export the matrix proba as csv
    utils.export_matrix_sparse_csv(probas,[rownames,counts],'probas/counts_'+yearrange+'_kwLimit'+str(kwLimit)+'_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.csv',";")

    # export the kw;com dico as csv
    utils.export_dico_csv(dico,'probas/keywords-counts_'+yearrange+'_kwLimit'+str(kwLimit)+'_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.csv',";")
