import nltk,operator,math,pymongo
import data,keywords,utils



## -- Issue with // processing --
#def test_kw():
#    def f(patent):
#        return extract_keywords(patent[1]+". "+patent[2],patent[0])
#
#    p = Pool(4)
#    print(p.map(f, get_patent_data(2000,1000)))






def termhood_extraction():
    corpus = io.get_patent_data(2000,10000)
    dicos = io.import_kw_dico('../../Data/processed/keywords_y2000_10000.sqlite3')
    [relevantkw,relevant_dico] = keywords.extract_relevant_keywords(corpus,1000,dicos)
    #for k in relevant_dico.keys():
    #    print(k+' : '+str(relevant_dico[k]))
    utils.export_dico_csv(relevant_dico,'../../data/processed/relevantDico_y2000_size10000_kwLimit4000')
    utils.export_list(relevantkw,'../../data/processed/relevantkw_y2000_size10000_kwLimit4000')

def extract_all_keywords() :
    corpus = get_patent_data(2000,10000)
    [p_kw_dico,kw_p_dico] = construct_occurrence_dico(corpus)
    export_kw_dico('../../Data/processed/keywords_y2000_10000.sqlite3',p_kw_dico)

def extract_remaining_keywords() :
    mongo = pymongo.MongoClient()
    existing = mongo['patents_keywords'].keywords.find({},{'id'})


def extract_keywords_year(year):
    corpus = data.get_patent_data(year,0)
    print 'corpus size : '+str(len(corpus))
    [p_kw_dico,kw_p_dico] = construct_occurrence_dico(corpus)
    data.export_kw_dico('patent','keywords',p_kw_dico,year)


# extract relevant keywords, using unithood and termhood
#  @returns [tselected,p_tsel_dico] : dico kw -> termhood ; dico patent -> kws
def extract_relevant_keywords(corpus,kwLimit,occurence_dicos):
    print('Extracting relevant keywords...')
    #[p_kw_dico,kw_p_dico]=construct_occurrence_dico(corpus) # DO NOT RECOMPUTE OCCURRENCES AT EACH STEP !

    [p_kw_dico,kw_p_dico] = extract_sub_dicos(corpus,occurence_dicos)

    # compute frequencies
    print('Compute frequencies...')
    docfrequencies = {}
    for k in kw_p_dico.keys():
        docfrequencies[k] = len(kw_p_dico[k])

    # compute unithoods
    print('Compute unithoods...')
    unithoods = dict()
    for k in kw_p_dico.keys():
        l = len(k.split(' '))
        unithoods[k]=math.log(l+1)*len(kw_p_dico[k])

    # sort and keep K*N keywords ; K = 4 for now ?
    selected_kws = {} # dictionary : kw -> index in matrix
    #selected_kws_indexes = {} # dico index -> kw.  Q : use kw as keys in cooc matrix ?
    #  seems to be even more performant
    sorted_unithoods = sorted(unithoods.items(), key=operator.itemgetter(1),reverse=True)
    for i in range(4*kwLimit):
        selected_kws[sorted_unithoods[i][0]] = i
        #selected_kws.append(sorted_unithoods[i][0])

    # computing cooccurrences
    print('Computing cooccurrences...')
    # compute termhoods :: coocurrence matrix -> in \Theta(16 N^2) - N must thus stay 'small'
    coocs = {}

    #for i in range(len(selected_kws.keys())):
    #    coocs.append(([0]*len(selected_kws.keys())))
    # fill the cooc matrix
    # for each patent : kws are coocurring if selected.
    # Beware to filter BEFORE launching O(n^2) procedure

    n=len(p_kw_dico)/100;pr=0
    for p in p_kw_dico.keys() :
        pr = pr + 1
        if pr % n == 0 : print('cooccs : '+str(pr/n)+'%')
        sel = []
        for k in p_kw_dico[p] :
            if k in selected_kws : sel.append(k)
        for i in range(len(sel)-1):
            #ii = selected_kws[sel[i]]
            ki = sel[i]
            if ki not in coocs : coocs[ki] = {}
            for j in range(i+1,len(sel)):
                kj= sel[j]
                if kj not in coocs : coocs[kj] = {}
                if kj not in coocs[ki] :
                    coocs[ki][kj] = 1
                else :
                    coocs[ki][kj] = coocs[ki][kj] + 1
                if ki not in coocs[kj] :
                    coocs[kj][ki] = 1
                else :
                    coocs[kj][ki] = coocs[kj][ki] + 1

    # compute termhoods
    #colSums = [sum(row) for row in coocs]
    colSums = {}
    for ki in coocs.keys():
        colSums[ki] = sum(coocs[ki].values())

    #termhoods = [0]*len(coocs.keys())
    termhoods = {}
    for ki in coocs.keys():
        s = 0;
        for kj in coocs[ki].keys():
            if kj != ki : s = s + ((coocs[ki][kj]-colSums[ki]*colSums[kj])*(coocs[ki][kj]-colSums[ki]*colSums[kj]))/(colSums[ki]*colSums[kj])
        termhoods[ki]=s

    # sort and filter on termhoods
    #sorting_termhoods = {}
    #for k in selected_kws.keys():
    #    sorting_termhoods[k]=termhoods[selected_kws[k]]

    [tselected,dico,freqselected] = extract_from_termhood(termhoods,p_kw_dico,docfrequencies,kwLimit)

    # construct graph edge list (! undirected)
    edge_list = []
    for kw in tselected.keys():
        for ki in coocs[kw].keys():
            if ki in tselected :
                edge_list.append({'edge' : kw+";"+ki, 'weight' : coocs[kw][ki]})


    return([tselected,dico,freqselected,edge_list])


def extract_from_termhood(termhoods,p_kw_dico,frequencies,kwLimit):
    sorted_termhoods = sorted(termhoods.items(), key=operator.itemgetter(1),reverse=True)

    tselected = {}
    freqselected = {}
    for i in range(kwLimit):
        tselected[sorted_termhoods[i][0]] = sorted_termhoods[i][1]
        freqselected[sorted_termhoods[i][0]] = frequencies[sorted_termhoods[i][0]]

    # reconstruct the patent -> tselected dico, finally necessary to build kw nw
    p_tsel_dico = dict()
    for p in p_kw_dico.keys() :
        sel = []
        for k in p_kw_dico[p] :
            if k in tselected and k not in sel : sel.append(k)
        p_tsel_dico[p] = sel

    # eventually write to file ? -> do that in other proc (! atomicity)
    return([tselected,p_tsel_dico,freqselected])

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
        patent_id = data.get_patent_id(patent)
        keywords = []
	if patent_id in p_kw_dico_all : keywords = p_kw_dico_all[patent_id]
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
        patent_id = patent[0]#data.get_patent_id(patent)
        keywords = extract_keywords(patent[1]+". "+patent[2],patent_id)
        #print(keywords)

        for k in keywords :
            #k = reduce(lambda s1,s2 : s1+' '+s2,w)
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
    multiterms = set()
    for i in range(len(tagged_text)) :
        # max length 4 for multi-terms ==> 3
        for l in range(1,4) :
            if i+l < len(tagged_text) :
                tags = [tagged_text[k] for k in range(i,i+l)]
                if potential_multi_term(tags) :
                    multistem = [str.lower(stemmer.stem(tagged_text[k][0]).encode('ascii','ignore')) for k in range(i,i+l)]
                    #multistem.sort(key=str.lower)
                    multiterms.add(reduce(lambda s1,s2 : s1+' '+s2,multistem))

    return list(multiterms)
