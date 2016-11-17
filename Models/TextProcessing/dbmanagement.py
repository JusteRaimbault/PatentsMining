# -*- coding: utf-8 -*-

# db management

import utils,data,os,sys
import pymongo

##
# add app_year and grant_year records in keywords collection
def update_year_records():
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    #from redbook : get app_date !! some patents with no app_date record -> ?
    #  replace in kw
    kwdata = mongo['patent']['keywords'].find()
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
    mongo['patent']['keywords'].drop()
    mongo['patent']['keywords'].insert_many(newkwdata)




##
# read techno csv file and return a dictionary id -> set of classes
def get_techno_dico():
    # load techno classes from csv
    techno = utils.read_csv(os.environ['CS_HOME']+'/PatentsMining/Data/processed/classes/class.csv',",")

    # techno dico
    techno_dico = {};n=len(techno)
    for i in range(1,len(techno)) :
        #if i % 10000 == 0 : print(100*i/n)
        currentid = techno[i][0];#currentid=currentid[1:]
        currentclass = techno[i][1]
        if currentid not in techno_dico : techno_dico[currentid] = set()
        techno_dico[currentid].add(currentclass)
    return(techno_dico)

#
# NOT NEEDED : use keywords database instead
#
#def update_techno_classes():
#    # for now get classes from fung file, redbook not complete for xml years
#    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
#
#    # do it dirtily (should be quicker in perf) : get full collection, update, insert_many
#    data = mongo['patent']['keywords'].find()
#
#    techno_dico = get_techno_dico()
#
#    # update data adding classes
#    newdata=[]
#    for p in data :
#        p['classes'] = []
#        if p['id'] in techno_dico : p['classes'] = list(techno_dico[p['id']])
#        newdata.append(p)
#
#    # drop collection
#    #mongo['patent'].drop_collection('keywords')
#
#    # insert everything
#    # test in tmp ?
#    mongo['patent']['keywords_tmp'].insert_many(newdata)
#

def compute_kw_techno():
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    data = mongo['patent']['keywords'].find()
    techno_dico = get_techno_dico()

    npatents = data.count()

    counts = {}
    for i in range(npatents):
        if i % 10000 == 0 : print(100*i/npatents)
        p=data.next()
        for kw in p['keywords']:
            if not kw in counts :
                counts[kw]={}
                counts[kw]['keyword']=kw
            if p['id'] in techno_dico :
                for cl in techno_dico[p['id']]:
                    if cl not in counts[kw] : counts[kw][cl] = 0
                    counts[kw][cl] = counts[kw][cl] + 1

    # dico to list ? -> counts.values()
    mongo['keywords']['techno'].insert_many(counts.values())



# first update
task = sys.argv[1]

if task=='--kw-consolidation':
    # first update year records
    update_year_records()
    # then compute techno classes
    compute_kw_techno()


#compute_kw_techno()
#update_year_records()
#update_techno_classes()

#data_to_mongo('/mnt/volume1/juste/ComplexSystems/PatentsMining/data','patents_fung')
#keywords_to_mongo('/mnt/volume1/juste/ComplexSystems/PatentsMining/data/keywords.sqlite3','patents_fung')
#data_to_kwtable('/mnt/volume1/juste/ComplexSystems/PatentsMining/data/patent.sqlite3','patents_fung')
