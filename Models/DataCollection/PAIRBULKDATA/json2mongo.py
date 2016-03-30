
# conversion of full json PAIR bulk data directory to mongo db, with projection

import os,json

dir = 'test'

files = os.listdir(dir)

for f in files :
    print('processing file : '+str(f))
    freader = open(dir+'/'+f)
    o = json.load(freader)
    odata = o['PatentBulkData']
    for i in range(len(odata)):
	patentid=None;gdate=None;classes=None
	try:
	    patentid = odata[i]['applicationDataOrProsecutionHistoryDataOrPatentTermData'][0]['patentGrantIdentification']['patentNumber']
	    #print(patentid)
	except Exception :
            patentid=None
	    #print('fail')
	try:
	    gdate = odata[i]['applicationDataOrProsecutionHistoryDataOrPatentTermData'][0]['patentGrantIdentification']['grantDate']
	    #print(gdate)
	except Exception :
            gdate=None
	    #print('fail')
	try:
	    oclasses = odata[i]['applicationDataOrProsecutionHistoryDataOrPatentTermData'][0]['patentClassificationBag']['cpcClassificationBagOrIPCClassificationOrECLAClassificationBag'][0]['ipcrClassification']
	    classes=[]
	    for j in range(len(oclasses)):
		classes.append(oclasses[j]['patentClassificationText'].encode('utf8'))
	    #print(classes)
	except Exception :
            classes=None
	    #print('fail')    
	print('id : '+str(patentid)+'; gdate : '+str(gdate)+' ; classes :  '+str(classes))
	#except Exception :
	#    print('fail')


