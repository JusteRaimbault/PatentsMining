import pymongo,pickle
from igraph import *

# post classification operations



##
#
def export_kws_with_attrs(years,kwLimit,dispth,ethunit):
    # load the graph
    yearrange = years[0]+"-"+years[len(years)-1]
    currentgraph=pickle.load(open('pickled/filteredgraph_'+yearrange+'_'+str(kwLimit)+'_eth10_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.pkl','rb'))

    # load old kws from csv
    #
    keywords = utils.import_csv('probas_count/keywords-counts_'+yearrange+'_kwLimit'+str(kwLimit)+'_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.csv',';')

    degree = currentgraph.degree(range(currentgraph.vcount()))
    evcentrality = currentgraph.eigenvector_centrality(weights='weight')
    bcentrality = currentgraph.betweenness(weights='weight')
    ccentrality = currentgraph.closeness(weights='weight')
    weighteddegree = currentgraph.strength(range(currentgraph.vcount()),weights='weight')

    # reconstruct communities (!! repro test)
    #com = currentgraph.community_multilevel(weights="weight",return_levels=True)
    #membership = com[len(com)-1].membership
    dico = {}
    for n in range(currentgraph.vcount()):
        dico[currentgraph.vs['name'][n]] = [currentgraph.vs['tfidf'][n],currentgraph.vs['disp'][n],currentgraph.vs['docfreq'][n],currentgraph.vs['termhood'][n],degree[n],weighteddegree[n],bcentrality[n],ccentrality[n],evcentrality[n]]
    ##  !! export of dico is shuffled, but same words same communities
    #utils.export_dico_csv(dico,'probas/test-'+yearrange+'.csv',';')

    res = []
    for row in keywords :
        currentkw = row[0]
        # small discrepancy in count -> small number of kws were not exported ?
        if currentkw in dico :
            res.append(row + dico[currentkw])

    # export
    utils.export_csv(res,'probas/keywords-count-extended_'+yearrange+'_kwLimit'+str(kwLimit)+'_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.csv',';','keyword;community;tfidf;technodispersion;docfreq;termhood;degree;weighteddegree;betweennesscentrality;closenesscentrality;eigenvectorcentrality')






##
#  construct patent probas at a given clustering level
def export_probas_matrices(years,kwLimit,dispth,ethunit):
    print("Constructing patent probas for years "+str(years))
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    # load keywords
    patents = mongo['patent']['keywords'].find({"year":{"$in":years}},no_cursor_timeout=True)
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





##
#   Associate to patent graph measures computed through weighted average of keywords network measures
def export_patent_measures(years,kwLimit,dispth,ethunit):
    print("Constructing patent measures for years "+str(years))
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    # load keywords
    patents = mongo['patent']['keywords'].find({"year":{"$in":years}},no_cursor_timeout=True)
    npatents = patents.count()
    yearrange = years[0]+"-"+years[len(years)-1]

    keywords = utils.import_csv('probas_count_extended/keywords-counts-extended_'+yearrange+'_kwLimit'+str(kwLimit)+'_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.csv',';')
    header = keywords[0]

    #construct dico kw -> measures
    dico = {}
    for row in [keywords[i] for i in range(1,len(keywords))]:
        dico[row[0]] = [float(row[i]) for i in range(2,len(row))]

    nmeasures = len(header)-2 # remove community number
    measures = []

    i=0
    for currentpatent in patents:
        if i%10000==0 : print(100*i/npatents)
        currentmeasures = [0.0]*nmeasures
        for kw in currentpatent['keywords']:
            if kw in dico :
                currentmeasures = [currentmeasures[i]+dico[kw][i] for i in range(len(currentmeasures))]
        nk=len(currentpatent['keywords'])
        currentmeasures = list(map(lambda x: x /nk,currentmeasures))
        if sum(currentmeasures)>0 :
            measures.append([currentpatent['id']]+currentmeasures)
        i=i+1

    patents.close()

    utils.export_csv(measures,'probas/patent-measures_'+yearrange+'_kwLimit'+str(kwLimit)+'_dispth'+str(dispth)+'_ethunit'+str(ethunit)+'.csv',';','patent;tfidf;technodispersion;docfreq;termhood;degree;weighteddegree;betweennesscentrality;closenesscentrality;eigenvectorcentrality')
