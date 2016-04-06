
# export of data from raw db

import pymongo


def export_redbook_as_csv(fields,file) :
    mongo = pymongo.MongoClient('localhost', 29019)
    database = mongo['redbook']

    projection = {}
    for field in fields :
        projection[field]=1

    data = database.raw.find({"id":{"$regex":"[0-9]*"}},projection)

    writer = open(file,'w')

    for i in range(len(fields)) :
        writer.write(fields[i])
        if i < len(fields)-1:
            writer.write(";")
        else :
            writer.write("\n")

    for row in data :
        print row
	for i in range(len(fields)) :
            if fields[i] in row : writer.write(row[fields[i]])
            if i < len(fields)-1:
                writer.write(";")
            else :
                writer.write("\n")


export_redbook_as_csv(['id','grant_date','app_date'],'export/redbook.csv')
