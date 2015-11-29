
import nltk,sqlite3,time,locale,datetime,operator,math

# issue with multithreading
#from multiprocessing import Pool



# tests

def test():
    test_dico()
    #import_kw_dico('../../data/processed/keywords.sqlite3')


def test_termhood_extract():
    corpus = get_patent_data(2000,3000)
    [relevantkw,relevant_dico] = extract_relevant_keywords(corpus,2000)
    #for k in relevant_dico.keys():
    #    print(k+' : '+str(relevant_dico[k]))
    export_dico_csv(relevant_dico,'../../data/processed/relevantDico_y2000_size1000_kwLimit200')
    export_list(relevantkw,'../../data/processed/relevantkw_y2000_size1000_kwLimit200')

def extract_all_keywords() :
    corpus = get_patent_data(-1,-1)
    [p_kw_dico,kw_p_dico] = construct_occurrence_dico(corpus)
    export_kw_dico('../../data/processed/keywords.sqlite3',p_kw_dico)

def test_dico():
    # with export
    corpus = get_patent_data(2007,1000)
    [p_kw_dico,kw_p_dico] = construct_occurrence_dico(corpus)
    export_kw_dico('../../data/processed/keywords_y2007_1000.sqlite3',p_kw_dico)

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
def bootstrap_subcorpuses(corpus,kwLimit,subCorpusSize,bootstrapSize):
    N = len(corpus)

    # compute occurence_dicos
    #  TODO : store results in db or file to not recompute them at each step.
    occurence_dicos = construct_occurrence_dico(corpus)

    # generate bSize extractions
    #   -> random subset of 1:N of size subCorpusSize
    # TODO
    extractions = []

    mean_termhoods = dict() # mean termhoods progressively updated
    p_kw_dico = dict() # patent -> kw dico : cumulated on repetitions. if a kw is relevant a few time, counted as 0 in mean.
    # for each extraction, extract subcorpus and get relevant kws
    # for each patent, mean termhoods computed cumulatively, ; recompute relevant keywords later
    for extraction in extractions :
        subcorpus = [corpus[i] for i in extraction]
        [keywords,p_kw_local_dico] = extract_relevant_keywords(subcorpus,kwLimit,occurence_dicos)

        # add termhoods
        for kw in keywords.keys() :
            if kw not in mean_termhoods : mean_termhoods[kw] = 0
            mean_termhoods[kw] = mean_termhoods[kw] + keywords[kw]

        # update p->kw dico
        for p in p_kw_local_dico.keys() :
            print('')
            #TODO



# extract relevant keywords, using unithood and termhood
#  @returns [tselected,p_tsel_dico] : dico kw -> termhood ; dico patent -> kws
def extract_relevant_keywords(corpus,kwLimit,occurence_dicos):
    print('Extracting relevant keywords...')
    #[p_kw_dico,kw_p_dico]=construct_occurrence_dico(corpus) # DO NOT RECOMPUTE OCCURRENCES AT EACH STEP !

    [p_kw_dico,kw_p_dico] = extract_sub_dicos(corpus,occurence_dicos)

    # compute unithoods
    print('Compute unithoods...')
    unithoods = dict()
    for k in kw_p_dico.keys():
        l = len(k.split(' '))
        unithoods[k]=math.log(l+1)*len(kw_p_dico[k])

    # sort and keep K*N keywords ; K = 4 for now ?
    selected_kws = dict() # dictionary : kw -> index in matrix
    sorted_unithoods = sorted(unithoods.items(), key=operator.itemgetter(1),reverse=True)
    for i in range(4*kwLimit):
        selected_kws[sorted_unithoods[i][0]] = i

    # computing cooccurrences
    print('Computing cooccurrences...')
    # compute termhoods :: coocurrence matrix -> in \Theta(16 N^2) - N must thus stay 'small'
    coocs = []
    for i in range(len(selected_kws.keys())):
        coocs.append(([0]*len(selected_kws.keys())))
    # fill the cooc matrix
    # for each patent : kws are coocurring if selected.
    # Beware to filter BEFORE launching O(n^2) procedure

    for p in p_kw_dico.keys() :
        sel = []
        for k in p_kw_dico[p] :
            if k in selected_kws : sel.append(k)
        for i in range(len(sel)-1):
            for j in range(i+1,len(sel)):
                ii = selected_kws[sel[i]] ; jj= selected_kws[sel[j]] ;
                coocs[ii][jj] = coocs[ii][jj] + 1
                coocs[jj][ii] = coocs[jj][ii] + 1

    # compute termhoods
    colSums = [sum(row) for row in coocs]

    termhoods = [0]*len(coocs)
    for i in range(len(coocs)):
        s = 0;
        for j in range(len(coocs)):
            if j != i : s = s + (coocs[i][j]-colSums[i]*colSums[j])^2/(colSums[i]*colSums[j])
        termhoods[i]=s

    # sort and filter on termhoods
    sorting_termhoods = dict()
    for k in selected_kws.keys():
        sorting_termhoods[k]=termhoods[selected_kws[k]]
    sorted_termhoods = sorted(sorting_termhoods.items(), key=operator.itemgetter(1),reverse=True)

    tselected = dict()
    for i in range(kwLimit):
        tselected[sorted_termhoods[i][0]] = sorted_termhoods[i][1]

    # reconstruct the patent -> tselected dico, finally necessary to build kw nw
    p_tsel_dico = dict()
    for p in p_kw_dico.keys() :
        sel = []
        for k in p_kw_dico[p] :
            if k in tselected : sel.append(k)
        p_tsel_dico[p] = sel

    # eventually write to file ? -> do that in other proc (! atomicity)
    return([tselected,p_tsel_dico])




