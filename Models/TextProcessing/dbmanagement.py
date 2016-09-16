# -*- coding: utf-8 -*-

# db management

import utils,data,os
import pymongo

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

# switch from GDate to AppDate
def update_year_records():
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    #from redbook : get app_date !! some patents with no app_date record -> ?
    #  replace in kw
    kwdata = mongo['patent']['keywords_grant'].find()
    print('kw data : '+str(kwdata.count()))
    redbook = mongo['redbook']['raw'].find()
    print('redbook : '+str(redbook.count()))
    redbookdico={}
    for r in redbook :
        if 'id' in r and 'app_date' in r and 'grant_date' in r : redbookdico[r['id']]={'app_date':r['app_date'],'grant_date':r['grant_date']}
    newkwdata = []
    for kw in kwdata :
        if 'id' in kw :
            if kw['id'] in redbookdico :
                appdate = redbookdico[kw['id']]['app_date']
                grantdate = redbookdico[kw['id']]['grant_date']
                if len(appdate)<4 : appdate = "0000"
                if len(grantdate)<4 : grantdate = "0000"
                newkwdata.append({'id':kw['id'],'keywords':kw['keywords'],'app_year':appdate[:4],'grant_year':grantdate[:4],'app_date':appdate,'grant_date':grantdate})
    print('new data to be inserted : '+str(len(newkwdata)))
    # insert new data
    mongo['patent']['keywords'].insert_many(newkwdata)




def update_techno_classes():
    # for now get classes from fung file, redbook not complete for xml years
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')

    # do it dirtily (should be quicker in perf) : get full collection, update, insert_many
    data = mongo['patent']['keywords'].find()

    # load techno classes from csv
    techno = utils.read_csv(os.environ['CS_HOME']+'/PatentsMining/Data/raw/classesTechno/class.csv',",")

    # techno dico
    techno_dico = {};n=len(techno)
    for i in range(1,len(techno)) :
        if i % 10000 == 0 : print(100*i/n)
        currentid = techno[i][0];currentclass = techno[i][2]
        if currentid not in techno_dico : techno_dico[currentid] = set()
        techno_dico[currentid].add(currentclass)

    # update data adding classes - mutable, no need for new data structure
    for p in data :
        p['classes'] = []
        if p['id'] in techno_dico : p['classes'] = list(techno_dico[p['id']])

    # drop collection
    mongo['patent'].drop_collection('keywords')

    # insert everything
    mongo['patent']['keywords'].insert_many(data)




update_techno_classes()


#update_year_records()

#data_to_mongo('/mnt/volume1/juste/ComplexSystems/PatentsMining/data','patents_fung')
#keywords_to_mongo('/mnt/volume1/juste/ComplexSystems/PatentsMining/data/keywords.sqlite3','patents_fung')
#data_to_kwtable('/mnt/volume1/juste/ComplexSystems/PatentsMining/data/patent.sqlite3','patents_fung')
