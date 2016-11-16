
###########
## DEPRECATED Procedures from TextProcessing




### DEPRECATED : keyword extraction




## -- Issue with // processing --
#def test_kw():
#    def f(patent):
#        return extract_keywords(patent[1]+". "+patent[2],patent[0])
#
#    p = Pool(4)
#    print(p.map(f, get_patent_data(2000,1000)))




#def termhood_extraction():
#    corpus = io.get_patent_data(2000,10000)
#    dicos = io.import_kw_dico('../../Data/processed/keywords_y2000_10000.sqlite3')
#    [relevantkw,relevant_dico] = keywords.extract_relevant_keywords(corpus,1000,dicos)
#    #for k in relevant_dico.keys():
#    #    print(k+' : '+str(relevant_dico[k]))
#    utils.export_dico_csv(relevant_dico,'../../data/processed/relevantDico_y2000_size10000_kwLimit4000')
#    utils.export_list(relevantkw,'../../data/processed/relevantkw_y2000_size10000_kwLimit4000')
#
#def extract_all_keywords() :
#    corpus = get_patent_data(2000,10000)
#    [p_kw_dico,kw_p_dico] = construct_occurrence_dico(corpus)
#    export_kw_dico('../../Data/processed/keywords_y2000_10000.sqlite3',p_kw_dico)
#
#def extract_remaining_keywords() :
#    mongo = pymongo.MongoClient()
#    existing = mongo['patents_keywords'].keywords.find({},{'id'})





##
#  import dictionnaries from sqlite db ; table assumed as keywords = (patent_id ; keywords separated by ';')
def import_kw_dico_sqlite(database,rawdb,year) :
    conn = sqlite3.connect(database)
    c = conn.cursor()
    c.execute('ATTACH DATABASE \''+rawdb+'\' as \'patent\'')
    c.execute('SELECT keywords.id,keywords.keywords FROM keywords,patent WHERE patent.patent=keywords.id AND patent.GYear='+str(year)+';')
    res = c.fetchall()

    p_kw_dico = dict()
    kw_p_dico = dict()

    for row in res :
        patent_id = row[0].encode('ascii','ignore')
        #print(patent_id)
        keywords = row[1].encode('ascii','ignore').split(';')
        p_kw_dico[patent_id] = keywords
        for kw in keywords :
            if kw not in kw_p_dico : kw_p_dico[kw] = []
            kw_p_dico[kw].append(kw)

    return([p_kw_dico,kw_p_dico])

# get from query
def get_patent_data_query(query,dbraw,dbdesc,dbdescname):
    conn = sqlite3.connect(dbraw)
    cursor = conn.cursor()
    cursor.execute('ATTACH DATABASE \''+dbdesc+'\' as \'\'')
    cursor.execute(query)
    res=cursor.fetchall()
    return res