##
#  Given large occurence dico, extracts corresponding subdico
#  assumes large dicos contains all subcorpus.
#   -- dirty but obliged for bootstraping --
#
#  @returns [p_kw_dico,kw_p_dico]
def extract_sub_dicos(corpus,occurence_dicos) :
    p_kw_dico_all = occurence_dicos[0]
    kw_p_dico_all = occurence_dicos[1]

    p_kw_dico = dict()
    kw_p_dico = dict()

    for patent in corpus :
        patent_id = get_patent_id(patent)
        keywords =  p_kw_dico_all[patent_id]
        p_kw_dico[patent_id] = keywords
        for k in keywords :
            if k not in kw_p_dico : kw_p_dico[k] = []
            kw_p_dico[k].append(patent_id)

    return([p_kw_dico,kw_p_dico])







##
#  Constructs occurrence dicos from raw data
def construct_occurrence_dico(data) :
    print('Constructing occurence dictionnaries...')

    p_kw_dico = dict()
    kw_p_dico = dict()
    for patent in data :
        patent_id = get_patent_id(patent)
        keywords = extract_keywords(patent[1]+". "+patent[2],patent_id)
        #print(keywords)

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

##
#  exports a dico to sqlite db
#  (to avoid reprocessing)
def export_kw_dico(database,p_kw_dico) :
    conn = sqlite3.connect(database)
    c = conn.cursor()

    # create the table
    c.execute('CREATE TABLE keywords (id text, keywords text)');

    for p in p_kw_dico.keys() :
        k = reduce(lambda s1,s2 : s1+';'+s2,p_kw_dico[p])
        query = "INSERT INTO keywords VALUES (\'"+p+"\',\'"+k+"\')"
        print(query)
        c.execute(query)

    # commit and close
    conn.commit()
    conn.close()

##
#  import dictionnaries from sqlite db ; table assumed as keywords = (patent_id ; keywords separated by ';')
def import_kw_dico(database) :
    conn = sqlite3.connect(database)
    c = conn.cursor()
    c.execute('SELECT * FROM keywords;')
    res = c.fetchall()

    p_kw_dico = dict()
    kw_p_dico = dict()

    for row in res :
        patent_id = row[0].encode('ascii','ignore')
        print(patent_id)
        keywords = row[1].encode('ascii','ignore').split(';')
        p_kw_dico[patent_id] = keywords
        for kw in keywords :
            if kw not in kw_p_dico : kw_p_dico[kw] = []
            kw_p_dico[kw].append(kw)

    return([p_kw_dico,kw_p_dico])


# get patent id
def get_patent_id(cursor_raw):
    return(cursor_raw[0].encode('ascii','ignore'))



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

    # Construct text

    # Tokens
    tokens = nltk.word_tokenize(raw_text)
    # filter undesirable words and format
    words = [w.replace('\'','') for w in tokens if len(w)>=3]
    text = nltk.Text(words)

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

    # import utils
    execfile('../Utils/utils.py')

    start = time.time()

    test()

    print('Ellapsed Time : '+str(time.time() - start))


main()
