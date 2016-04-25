# -*- coding: utf-8 -*-

# db management

import utils,data
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
        col.insert_one({'id':row[0],'title':row[1],'abstract':row[2],'year':row[3],'date':row[4]})
    col.create_index('id')

# add some data to keywords ; avoiding $lookup
def data_to_kwtable(sqlitedb,mongodb):
    client=pymongo.MongoClient('localhost',29019)
    db=client[mongodb]
    data = utils.fetch_sqlite('SELECT patent,GYear FROM patent;',sqlitedb)
    col=db['keywords']
    for row in data :
        col.update({'id':row[0]},{'$set' : {'year':row[1]}})



data_to_mongo('/mnt/volume1/juste/ComplexSystems/PatentsMining/data','patents_fung')
keywords_to_mongo('/mnt/volume1/juste/ComplexSystems/PatentsMining/data/keywords.sqlite3','patents_fung')
data_to_kwtable('/mnt/volume1/juste/ComplexSystems/PatentsMining/data/patent.sqlite3','patents_fung')
