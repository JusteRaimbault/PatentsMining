import pymongo,pickle,os
from igraph import *
import graph,utils

# post classification operations




##
#  construct patent probas at a given clustering level
def export_classification(years,kwLimit,min_edge_th,dispth,ethunit):
    resdir='classification/classification_window'+str(int(years[len(years)-1])-int(years[0])+1)+'_kwLimit'+str(int(kwLimit))+'_dispth'+str(dispth)+'_ethunit'+str(ethunit)
    try :
	os.makedirs(resdir)
    except :
	print("res dir exists")

    print("Constructing patent probas for years "+str(years))

    mongo = pymongo.MongoClient(utils.get_parameter('mongopath',True,True))
    # load keywords
    patents = mongo['patent']['keywords'].find({"app_year":{"$in":years}},no_cursor_timeout=True)
    npatents = patents.count()
    yearrange = years[0]+"-"+years[len(years)-1]
    # load graph and construct communities
    [graph,coms]=pickle.load(open('pickled/filteredgraphcoms_'+yearrange+'_'+str(kwLimit)+'_eth'+str(min_edge_th)+'_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.pkl','rb'))
    # best clustering in com[len(com)-1]
    clustering = coms[len(coms)-1]

    #construct dico kw -> community
    dico = {}
    for n in range(graph.vcount()):
        name = graph.vs['name'][n]
        dico[name] = clustering.membership[n]

    ncommunities = len(clustering.sizes())
    probas = []
    rownames = []
    counts = []

    i=0
    for currentpatent in patents:
        if i%10000==0 : print('probas : '+str(100*i/npatents))
        #currentpatent = patents.next()
        currentprobas = [0.0]*ncommunities
        for kw in currentpatent['keywords']:
            if kw in dico :
                currentprobas[dico[kw]]=currentprobas[dico[kw]]+1
            nk=len(currentpatent['keywords'])
        if sum(currentprobas)>0 :
            probas.append(currentprobas)
            rownames.append(currentpatent['id'])
            counts.append(nk)
        i=i+1

    # export the matrix proba as csv
    utils.export_matrix_sparse_csv(probas,[rownames,counts],resdir+'/probas_'+yearrange+'_kwLimit'+str(kwLimit)+'_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.csv',";")


    # add attributes to keywords
    degree = graph.degree(range(graph.vcount()))
    evcentrality = graph.eigenvector_centrality(weights='weight')
    bcentrality = graph.betweenness(weights='weight')
    ccentrality = graph.closeness(weights='weight')
    weighteddegree = graph.strength(range(graph.vcount()),weights='weight')

    kwattrsdico={}
    for n in range(graph.vcount()):
        kwattrsdico[graph.vs['name'][n]] = [graph.vs['tidf'][n],graph.vs['disp'][n],graph.vs['docfreq'][n],graph.vs['termhood'][n],degree[n],weighteddegree[n],bcentrality[n],ccentrality[n],evcentrality[n]]

    kwdata = []
    for currentkw in dico.keys() :
        if currentkw in kwattrsdico :
            kwdata.append([currentkw,dico[currentkw]] + kwattrsdico[currentkw])

    # export keywords as csv
    utils.export_csv(kwdata,resdir+'/keywords_'+yearrange+'_kwLimit'+str(kwLimit)+'_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.csv',';','keyword;community;tidf;technodispersion;docfreq;termhood;degree;weighteddegree;betweennesscentrality;closenesscentrality;eigenvectorcentrality')


    # Patent measures
    patents = mongo['patent']['keywords'].find({"app_year":{"$in":years}},no_cursor_timeout=True)
    measures=[]
    nmeasures = len(kwattrsdico[graph.vs['name'][0]])
    i=0
    for currentpatent in patents:
        #if i%10000==0 : print('patent measures : '+str(100*i/npatents))
        print('patent measures : '+str(100*i/npatents))
        currentmeasures = [0.0]*nmeasures
        kwnum=0
        for kw in currentpatent['keywords']:
            if kw in kwattrsdico :
                currentmeasures = [currentmeasures[i]+kwattrsdico[kw][i] for i in range(len(currentmeasures))]
                kwnum=kwnum+1
        nk=len(currentpatent['keywords'])
        if sum(currentmeasures)!=0 :
            measures.append([currentpatent['id'],nk,kwnum]+currentmeasures)
        i=i+1

    # export measures

    utils.export_csv(measures,resdir+'/patent_'+yearrange+'_kwLimit'+str(kwLimit)+'_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.csv',';','patent;kws;classkws;tidf;technodispersion;docfreq;termhood;degree;weighteddegree;betweennesscentrality;closenesscentrality;eigenvectorcentrality')
