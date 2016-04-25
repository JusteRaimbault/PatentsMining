import numpy,pymongo,math
import utils,data,keywords



def test_bootstrap():
    year = -1
    N = -1
    kwLimit=50000
    subCorpusSize=100000
    bootstrapSize=100
    corpus = get_patent_data(year,N,False)
    [relevantkw,relevant_dico] = bootstrap_subcorpuses(corpus,kwLimit,subCorpusSize,bootstrapSize)
    export_dico_csv(relevant_dico,'res/bootstrap_relevantDico_y'+str(year)+'_size'+str(N)+'_kwLimit'+str(kwLimit)+'_subCorpusSize'+str(subCorpusSize)+'_bootstrapSize'+str(bootstrapSize))
    export_list(relevantkw,'res/relevantkw_y'+str(year)+'_size'+str(N)+'_kwLimit'+str(kwLimit)+'_subCorpusSize'+str(subCorpusSize)+'_bootstrapSize'+str(bootstrapSize))




# creates databases for bootstrap run
#def init_bootstrap(year,limit,kwLimit,subCorpusSize,bootstrapSize,nruns):
#    dbname = 'run_year'+str(year)+'_limit'+str(limit)+'_kw'+str(kwLimit)+'_csize'+str(subCorpusSize)+'_b'+str(bootstrapSize)+'_runs'+str(nruns)
#    mongo = MongoClient()
#    database = mongo[dbname]
#    database.relevant.create_index('keyword')
#    database.dico.create_index('id')


def relevant_full_corpus(year,kwLimit):
    dbdata = 'patents_fung'
    dbrelevant = 'relevant_fung'
    corpus = data.get_patent_data(dbdata,'patent',year,-1)
    occurence_dicos = data.import_kw_dico(dbdata,'keywords',year)
    print('corpus : '+str(len(corpus))+' ; dico : '+str(len(occurence_dicos[0]))+' , '+str(len(occurence_dicos[1])))
    if len(corpus) > 0 and len(occurence_dicos) > 0 :
        relevant = 'relevant_'+str(year)+'_full_'+str(kwLimit)
        network = 'network_'+str(year)+'_full_'+str(kwLimit)+'_eth10'
        #mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
        mongo = pymongo.MongoClient('localhost',29019)
        database = mongo[dbrelevant]
        # clean the collection first
        database[relevant].delete_many({"cumtermhood":{"$gt":0}})
        database[relevant].create_index('keyword')
        [rel_kws,dico,frequencies,edge_list] = keywords.extract_relevant_keywords(corpus,kwLimit,occurence_dicos)
        print('insert relevant...')
	    for kw in rel_kws.keys():
            update_kw_tm(kw,rel_kws[kw],frequencies[kw],math.log(rel_kws[kw])*math.log(len(corpus)/frequencies[kw]),database,relevant)
        print('insert edges...')
        database[network].delete_many({"weight":{"$gt":0}})
	    database[network].insert_many(edge_list)



##
#   assumed to be run in //
#     - run by packet for intermediate filtering -
def run_bootstrap(year,limit,kwLimit,subCorpusSize,bootstrapSize,nruns) :
    corpus = data.get_patent_data(year,limit,False)
    occurence_dicos = data.import_kw_dico('data/keywords.sqlite3','data/patent.sqlite3',year)
    if len(corpus) > 0 and len(occurence_dicos) > 0 :
        dbname = 'patent_limit'+str(limit)+'_kw'+str(kwLimit)+'_csize'+str(subCorpusSize)+'_b'+str(bootstrapSize)+'_runs'+str(nruns)
        relevant = 'relevant_'+str(year)
        mongo = pymongo.MongoClient()
        database = mongo[dbname]
        database[relevant].create_index('keyword')

        for i in range(nruns):
            print("run "+str(i)+" for year "+str(year))
            [relevantkw,relevant_dico,allkw] = bootstrap_subcorpuses(corpus,occurence_dicos,kwLimit,subCorpusSize,bootstrapSize)
            # update bases iteratively (ok for concurrency ?)
            for kw in relevantkw.keys():
                update_kw_tm(kw,relevantkw[kw],database,relevant)
            #for i in relevant_dico.keys():
            #    update_kw_dico(i,relevant_dico[i],database)
            update_count(bootstrapSize,database,year)



