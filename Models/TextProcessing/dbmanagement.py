# -*- coding: utf-8 -*-

# db management

import utils
import pymongo

def keywords_to_mongo(sqlitedb,mongodb):
    client=pymongo.MongoClient()
    db=client[mongodb]
    data = utils.fetch_sqlite('SELECT * FROM keywords;',sqlitedb)
    col=db['keywords']
    for row in data:
        col.insert_one({'id':row[0],'keywords':row[1].split(';')})
    # add index for query efficiency
    col.create_index('id')

# convert all data to mongo collection
def data_to_mongo(sqlitedb,mongodb):
    client=pymongo.MongoClient()
    db=client[mongodb]
    data = utils.fetch_sqlite('SELECT patent,GYear,GDate FROM patent;',sqlitedb)
    col=db['patent']
    for row in data:
        col.insert_one({'id':row[0],'year':row[1],'date':row[2]})
    col.create_index('id')


#keywords_to_mongo('data/keywords.sqlite3','patents_keywords')
data_to_mongo('data/patent.sqlite3','patents_keywords')
