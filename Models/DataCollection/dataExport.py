
# export of data from raw db

import pymongo


def export_redbook_as_csv(fields,file) :
    mongo = pymongo.MongoClient('localhost', 29019)
    database = mongo['redbook']

    projection = {}
    for field in fields :
        projection[field]=1

    data = database.raw.find({"year":"2012","id":{"$regex":"'[0-9]*'"}},projection)

    writer = open(file,'w')

    for row in [data[k] for k in range(20)] :
        for i in range(len(fields)) :
            writer.write(row[fields[i]])
            if i < len(fields)-1:
                writer.write(";")
            else :
                writer.write("\n")


export_redbook_as_csv(['id','grant_date','app_date'],'export/redbook.csv')
