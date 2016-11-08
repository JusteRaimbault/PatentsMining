# -*- coding: utf-8 -*-

# Collect and store data
#   - retrieving and unzipping done in shell ; here file name as arg -

import pymongo,sys
import parser


def test_xml_import() :
    data = parser.parse_xml_file('data/2002.xml',2002)
    print data

def import_file(f):
    print 'importing file '+str(f)
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    database = mongo['redbook']
    database.raw.create_index('id')

    year = f.split('/')[1].split('.')[0].split('_')[0]

    data = parser.parse_file(f,year)

    database.raw.insert_many(data)

import_file(sys.argv[1])
