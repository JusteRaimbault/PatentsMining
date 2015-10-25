
import nltk,sqlite3,time,locale,datetime

# issue with multithreading
#from multiprocessing import Pool



# tests

def test():
    #test_kw()
    #test_db()
    test_dico()

def test_dico():
    construct_occurrence_dico(2000,1000)

def test_db():
    for patent in get_patent_data(2000,100):
        print(patent)


def test_kw():
    def f(patent):
        return extract_keywords(patent[1]+". "+patent[2],patent[0])

    p = Pool(4)
    print(p.map(f, get_patent_data(2000,1000)))



## Functions


# tests for a bootstrap technique to avoid subcorpus relevance bias
def bootstrap_subcorpuses(corpus,kwLimit,subCorpusSize,bSize):
    N = len(corpus)

    # generate bSize extractions
    #extractions =

    # for each extraction, extract subcorpus and get relevant kws

    # then for each patent, mean termhoods, and recompute relevant keywords ?





# extract relevant keywords, using unithood and termhood
def extract_relevant_keywords(corpus,kwLimit):
    [p_kw_dico,kw_p_dico]=construct_occurrence_dico(corpus)
    # compute unithoods
    unithoods = dict()
    for k in kw_p_dico.keys():
        # TODO
        l = 1 # l = len(strsplit(k,' '))
        unithoods[k]=log(l+1)*len(kw_p_dico[k])
    # sort and keep K*N keywords
    ## TODO
    selected_kws = dict()
    # dictionary : kw -> index in matrix

    # compute termhoods :: coocurrence matrix -> in \Theta(16 N^2) - N must thus stay 'small'
    cooccs = []
    for i in range(len(selected_kws.keys())):
        cooccs.append(([0]*len(selected_kws.keys())))
    # fill the cooc matrix
    # for each patent : kws are coocurring if selected.
    # Beware to filter BEFORE launching O(n^2) procedure

    for p in p_kw_dico.keys() :
        sel = []
        for k in p_kw_dico[p] :
            if k in selected_kws : sel.append(k)
        for i in range(1,len(sel)-1):
            for j in range(i+1,len(sel)):
                ii = selected_kws[sel[i]] ; jj= selected_kws[sel[j]] ;
                cooccs[ii][jj] = cooccs[ii][jj] + 1
                cooccs[jj][ii] = cooccs[jj][ii] + 1

    # compute termhoods
    colSums = [sum(row) for row in cooccs]

    termhoods = [0]*len(cooccs)
    for i in range(len(coocs)):
        s = 0;
        for j in range(len(coocs)):
            if j != i : s = s + (cooccs[i][j]-colSums[i]*colSums[j])^2/(colSums[i]*colSums[j])
        termhoods[i]=s

    # sort and filter on termhoods
    # TODO
    tselected = dict()

    # reconstruct the patent -> tselected dico, finally necessary to build kw nw
    p_tsel_dico = dict()
    for p in p_kw_dico.keys() :
        sel = []
        for k in p_kw_dico[p] :
            if k in selected_kws : sel.append(k)
        p_tsel_dico[p] = sel

    # eventually write to file ? -> do that in other proc (! atomicity)
    return(p_tsel_dico)


#
def construct_occurrence_dico(data) :
    #data = get_patent_data(year,limit)
    p_kw_dico = dict()
    kw_p_dico = dict()
    for patent in data :
        patent_id = patent[0].encode('ascii','ignore')
        keywords = extract_keywords(patent[1]+". "+patent[2],patent_id)
        print(keywords)

        for w in keywords :
            k = reduce(lambda s1,s2 : s1+' '+s2,w)
            # add to p_kw dico
            if k in kw_p_dico :
                kw_p_dico[k].append(patent_id)
            else :
                kw_p_dico[k]= [patent_id]

            #
            if patent_id in p_kw_dico :
                p_kw_dico[patent_id].append(k)
            else :
                p_kw_dico[patent_id] = [k]

    return([p_kw_dico,kw_p_dico])
    #print(p_kw_dico.keys())
    #print(p_kw_dico.values())
    #print(map(lambda l : len(l),dico.values()))

    # write to file
    #export_dico_csv(p_kw_dico,'../../Data/processed/test_pkw_'+str(year)+'_'+str(limit))
    #export_dico_csv(kw_p_dico,'../../Data/processed/test_kwp_'+str(year)+'_'+str(limit))



# Exports a dictionary to a generalized csv, under the form key;val1;val2;...;valN
def export_dico_csv(dico,fileprefix):
    outfile=open(fileprefix+str(datetime.datetime.now())+'.csv','w')
    for k in dico.keys():
        outfile.write(k+";")
        for kw in dico[k]:
            outfile.write(kw+";")
        outfile.write('\n')


def get_patent_data(year,limit) :
    # connect to the database
    conn = sqlite3.connect('../../Data/raw/patdesc/patdesc.sqlite3')
    cursor = conn.cursor()
    # attach patent data
    cursor.execute('ATTACH DATABASE \'../../Data/raw/patent/patent.sqlite3\' as \'patent\'')

    #cursor.execute('SELECT patdesc.patent,patent.patent FROM patent,patdesc WHERE patent.patent=patdesc.patent LIMIT 10;')
    # retrieve records
    query='SELECT patent.patent,title,abstract,GYear FROM patdesc,patent WHERE patdesc.patent = patent.patent AND abstract!=\'\' AND GYear = '+str(year)
    if limit != -1 :
        query = query+' LIMIT '+str(limit)+";"
    else :
        query = query+";"
    cursor.execute(query)
    res=cursor.fetchall()
    #first=res[0]
    #raw_text = first[0]+". "+first[1]
    return res


# tagged of the form (word,TAG)
def potential_multi_term(tagged) :
    res = True
    for tag in tagged :
        res = res and (tag[1]=='NN' or tag[1]=='NNP' or tag[1] == 'VBG' or tag[1] =='NNS'or tag[1] =='JJ' or tag[1] =='JJR')
    return res

#print(res)
def extract_keywords(raw_text,id):

    print("Extracting keywords for "+id)

    stemmer = nltk.PorterStemmer()

    #keywords = []

    # construct text
    text = nltk.Text(nltk.word_tokenize(raw_text))
    #print(text.tokens)

    # tag
    #   interesting tags are :

    tagged_text = nltk.pos_tag(text)
    #nouns = [tg[0] for tg in tagged_text if tg[1]=='NN' or tg[1]=='NNP' ]
    #print(nouns)

    # multi-term
    multiterms = []
    for i in range(len(tagged_text)) :
        # max length 4 for multi-terms
        for l in range(1,5) :
            if i+l < len(tagged_text) :
                tags = [tagged_text[k] for k in range(i,i+l)]
                if potential_multi_term(tags) :
                    multistem = [str.lower(stemmer.stem(tagged_text[k][0]).encode('ascii','ignore')) for k in range(i,i+l)]
                    multistem.sort(key=str.lower)
                    multiterms.append(multistem)

    return multiterms


def main():
    #print(extract_keywords(raw_text))
    start = time.time()

    test()

    print(time.time() - start)


main()
