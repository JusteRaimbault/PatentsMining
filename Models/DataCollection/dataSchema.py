
# data formatting for db insertion



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
