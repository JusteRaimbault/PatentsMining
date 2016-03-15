import sqlite3



def test_dico():
    # with export
    corpus = get_patent_data(2007,1000)
    [p_kw_dico,kw_p_dico] = construct_occurrence_dico(corpus)
    export_kw_dico('../../Data/processed/keywords_y2007_1000.sqlite3',p_kw_dico)

def test_db():
    for patent in get_patent_data(2000,100):
        print(patent)





##
#  exports a dico to sqlite db
#  (to avoid reprocessing)
def export_kw_dico(database,p_kw_dico) :
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
def import_kw_dico(database,rawdb,year) :
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



def get_patent_data(year,limit,full) :
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
