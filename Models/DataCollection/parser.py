# -*- coding: utf-8 -*-

# parsers for various file types


def parse_file(f) :
    if f.endswith('.dat') : parse_dat_file(f)
    if f.endswith('.xml') : parse_xml_file(f)


def parse_dat_file(f,year):
    res = []
    f = open(f,'r')
    currentLine = f.readline().replace('\n',' ')
    currentPatent = {'abstract':''}
    while currentLine != '' :
        # if PATN -> store in res
        if currentLine.startswith('PATN') and currentPatent !=  {'abstract':''} :
            currentPatent['year']=year
            res.append(currentPatent)
            currentPatent = {'abstract':''};
        if currentLine.startswith('WKU') :
            currentPatent['id'] = currentLine.split('  ')[1]
            print(currentLine.split('  ')[1])
        if currentLine.startswith('ISD') :
            currentPatent['date'] = currentLine.split('  ')[1]
        if currentLine.startswith('ABST') :
            currentLine = f.readline().replace('\n',' ')
            while not currentLine.startswith('PATN') and currentLine != '' :
                currentPatent['abstract'] = currentPatent['abstract']+currentLine.replace('PAL','').replace('    ','').replace('  ','')
                currentLine = f.readline().replace('\n',' ')
        else :
            currentLine = f.readline().replace('\n',' ')
    currentPatent['year']=year;res.append(currentPatent)
    return(res)

t = parse_dat_file('test/data/2001.dat',2001)
for r in t :
    print(' id : '+r['id']+" ; abstract : "+r['abstract'])
print(len(t))



def parse_xml_file :
    schema = ''
