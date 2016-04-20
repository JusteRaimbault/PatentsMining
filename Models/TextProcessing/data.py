import sqlite3,pymongo



def test_dico():
    # with export
    corpus = get_patent_data(2007,1000)
    [p_kw_dico,kw_p_dico] = construct_occurrence_dico(corpus)
    export_kw_dico('../../Data/processed/keywords_y2007_1000.sqlite3',p_kw_dico)

def test_db():
    for patent in get_patent_data(2000,100):
        print(patent)




##
#  export to mongo
def export_kw_dico(database,collection,p_kw_dico,year):
    mongo = pymongo.MongoClient('localhost', 29019)
    database = mongo[database]
    col = database[collection]
    col.create_index("id")

    data = []

    for p in p_kw_dico.keys() :
        data.append({"id":p,"keywords":p_kw_dico[p],"year":str(year)})

    col.insert_many(data)


def import_kw_dico(database,collection,year):
    mongo = pymongo.MongoClient('localhost', 29019)
    database = mongo[database]
    col = database[collection]

    data = col.find({"year":year})
    p_kw_dico={}
    kw_p_dico={}

    for row in data:
        keywords = row['keywords'];patent_id=row['id']
        p_kw_dico[patent_id] = keywords
        for kw in keywords :
            if kw not in kw_p_dico : kw_p_dico[kw] = []
            kw_p_dico[kw].append(kw)

    return([p_kw_dico,kw_p_dico])

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


# get patent id
def get_patent_id(cursor_raw):
    return(cursor_raw[0].encode('ascii','ignore'))



def get_patent_data(year,limit):
    mongo = pymongo.MongoClient('localhost', 29019)
    database = mongo['redbook']
    col = database['raw']
    data = col.find({"year":year,"id":{"$regex":r'^[0-9]'},"abstract":{"$regex":r'.'}},{"id":1,"title":1,"abstract":1})#.limit(limit)
    res=[]
    for row in data :
        #print row
	i=""
	if 'id' in row : i = row['id']
	title = ""
	if 'title' in row : title = row['title']
	abstract = ""
	if 'abstract' in row : abstract = row['abstract']
	res.append([i,title,abstract])
    return(res)


def get_patent_data_sqlite(year,limit,full) :
    # connect to the database
    #conn = sqlite3.connect('../../Data/raw/patdesc/patdesc.sqlite3')
    conn = sqlite3.connect('data/patent.sqlite3')
    cursor = conn.cursor()
    # attach patent data
    #cursor.execute('ATTACH DATABASE \'../../Data/raw/patent/patent.sqlite3\' as \'patent\'')
    #if full : cursor.execute('ATTACH DATABASE \'data/patdesc.sqlite3\' as \'patdesc\'')
    cursor.execute('ATTACH DATABASE \'data/patdesc.sqlite3\' as \'patdesc\'')

    #cursor.execute('SELECT patdesc.patent,patent.patent FROM patent,patdesc WHERE patent.patent=patdesc.patent LIMIT 10;')
    # retrieve records
    if full :
        query='SELECT patent.patent,title,abstract,GYear FROM patdesc,patent WHERE patdesc.patent = patent.patent AND (NOT (Patent glob \'*[A-z]*\')) AND abstract!=\'\''
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

# get from query
def get_patent_data_query(query,dbraw,dbdesc,dbdescname):
    conn = sqlite3.connect(dbraw)
    cursor = conn.cursor()
    cursor.execute('ATTACH DATABASE \''+dbdesc+'\' as \'\'')
    cursor.execute(query)
    res=cursor.fetchall()
    return res
