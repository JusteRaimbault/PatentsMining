import nltk,operator
import io,keywords,utils



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
            if j != i : s = s + ()(coocs[i][j]-colSums[i]*colSums[j])*(coocs[i][j]-colSums[i]*colSums[j]))/(colSums[i]*colSums[j])
        termhoods[i]=s

    # sort and filter on termhoods
    sorting_termhoods = dict()
    for k in selected_kws.keys():
        sorting_termhoods[k]=termhoods[selected_kws[k]]

    return(extract_from_termhood(sorting_termhoods,p_kw_dico,kwLimit))


def extract_from_termhood(termhoods,p_kw_dico,kwLimit):
    sorted_termhoods = sorted(termhoods.items(), key=operator.itemgetter(1),reverse=True)

    tselected = dict()
    for i in range(kwLimit):
        tselected[sorted_termhoods[i][0]] = sorted_termhoods[i][1]

    # reconstruct the patent -> tselected dico, finally necessary to build kw nw
    p_tsel_dico = dict()
    for p in p_kw_dico.keys() :
        sel = []
        for k in p_kw_dico[p] :
            if k in tselected and k not in sel : sel.append(k)
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
        patent_id = io.get_patent_id(patent)
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
        patent_id = io.get_patent_id(patent)
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
