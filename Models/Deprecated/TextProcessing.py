
###########
## DEPRECATED Procedures from TextProcessing

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
