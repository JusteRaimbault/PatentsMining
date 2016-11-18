
###########
## DEPRECATED Procedures from TextProcessing


###############
### from utils.py


# returns sqlite connection
def configure_sqlite(database):
    return(sqlite3.connect(database,600))


def fetchone_sqlite(query,database):
    conn = configure_sqlite(database)
    cursor = conn.cursor()
    cursor.execute(query)
    res = cursor.fetchone()
    conn.commit()
    conn.close()
    return(res)


def fetch_sqlite(query,database):
    conn = configure_sqlite(database)
    cursor = conn.cursor()
    cursor.execute(query)
    res = cursor.fetchall()
    conn.commit()
    conn.close()
    return(res)



def insert_sqlite(query,database):
    conn = configure_sqlite(database)
    cursor = conn.cursor()
    cursor.execute(query)
    conn.commit()
    conn.close()






###############
### from data.py

##
#  exports a dico to sqlite db
#  (to avoid reprocessing)
def export_kw_dico_sqlite(database,p_kw_dico) :
    conn = sqlite3.connect(database)
    c = conn.cursor()

    # create the table
    c.execute('CREATE TABLE keywords (id text, keywords text)');

    for p in p_kw_dico.keys() :
        k = reduce(lambda s1,s2 : s1+';'+s2,p_kw_dico[p])
        query = "INSERT INTO keywords VALUES (\'"+p+"\',\'"+k+"\')"
        print(query)
        c.execute(query)

    # commit and close
    conn.commit()
    conn.close()




def get_patent_data_sqlite(sqlitedir,year,limit,full) :
    # connect to the database
    #conn = sqlite3.connect('../../Data/raw/patdesc/patdesc.sqlite3')
    conn = sqlite3.connect(sqlitedir+'/patent.sqlite3')
    cursor = conn.cursor()
    # attach patent data
    #cursor.execute('ATTACH DATABASE \'../../Data/raw/patent/patent.sqlite3\' as \'patent\'')
    #if full : cursor.execute('ATTACH DATABASE \'data/patdesc.sqlite3\' as \'patdesc\'')
    cursor.execute('ATTACH DATABASE \''+sqlitedir+'/patdesc.sqlite3\' as \'patdesc\'')

    #cursor.execute('SELECT patdesc.patent,patent.patent FROM patent,patdesc WHERE patent.patent=patdesc.patent LIMIT 10;')
    # retrieve records
    if full :
        query='SELECT patent.patent,title,abstract,GYear,GDate FROM patdesc,patent WHERE patdesc.patent = patent.patent AND (NOT (patent.patent glob \'*[A-z]*\')) AND abstract!=\'\''
    else :
        query='SELECT patent.patent,GYear FROM patent,patdesc WHERE patdesc.patent = patent.patent AND (NOT (patent.patent glob \'*[A-z]*\')) AND abstract!=\'\''
    if year != -1 :
        query = query +' AND GYear = '+str(year)
    if limit != -1 :
        query = query+' LIMIT '+str(limit)+";"
    else :
        query = query+";"
    print(query)
    cursor.execute(query)
    res=cursor.fetchall()
    #first=res[0]
    #raw_text = first[0]+". "+first[1]
    return res






###########
### from dbmanagement.py


def keywords_to_mongo(sqlitedb,mongodb):
    client=pymongo.MongoClient('localhost',29019)
    db=client[mongodb]
    data = utils.fetch_sqlite('SELECT * FROM keywords;',sqlitedb)
    col=db['keywords']
    for row in data:
        col.insert_one({'id':row[0],'keywords':row[1].split(';')})
    # add index for query efficiency
    col.create_index('id')

# convert all data to mongo collection
def data_to_mongo(sqlitedir,mongodb):
    client=pymongo.MongoClient('localhost',29019)
    db=client[mongodb]
    #data = utils.fetch_sqlite('SELECT patent,GYear,GDate FROM patent;',sqlitedb)
    d = data.get_patent_data_sqlite(sqlitedir,-1,-1,True)
    col=db['patent']
    for row in d:
        col.insert_one({'id':row[0],'title':row[1],'abstract':row[2],'year':str(row[3]),'date':row[4]})
    col.create_index('id')

# add some data to keywords ; avoiding $lookup
def data_to_kwtable(sqlitedb,mongodb):
    client=pymongo.MongoClient('localhost',29019)
    db=client[mongodb]
    data = utils.fetch_sqlite('SELECT patent,GYear FROM patent;',sqlitedb)
    col=db['keywords']
    for row in data :
        col.update({'id':row[0]},{'$set' : {'year':str(row[1])}})







###########
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
