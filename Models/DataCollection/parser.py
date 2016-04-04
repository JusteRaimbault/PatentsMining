# -*- coding: utf-8 -*-

# parsers for various file types

#import re
import dataSchema
#import codecs
from lxml import etree
from io import StringIO

def parse_file(f) :
    if f.endswith('.dat') : return parse_dat_file(f)
    if f.endswith('.xml') : return parse_xml_file(f)


def parse_xml_file(f,year):
    proj_data = [dataSchema.xml_projection(r) for r in parse_xml_file_raw(f)]
    for r in proj_data :
        r['year']=year
    return(proj_data)



def parse_xml_file_raw(f) :
    # read the file
    print 'reading file'+str(f)
    r=open(f,'r')
    docs = []
    currentLine=r.readline().replace('&','&amp;');currentDoc=''#currentLine
    while currentLine != '':
        currentLine=r.readline().replace('&','&amp;');
        if currentLine.startswith('<?xml version="1.0" encoding="UTF-8"?>') :
            docs.append(currentDoc)
            currentLine=r.readline().replace('&','&amp;');
            currentDoc = ''
        currentDoc=currentDoc+currentLine
    docs.append(currentDoc)
    print len(docs)
    parsed_docs = []
    for doc in docs :
        parser = etree.XMLParser(resolve_entities=True,attribute_defaults=True)
        tree = etree.parse(StringIO(doc.decode('utf8')))
        parsed_docs.append(tree.getroot())
        #print etree.tostring(tree)
    return parsed_docs



def parse_dat_file(f,year):
    proj_data = [dataSchema.dat_projection(parse_sub_fields(r)) for r in read_dat_as_raw(f)]
    for r in proj_data :
        r['year']=year
    return(proj_data)

    #for r in read_dat_as_raw(f):
        #print(r)
        #print('\n-----------\n')
        #sf = parse_sub_fields(r)
        #print(dataSchema.dat_projection(sf))
        #print(sf)
        #print(sf['WKU'])
        #if 'ABST' in sf and len(sf['ABST']) > 1 :
        #    print sf['ABST'].keys()
        #if 'CLAS' in sf : print(sf['CLAS'])
        #print('\n===========\n')




def read_dat_as_raw(f) :
    print 'reading file '+str(f)
    res = []
    r = open(f,'r')
    r.readline()
    currentLine = r.readline().replace('\n','')
    currentPatent = []
    while currentLine != '':
        if currentLine.startswith('PATN'):
            res.append(currentPatent)
            currentPatent = []
        else :
            currentPatent.append(currentLine)
        currentLine = r.readline().replace('\n','')
    res.append(currentPatent)
    return res

def parse_sub_fields(raw):
    #print raw
    res = {}
    if len(raw)==0 : return res
    currentField = [raw[0]]
    i=1
    singleRecords = False
    if len(raw)>1 : singleRecords = len(raw[i].split(' '))>1
    while i<len(raw) and singleRecords :
        if raw[i].startswith(' '):
            currentField.append(raw[i])
        else :
            [fieldName,fieldValue] = parse_field(currentField)
            res = append_dico(res,fieldName,fieldValue)
            currentField=[raw[i]]
        i = i+1
        if i<len(raw): singleRecords = len(raw[i].split(' '))>1
    [fieldName,fieldValue] = parse_field(currentField)
    res = append_dico(res,fieldName,fieldValue)
    if i<len(raw):
        currentField = [raw[i]]
        for j in range(i+1,len(raw)):
            if len(raw[j].split(' '))==1 :
                [fieldName,fieldValue] = parse_field(currentField)
                res = append_dico(res,fieldName,fieldValue)
                currentField=[]
            currentField.append(raw[j])
        [fieldName,fieldValue] = parse_field(currentField)
        res = append_dico(res,fieldName,fieldValue)
    return(res)


def parse_field(rows) :
    if len(rows)==1:
        return(split_field(rows[0]))
    else :
        if len(rows[0].split(' '))>1:
            [fieldName,row1]=split_field(rows[0])
            return [fieldName,row1+' '+reduce(lambda s1,s2 : s1.lstrip()+' '+s2.lstrip(),[rows[j] for j in range(1,len(rows))])]
        else :
            fieldName = rows[0]
            subfields = {}
            currentSubField = split_field(rows[1])
            for j in range(2,len(rows)) :
                if rows[j].startswith(' '):
                    currentSubField = [currentSubField[0],currentSubField[1]+' '+rows[j].lstrip()]
                else :
                    subfields=append_dico(subfields,currentSubField[0],currentSubField[1])
                    currentSubField = split_field(rows[j])
            subfields=append_dico(subfields,currentSubField[0],currentSubField[1])
            return([fieldName,subfields])


def split_field(row) :
    s = row.split(' ',1)
    if len(s)>1 :
        return([s[0],s[1].lstrip()])
    else :
        return(s[0],'')


def append_dico(dico,key,value):
    if key in dico :
        l=dico[key]
        if type(l)!=type([]): l = [l]
        l.append(value)
        dico[key]=l
    else :
        dico[key] = value
    return(dico)
