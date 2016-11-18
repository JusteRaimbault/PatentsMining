import datetime,sqlite3

# Exports a dictionary to a generalized csv, under the form key;val1;val2;...;valN
def export_dico_csv(dico,fileprefix):
    outfile=open(fileprefix+str(datetime.datetime.now())+'.csv','w')
    for k in dico.keys():
        outfile.write(k+";")
        for kw in dico[k]:
            outfile.write(kw+";")
        outfile.write('\n')

def export_list(l,fileprefix):
    outfile=open(fileprefix+str(datetime.datetime.now())+'.csv','w')
    for k in l :
        outfile.write(k+'\n')

# read a csv file as list of lists
def read_csv(file,delimiter):
    f=open(file,'r')
    lines = f.readlines()
    return([s.replace('\n','').split(delimiter) for s in lines])




def implode(l,delimiter):
    res=''
    i=0
    for k in l:
        res = res+str(k)
        if i<len(l)-1 : res=res+delimiter
    return(res)
