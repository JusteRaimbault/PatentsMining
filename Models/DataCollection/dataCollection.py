# -*- coding: utf-8 -*-

# Collect and store data
#   - retrieving and unzipping done in shell ; here file name as arg -

import pymongo,sys
import parser

def import_dat_file(f):
    print 'importing file '+str(f)
    mongo = pymongo.MongoClient('localhost', 29019)
    database = mongo['redbook']
    database.raw.create_index('id')

    year = f.split('.')[0]
    data = parse_dat_file(f,year)

    database.raw.insert_many(data)

import_dat_file(sys.argv[0])
