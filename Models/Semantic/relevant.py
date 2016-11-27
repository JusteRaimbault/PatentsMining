

## Keywords relevance estimation
import math,pymongo,functools
import data,utils


##
#  Estimate relevance
def relevant_full_corpus(years,kwLimit,edge_th):
    dbdata = 'patent'
    coldata = 'keywords'
    coldico = 'keywords'
    dbrelevant = 'relevant'
    corpus = data.get_patent_data(dbdata,coldata,years,"app_year",-1,full=False)
    occurence_dicos = data.import_kw_dico(dbdata,coldico,years,"app_year")
    print('corpus : '+str(len(corpus))+' ; dico : '+str(len(occurence_dicos[0]))+' , '+str(len(occurence_dicos[1])))
    if len(corpus) > 0 and len(occurence_dicos) > 0 :
        relevant = 'relevant_'+str(years[0])+"-"+str(years[len(years)-1])+'_full_'+str(kwLimit)
        network = 'network_'+str(years[0])+"-"+str(years[len(years)-1])+'_full_'+str(kwLimit)+'_eth'+str(edge_th)
        mongo = pymongo.MongoClient(utils.get_parameter('mongopath',True,True))
        database = mongo[dbrelevant]
        # clean the collection first
        database[relevant].delete_many({"cumtermhood":{"$gt":0}})
        database[relevant].create_index('keyword')
        [rel_kws,dico,frequencies,edge_list] = extract_relevant_keywords(corpus,kwLimit,occurence_dicos,edge_th)
        print('insert relevant...')
        for kw in rel_kws.keys():
            update_kw_tm(kw,rel_kws[kw],frequencies[kw],math.log(rel_kws[kw])*math.log(len(corpus)/frequencies[kw]),database,relevant)
        print('insert edges...')
        database[network].delete_many({"weight":{"$gt":0}})
        database[network].insert_many(edge_list)




# extract relevant keywords, using unithood and termhood
#  @returns [tselected,p_tsel_dico] : dico kw -> termhood ; dico patent -> kws
def extract_relevant_keywords(corpus,kwLimit,occurence_dicos,edge_th):
    print('Extracting relevant keywords...')

    #[p_kw_dico,kw_p_dico] = data.extract_sub_dicos(corpus,occurence_dicos)
    p_kw_dico = occurence_dicos[0]
    kw_p_dico = occurence_dicos[1]

    print("subdicos : "+str(len(p_kw_dico.keys()))+" ; "+str(len(kw_p_dico.keys())))

    # compute frequencies
    print('Compute frequencies...')
    docfrequencies = {}
    for k in kw_p_dico.keys():
        docfrequencies[k] = len(kw_p_dico[k])

    # compute unithoods
    print('Compute unithoods...')
    unithoods = {}
    for k in kw_p_dico.keys():
        l = len(k.split(' '))
        unithoods[k]=math.log(l+1)*len(kw_p_dico[k])

    # sort and keep K*N keywords ; K = 4 for now ?
    selected_kws = {} # dictionary : kw -> index in matrix
    #selected_kws_indexes = {} # dico index -> kw.  Q : use kw as keys in cooc matrix ?
    #  seems to be even more performant
    print("len(unithoods = "+str(len(unithoods.keys())))
    sorted_unithoods = sorted(unithoods.items(), key=lambda entry: entry[1],reverse=True)
    print("len(sorted_unithoods) = "+str(len(sorted_unithoods)))
    for i in range(int(4*kwLimit)):
        selected_kws[sorted_unithoods[i][0]] = i
        #selected_kws.append(sorted_unithoods[i][0])

    # computing cooccurrences
    print('Computing cooccurrences...')
    # compute termhoods :: coocurrence matrix -> in \Theta(16 N^2) - N must thus stay 'small'
    coocs = {}

    n=len(p_kw_dico)/100;pr=0
    for p in p_kw_dico.keys() :
        pr = pr + 1
        if pr % n == 0 : print('cooccs : '+str(pr/n)+'%')
        sel = []
        for k in p_kw_dico[p] :
            if k in selected_kws : sel.append(k)
        for i in range(len(sel)-1):
            #ii = selected_kws[sel[i]]
            ki = sel[i]
            if ki not in coocs : coocs[ki] = {}
            for j in range(i+1,len(sel)):
                kj= sel[j]
                if kj not in coocs : coocs[kj] = {}
                if kj not in coocs[ki] :
                    coocs[ki][kj] = 1
                else :
                    coocs[ki][kj] = coocs[ki][kj] + 1
                if ki not in coocs[kj] :
                    coocs[kj][ki] = 1
                else :
                    coocs[kj][ki] = coocs[kj][ki] + 1

    # compute termhoods
    #colSums = [sum(row) for row in coocs]
    colSums = {}
    for ki in coocs.keys():
        colSums[ki] = sum(coocs[ki].values())

    #termhoods = [0]*len(coocs.keys())
    termhoods = {}
    for ki in coocs.keys():
        s = 0;
        for kj in coocs[ki].keys():
            if kj != ki : s = s + ((coocs[ki][kj]-colSums[ki]*colSums[kj])*(coocs[ki][kj]-colSums[ki]*colSums[kj]))/(colSums[ki]*colSums[kj])
        termhoods[ki]=s

    # sort and filter on termhoods
    [tselected,dico,freqselected] = extract_from_termhood(termhoods,p_kw_dico,docfrequencies,kwLimit)

    # construct graph edge list (! undirected)
    edge_list = []
    for kw in tselected.keys():
        for ki in coocs[kw].keys():
            if ki in tselected :
                if coocs[kw][ki] >= edge_th :
                    edge_list.append({'edge' : kw+";"+ki, 'weight' : coocs[kw][ki]})


    return([tselected,dico,freqselected,edge_list])



##
# select best keywords given dictionary and computed termhood
def extract_from_termhood(termhoods,p_kw_dico,frequencies,kwLimit):
    sorted_termhoods = sorted(termhoods.items(), key=lambda entry: entry[1],reverse=True)

    tselected = {}
    freqselected = {}
    for i in range(int(kwLimit)):
        tselected[sorted_termhoods[i][0]] = sorted_termhoods[i][1]
        freqselected[sorted_termhoods[i][0]] = frequencies[sorted_termhoods[i][0]]

    # reconstruct the patent -> tselected dico, finally necessary to build kw nw
    p_tsel_dico = dict()
    for p in p_kw_dico.keys() :
        sel = []
        for k in p_kw_dico[p] :
            if k in tselected and k not in sel : sel.append(k)
        p_tsel_dico[p] = sel

    # eventually write to file ? -> do that in other proc (! atomicity)
    return([tselected,p_tsel_dico,freqselected])




##
#
def update_kw_tm(kw,incr,frequency,tidf,database,table):
    prev = database[table].find_one({'keyword':kw})
    if prev is not None:
        prev['cumtermhood']=prev['cumtermhood']+incr
        prev['frequency'] = frequency;prev['tidf']=tidf
        database[table].replace_one({'keyword':kw},prev)
    else :
        database[table].insert_one({'keyword':kw,'cumtermhood':incr,'docfrequency':frequency,'tidf':tidf})
