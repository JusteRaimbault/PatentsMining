
# export of data from raw db

import pymongo
import json


#'
#' This simple request is not implemented by mongo
def and_text_query(terms,fields,f):
    mongo = pymongo.MongoClient('mongodb://root:root@127.0.0.1:29019')
    database = mongo['redbook']
    projection = {}
    for field in fields :
        projection[field]=1

    ids=set()
    for term in terms:
        data = database.raw.find({"$text":{"$search":term}},{"id":1})
        currentids=set([record['id'] for record in list(data)])
        if len(ids)>0:
            ids=ids.intersection(currentids)
        else:
            ids=currentids
    #print(ids)
    ids=list(ids)
    fulldata= database.raw.find({"id":{"$in":ids}},{"id":1,"abstract":1,"title":1,"year":1,"_id":0})
    #print(list(fulldata))
    finaldata=list(fulldata)
    print(len(finaldata))
    print(finaldata)
    json.dump(finaldata,open(f,'w'))


def export_redbook_as_csv(fields,file):
    mongo = pymongo.MongoClient('localhost', 29019)
    database = mongo['redbook']

    projection = {}
    for field in fields :
        projection[field]=1

    data = database.raw.find({"id":{"$regex":"[0-9]*"}},projection)

    writer = open(file,'w')

    for i in range(len(fields)):
        writer.write(fields[i])
        if i < len(fields)-1:
            writer.write(";")
        else :
            writer.write("\n")

    for row in data:
        print(row)
        for i in range(len(fields)):
            if fields[i] in row : writer.write(row[fields[i]])
            if i < len(fields)-1:
                writer.write(";")
            else :
                writer.write("\n")

def export_classes_as_csv(file,max_year):
    mongo = pymongo.MongoClient('localhost', 29019)
    database = mongo['redbook']
    data = database.raw.find({"id":{"$regex":r'^[0-9]'},"year":{"$lt":max_year}},{"id":1,"classes":1})

    writer = open(file,'w')

    writer.write('id;class;primary\n')

    for row in data :
        print(row)
        if 'id' in row :
            patent_id = row['id']
            if 'classes' in row :
                classes = row['classes']
                # primary classif : OCL
                if 'OCL' in classes : writer.write(patent_id+';'+classes['OCL']+';1\n')
                if 'XCL' in classes :
                    xcl_classes = classes['XCL']
                    if type(xcl_classes)==type([]):
                        for xcl in xcl_classes :
                             writer.write(patent_id+';'+xcl+';0\n')
                    else :
                        writer.write(patent_id+';'+xcl_classes+';0\n')



#export_redbook_as_csv(['id','grant_date','app_date'],'export/redbook.csv')

#export_classes_as_csv('export/classes_76-01.csv',"2002")

#and_text_query(['cosmetic','wax','oil'],{},'res/cosmetic-wax-oil.json')
and_text_query(['cosmetic','wax'],{},'res/cosmetic-wax.json')
and_text_query(['cosmetic','oil'],{},'res/cosmetic-oil.json')
and_text_query(['oil','wax'],{},'res/oil-wax.json')

