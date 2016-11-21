import pymongo







##
#  Given large occurence dico, extracts corresponding subdico
#  assumes large dicos contains all subcorpus.
#  @returns [p_kw_dico,kw_p_dico]
def extract_sub_dicos(corpus,occurence_dicos) :
    p_kw_dico_all = occurence_dicos[0]
    kw_p_dico_all = occurence_dicos[1]

    p_kw_dico = dict()
    kw_p_dico = dict()

    for patent in corpus :
        #patent_id = data.get_patent_id(patent)
        patent_id=patent[0]
        keywords = []
        if patent_id in p_kw_dico_all : keywords = p_kw_dico_all[patent_id]
        p_kw_dico[patent_id] = keywords
        for k in keywords :
            if k not in kw_p_dico : kw_p_dico[k] = []
            kw_p_dico[k].append(patent_id)

    return([p_kw_dico,kw_p_dico])







##
#  export to mongo
def export_kw_dico(database,collection,p_kw_dico,year):
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    database = mongo[database]
    col = database[collection]
    col.create_index("id")

    data = []

    for p in p_kw_dico.keys() :
        data.append({"id":p,"keywords":p_kw_dico[p],"year":str(year)})

    col.insert_many(data)


def export_set_dico(database,collection,dico,fields):
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    database = mongo[database]
    col = database[collection]
    col.create_index(fields[0])
    data = []
    for p in dico.keys() :
        data.append({fields[0]:p,fields[1]:list(dico[p])})
    col.insert_many(data)

def import_kw_dico(database,collection,years,yearfield):
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    database = mongo[database]
    col = database[collection]

    data = col.find({yearfield:{"$in":years}})
    p_kw_dico={}
    kw_p_dico={}

    for row in data:
        keywords = row['keywords'];patent_id=row['id']
        p_kw_dico[patent_id] = keywords
        for kw in keywords :
            if kw not in kw_p_dico : kw_p_dico[kw] = []
            kw_p_dico[kw].append(kw)

    return([p_kw_dico,kw_p_dico])



# get patent id
def get_patent_id(cursor_raw):
    return(cursor_raw[0].encode('ascii','ignore'))



def get_patent_data(db,collection,years,yearfield,limit,full=True):
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    database = mongo[db]
    col = database[collection]
    if full :
        data = col.find({yearfield:{"$in":years},"id":{"$regex":r'^[0-9]'},"abstract":{"$regex":r'.'}},{"id":1,"title":1,"abstract":1})#.limit(limit)
    else :
        data = col.find({yearfield:{"$in":years},"id":{"$regex":r'^[0-9]'}},{"id":1})
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
