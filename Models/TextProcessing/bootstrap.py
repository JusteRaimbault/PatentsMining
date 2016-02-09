import numpy
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
def init_bootstrap(res_folder):
    conn = utils.configure_sqlite(res_folder+'/bootstrap.sqlite3')
    c = conn.cursor()
    c.execute('CREATE TABLE relevant (keyword text, cumtermhood real, ids text);')
    c.execute('CREATE TABLE params (key text, value real);')
    c.execute('CREATE TABLE dico (id text, keywords text);')
    conn.commit()
    conn.close()


##
#   assumed to be run in //
#     - run by packet for intermediate filtering -
def run_bootstrap(res_folder,kwLimit,subCorpusSize,bootstrapSize) :
    corpus = data.get_patent_data(-1,-1,False)
    occurence_dicos = data.import_kw_dico('data/keywords.sqlite3')
    database = res_folder+'/bootstrap.sqlite3'
    #while True :
    for i in range(2):
        [relevantkw,relevant_dico,allkw] = bootstrap_subcorpuses(corpus,occurence_dicos,kwLimit,subCorpusSize,bootstrapSize)
        # update bases iteratively (ok for concurrency ?)
        for kw in relevantkw.keys():
            update_kw_tm(kw,relevantkw[kw],database)
        for i in relevant_dico.keys():
            update_kw_dico(i,relevant_dico[i],database)
        update_count(bootstrapSize,database)

def update_kw_tm(kw,incr,database):
    prev = utils.fetchone_sqlite('SELECT cumtermhood,ids FROM relevant WHERE keyword=\''+kw+'\';',database)
    t = 0
    ids=''
    #print(prev)
    if prev is not None:
        t = prev[0]+incr
        ids = prev[1]
        utils.insert_sqlite('UPDATE relevant SET keyword=\''+kw+'\',cumtermhood='+str(t)+',ids=\''+ids+'\' WHERE keyword=\''+kw+'\';',database)
    else :
        # insert
        utils.insert_sqlite('INSERT INTO relevant VALUES (\''+kw+'\','+str(incr)+',\'\');',database)




def update_kw_dico(i,kwlist,database):
    # update id -> kws dico
    prev = utils.fetchone_sqlite('SELECT keywords FROM dico WHERE id=\''+i+'\';',database)
    kws = set()
    if prev is not None: kws = set(prev[0].split(";"))
    for kw in kwlist :
        kws.add(kw)
    if prev is not None:
        utils.insert_sqlite('UPDATE dico SET id=\''+i+'\',keywords=\''+utils.implode(kws,";")+'\' WHERE id=\''+i+'\';',database)
    else :
        utils.insert_sqlite('INSERT INTO dico VALUES (\''+i+'\',\''+utils.implode(kws,";")+'\')',database)
    # update kw -> id
    for kw in kwlist :
        prev = utils.fetchone_sqlite('SELECT * FROM relevant WHERE keyword=\''+kw+'\';',database)
        ids = set()
        if prev is not None :
            ids = set(prev[2].split(";"))
            ids.add(i)
            utils.insert_sqlite('UPDATE relevant SET keyword=\''+kw+'\',cumtermhood='+str(prev[1])+',ids=\''+utils.implode(ids,";")+'\' WHERE keyword=\''+kw+'\';',database)
        else :
            utils.insert_sqlite('INSERT INTO relevant VALUES (\''+kw+'\',0,\''+i+'\');',database)



def update_count(bootstrapSize,database):
    prev = utils.fetchone_sqlite('SELECT value FROM params WHERE key=\'count\'',database)
    if prev is not None:
        t=prev[0]+bootstrapSize
	    utils.insert_sqlite('UPDATE params SET value='+str(t)+' WHERE key=\'count\';',database)
    else :
	    utils.insert_sqlite('INSERT INTO params VALUES (\'count\','+str(bootstrapSize)+')',database)








## Functions


# tests for a bootstrap technique to avoid subcorpus relevance bias
def bootstrap_subcorpuses(corpus,occurence_dicos,kwLimit,subCorpusSize,bootstrapSize):
    N = len(corpus)

    print('Bootstrapping on corpus of size '+str(N))

    # generate bSize extractions
    #   -> random subset of 1:N of size subCorpusSize
    extractions = [numpy.random.random_integers(0,(N-1),subCorpusSize) for b in range(bootstrapSize)]

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

    res = kwFunctions.extract_from_termhood(mean_termhoods,p_kw_dico,kwLimit)
    res.append(allkw)
    return(res)
