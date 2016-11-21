
import pymongo,pickle,math,numpy
from igraph import *
import utils


##
# construct graph, store in pickle
def construct_graph(years,kwLimit,min_edge_th):
    mongo = pymongo.MongoClient(utils.get_parameter('mongopath',True,True))
    database = mongo['relevant']
    # get edges
    yearstr = str(years[0])+'-'+str(years[len(years)-1])
    edges = database['network_'+yearstr+'_full_'+str(kwLimit)+'_eth'+str(min_edge_th)].find()
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

    # add attributes
    vertices = mongo['relevant']['relevant_'+yearrange+'_full_'+str(kwLimit)].find()
    nvertices = vertices.count()
    # dico kw -> vertex in mongo
    dico = {}
    for currentvertex in vertices:
        dico[currentvertex['keyword']]=currentvertex
    tidf = [];docf = [];termhood = []
    for name in gf.vs['name']:
        attrs = dico[name]
        tidf.append(attrs['tidf']);docf.append(attrs['docfrequency']);termhood.append(attrs['cumtermhood'])
    gf.vs['tidf']=tidf
    gf.vs['docfreq']=docf
    gf.vs['termhood']=termhood

    # save everything
    pickle.dump(gf,open('pickled/graph_'+yearstr+'_'+str(kwLimit)+'_eth'+str(min_edge_th)+'.pkl','wb'))



##
#  sensitivity analysis
def sensitivity(years,kwLimit,min_edge_th) :
    print('Sensitivity analysis for years '+str(years))
    yearrange = years[0]+"-"+years[len(years)-1]
    graph=pickle.load(open('pickled/graph_'+yearrange+'_'+str(kwLimit)+'_eth'+str(min_edge_th)+'.pkl','rb'))

    dthvals=numpy.arange(0.01,0.12,0.005)
    ethvals=numpy.arange(10,200,5)
    #mincomsizevals=[0,4,10] # remove min com size, additional filtering does not makes really sense

    res = []
    for dth in dthvals:
        for eth in ethvals:
            print('eth = '+str(eth)+' ; dth = '+str(dth))
            [fgraph,coms]=get_communities(graph,dth,eth)
            for i in range(len(coms)):
                comnum = len(coms[i].sizes())
                vcount = fgraph.vcount()
                modularity = coms[i].modularity
                res.append([dth,eth,comnum,vcount,modularity])
    # export res
    export_csv(res,'sensitivity/sensitivity_'+yearrange+'_'+str(kwLimit)+'_eth'+str(min_edge_th)+'.csv',";","dispth;eth;comnum;vcount;modularity")





##
#  Dispersion index
#  d = \sum (k_j / sum k_j) ^ 2
def dispersion(x):
    s=sum(x)
    return(sum(list(map(lambda y:(y/s)*(y/s),x))))


##
#  construct filtered graph
#  requires pickled full networks constructed
def filtered_graph(graph,dispth,eth):
    mongo = pymongo.MongoClient(utils.get_parameter('mongopath',True,True))
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
#  get multilevel communities
def get_communities(yearrange,kwLimit,min_edge_th,dispth,eth):
    print("Constructing communities : "+yearrange+" ; "+str(dispth)+" ; "+str(eth))
    graph = filtered_graph(yearrange,kwLimit,min_edge_th,dispth,eth)
    com = graph.community_multilevel(weights="weight",return_levels=True)
    return([graph,com])


##
#  pickle filtered graphs and communities
def construct_communities(years,kwLimit,min_edge_th,dispth,ethunit):
    mongo = pymongo.MongoClient(utils.get_parameter('mongopath',True,True))
    patents = mongo['patent']['keywords'].find({"app_year":{"$in":years}},no_cursor_timeout=True)
    npatents = patents.count()
    yearrange = years[0]+"-"+years[len(years)-1]

    graph=pickle.load(open('pickled/graph_'+yearrange+'_'+str(kwLimit)+'_eth'+str(min_edge_th)+'.pkl','rb'))

    currentgraphcoms=get_communities(graph,dispth,math.floor(ethunit*npatents))
    pickle.dump(currentgraphcoms,open('pickled/filteredgraphcoms_'+yearrange+'_'+str(kwLimit)+'_eth'+str(min_edge_th)+'_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.pkl','wb'))
    # TODO add a gml export for convenience
