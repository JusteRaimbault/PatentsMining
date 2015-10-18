
import nltk,sqlite3,time,locale,datetime

# issue with multithreading
#from multiprocessing import Pool



# tests

def test():
    #test_kw()
    #test_db()
    test_dico()

def test_dico():
    construct_occurrence_dico(2000,100)

def test_db():
    for patent in get_patent_data(2000,100):
        print(patent)


def test_kw():
    def f(patent):
        return extract_keywords(patent[1]+". "+patent[2],patent[0])

    p = Pool(4)
    print(p.map(f, get_patent_data(2000,1000)))



## Functions

def construct_occurrence_dico(year,limit) :
    data = get_patent_data(year,limit)
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


    print(p_kw_dico.keys())
    print(p_kw_dico.values())
    #print(map(lambda l : len(l),dico.values()))

    # write to file
    p_kw = open('../../Data/processed/test_pkw_'+str(year)+'_'+str(limit)+'_'+str(datetime.datetime.now())+'.csv','w')
    kw_p = open('../../Data/processed/test_kwp_'+str(year)+'_'+str(limit)+'_'+str(datetime.datetime.now())+'.csv','w')

    for k in p_kw_dico.keys():
        p_kw.write(k)
        for kw in p_kw_dico[k]:
            p_kw.write(kw)
        p_kw.write('\n')

    for k in kw_p_dico.keys():
        kw_p.write(k)
        for kw in kw_p_dico[k]:
            kw_p.write(kw)
        kw_p.write('\n')


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
