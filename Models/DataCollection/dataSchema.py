
# data formatting for db insertion

from lxml import etree



def xml_projection(patent):
    return xml_25_projection(patent)




def xml_42_projection(patent):
    res = {}
    res['id'] =  text_leaves(xpath(patent ,['us-bibliographic-data-grant','publication-reference','document-id','doc-number'])).lstrip('0')
    res['grant_date'] = text_leaves(xpath(patent ,['us-bibliographic-data-grant','publication-reference','document-id','date']))
    res['app_date'] = text_leaves(xpath(patent ,['us-bibliographic-data-grant','application-reference','document-id','date']))
    res['abstract'] = text_leaves(xpath(patent ,['abstract']))
    res['title'] = text_leaves(xpath(patent ,['us-bibliographic-data-grant','invention-title']))
    #res['classes'] = [text_leaves(e) for e in multiple_xpath(patent,['SDOBI','B500','B520','B522','STEXT','PDAT'])]
    return res




def xml_41_projection(patent):
    res = {}
    res['id'] =  text_leaves(xpath(patent ,['us-bibliographic-data-grant','publication-reference','document-id','doc-number'])).lstrip('0')
    res['grant_date'] = text_leaves(xpath(patent ,['us-bibliographic-data-grant','publication-reference','document-id','date']))
    res['app_date'] = text_leaves(xpath(patent ,['us-bibliographic-data-grant','application-reference','document-id','date']))
    res['abstract'] = text_leaves(xpath(patent ,['abstract']))
    res['title'] = text_leaves(xpath(patent ,['us-bibliographic-data-grant','invention-title']))
    #res['classes'] = [text_leaves(e) for e in multiple_xpath(patent,['SDOBI','B500','B520','B522','STEXT','PDAT'])]
    return res


def xml_40_projection(patent):
    res = {}
    res['id'] =  text_leaves(xpath(patent ,['us-bibliographic-data-grant','publication-reference','document-id','doc-number'])).lstrip('0')
    res['grant_date'] = text_leaves(xpath(patent ,['us-bibliographic-data-grant','publication-reference','document-id','date']))
    res['app_date'] = text_leaves(xpath(patent ,['us-bibliographic-data-grant','application-reference','document-id','date']))
    res['abstract'] = text_leaves(xpath(patent ,['abstract']))
    res['title'] = text_leaves(xpath(patent ,['us-bibliographic-data-grant','invention-title']))
    #res['classes'] = [text_leaves(e) for e in multiple_xpath(patent,['SDOBI','B500','B520','B522','STEXT','PDAT'])]
    return res


##
# lxml object to data dico for one record
def xml_25_projection(patent):
    res = {}
    res['id'] =  text_leaves(xpath(patent ,['SDOBI','B100','B110','DNUM','PDAT'])).lstrip('0')
    res['grant_date'] = text_leaves(xpath(patent ,['SDOBI','B100','B140','DATE','PDAT']))
    res['app_date'] = text_leaves(xpath(patent ,['SDOBI','B200','B220','DATE','PDAT']))
    res['abstract'] = text_leaves(xpath(patent ,['SDOAB','BTEXT']))
    res['title'] = text_leaves(xpath(patent ,['SDOBI','B500','B540','STEXT','PDAT']))
    #res['classes'] = [text_leaves(e) for e in multiple_xpath(patent,['SDOBI','B500','B520','B522','STEXT','PDAT'])]
    return res




##
#  define a xpath function for non-html docs
def xpath(tree,path):
    element = tree
    for p in path :
        index = -1;i=0
        for child in element :
            if child.tag==p : index = i
            i=i+1
        if index ==-1 : return None
        element = element[index]
    return element



def multiple_xpath(tree,path):
    currentPaths = [[]]
    for p in path :
        nextPaths = []
        for currentPath in currentPaths :
            indexes = [];i=0
            for child in get_element(tree,currentPath) :
                if child.tag==p : indexes.append(i)
                i=i+1
            if indexes != [] :
                for i in indexes :
                    np = currentPath
                    np.append(i)
                    nextPaths.append(np)
        currentPaths = nextPaths
        print currentPaths
    return [get_element(tree,p) for p in currentPaths]


def get_element(tree,idpath):
    element = tree
    for i in idpath:
        print i
        element = element[i]
    return element

def text_leaves(element):
    if element is None : return ''
    if len(element)==0 :
        if element.text is None :
            return ''
        else :
            return element.text
    text = ''
    for child in element :
        if (child.text!= None) :
            text = text+' '+child.text
        else :
            text = text+' '+str(text_leaves(child))
    return text



def dat_projection(patent):
    res = {}
    for k in patent.keys() :
        if k=='WKU' :
            res['id'] = patent[k].lstrip('0')[:7]
        elif k=='ISD' :
            res['grant_date']=patent[k]
        elif k=='APD' :
            res['app_date']=patent[k]
        elif k=='ABST' :
            abstract = patent[k]
	    print patent
            text = ""
            additional = {}
            for kk in abstract.keys():
                if kk=='EQU' or kk=='TBL' :
                    additional[kk] = abstract[kk]
                else :
                    text = text+' '+reduce_field(abstract[kk])
            res['abstract']=text.lstrip()
            res['additional']=additional
        elif k=='CLAS' :
            res['classes']=patent[k]
        elif k=='TTL' :
            res['title']=patent[k]
        else :
            res[k]=patent[k]
    return(res)

def reduce_field(l) :
    if type(l)==type([]) :
        return(reduce(lambda s1,s2 : s1+' '+s2,l))
    else :
        return(l)