def update_kw_tm(kw,incr,frequency,tidf,database,table):
    prev = database[table].find_one({'keyword':kw})
    if prev is not None:
        prev['cumtermhood']=prev['cumtermhood']+incr
        prev['frequency'] = frequency;prev['tidf']=tidf
        database[table].replace_one({'keyword':kw},prev)
    else :
        database[table].insert_one({'keyword':kw,'cumtermhood':incr,'docfrequency':frequency,'tidf':tidf})



#def update_kw_dico(i,kwlist,database):
#    # update id -> kws dico
#    #prev = utils.fetchone_sqlite('SELECT keywords FROM dico WHERE id=\''+i+'\';',database)
#    #kws = set()
#    #if prev is not None: kws = set(prev[0].split(";"))
#    #for kw in kwlist :
#    #    kws.add(kw)
#    #if prev is not None:
#    #    utils.insert_sqlite('UPDATE dico SET id=\''+i+'\',keywords=\''+utils.implode(kws,";")+'\' WHERE id=\''+i+'\';',database)
#    #else :
#    #    utils.insert_sqlite('INSERT INTO dico VALUES (\''+i+'\',\''+utils.implode(kws,";")+'\')',database)
#    # update kw -> id
#    prev = database.dico.find_one({'id':i})
#    if prev is not None:
#        kwset=set(prev['keywords'])
#        for kw in kwlist :
#            kwset.add(kw)
#        prev['keywords']=list(kwset)
#        database.dico.replace_one({'id':i},prev)
#    else :
#        database.dico.insert_one({'id':i,'keywords':kwlist})
#
#    # kw -> ids
#    for kw in kwlist :
#        #prev = utils.fetchone_sqlite('SELECT * FROM relevant WHERE keyword=\''+kw+'\';',database)
#        #ids = set()
#        prev = database.relevant.find_one({'keyword':kw})
#        if prev is not None :
#            #ids = set(prev[2].split(";"))
#            #ids.add(i)
#            #utils.insert_sqlite('UPDATE relevant SET keyword=\''+kw+'\',cumtermhood='+str(prev[1])+',ids=\''+utils.implode(ids,";")+'\' WHERE keyword=\''+kw+'\';',database)
#            ids=set(prev['ids'])
#            ids.add(i)
#            prev['ids']=list(ids)
#            database.relevant.replace_one({'keyword':kw},prev)
#        else :
#            #utils.insert_sqlite('INSERT INTO relevant VALUES (\''+kw+'\',0,\''+i+'\');',database)
#            database.relevant.insert_one({'keyword':kw,'cumtermhood':0,'ids':[i]})



def update_count(bootstrapSize,database,year):
    prev=database.params.find_one({'key':'count_'+str(year)})
    if prev is not None:
        prev['value']=prev['value']+bootstrapSize
        database.params.replace_one({'key':'count_'+str(year)},prev)
    else :
        database.params.insert_one({'key':'count_'+str(year),'value':bootstrapSize})







## Functions


# tests for a bootstrap technique to avoid subcorpus relevance bias
def bootstrap_subcorpuses(corpus,occurence_dicos,kwLimit,subCorpusSize,bootstrapSize):
    N = len(corpus)

    print('Bootstrapping on corpus of size '+str(N))

    # generate bSize extractions
    #   -> random subset of 1:N of size subCorpusSize
    extractions = [map(lambda x : x - 1,numpy.random.choice(N,subCorpusSize,replace=False)) for b in range(bootstrapSize)]

    mean_termhoods = dict() # mean termhoods progressively updated
    p_kw_dico = dict() # patent -> kw dico : cumulated on repetitions. if a kw is relevant a few time, counted as 0 in mean.
    # for each extraction, extract subcorpus and get relevant kws
    # for each patent, mean termhoods computed cumulatively, ; recompute relevant keywords later

    allkw = []

    for eind in range(len(extractions)) :
        print("bootstrap : run "+str(eind))
	extraction = extractions[eind]
        subcorpus = [corpus[i] for i in extraction]
        [kws,p_kw_local_dico] = keywords.extract_relevant_keywords(subcorpus,kwLimit,occurence_dicos)

        allkw.append(kws)

        # add termhoods
        for kw in kws.keys() :
            if kw not in mean_termhoods : mean_termhoods[kw] = 0
            mean_termhoods[kw] = mean_termhoods[kw] + kws[kw]

        # update p->kw dico
        for p in p_kw_local_dico.keys() :
            if p not in p_kw_dico : p_kw_dico[p] = set()
            for kw in p_kw_local_dico[p] :
		        p_kw_dico[p].add(kw)

    res = keywords.extract_from_termhood(mean_termhoods,p_kw_dico,kwLimit)
    res.append(allkw)
    return(res)
