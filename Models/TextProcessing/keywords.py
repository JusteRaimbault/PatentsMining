import nltk,operator,math,pymongo,functools
import data,keywords,utils



##
# Extract keywords for a given year
def extract_keywords_year(year):
    corpus = data.get_patent_data('redbook','raw',[year],"app_year",0,full=True)
    print('corpus size : '+str(len(corpus)))
    [p_kw_dico,kw_p_dico,stem_dico] = construct_occurrence_dico(corpus)
    data.export_kw_dico('patent','keywords',p_kw_dico,year)
    data.export_set_dico('patent','stems',stem_dico,['stem','keywords'])












##
#  Constructs occurrence dicos from raw data
def construct_occurrence_dico(data) :
    print('Constructing occurence dictionnaries...')

    p_kw_dico = dict()
    kw_p_dico = dict()
    full_stem_dico = {}
    for patent in data :
        patent_id = patent[0]#data.get_patent_id(patent)
        [keywords,stem_dico] = extract_keywords(patent[1]+". "+patent[2],patent_id)
        #print(keywords)

        for k in keywords :
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

        for k in stem_dico.keys():
            if k in full_stem_dico :
                full_stem_dico[k]=full_stem_dico[k].union(stem_dico[k])
            else :
                full_stem_dico[k] = stem_dico[k]

    return([p_kw_dico,kw_p_dico,full_stem_dico])




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
    stem_dico = {}
    for i in range(len(tagged_text)) :
        # max length 4 for multi-terms ==> 3
        for l in range(1,4) :
            if i+l < len(tagged_text) :
                tags = [tagged_text[k] for k in range(i,i+l)]
                if potential_multi_term(tags) :
                    multistemlist = [str.lower(stemmer.stem(tagged_text[k][0])) for k in range(i,i+l)]
                    #multistem.sort(key=str.lower)
		    #python 3 : remove .encode('ascii','ignore')
                    multistem = functools.reduce(lambda s1,s2 : s1+' '+s2,multistemlist)
                    rawtext = functools.reduce(lambda s1,s2 : s1+' '+s2,[str.lower(tagged_text[k][0]) for k in range(i,i+l)])
                    multiterms.add(multistem)
                    if multistem in stem_dico :
                        stem_dico[multistem].add(rawtext)
                    else :
                        stem_dico[multistem] = set([rawtext])

    return [list(multiterms),stem_dico]



### DEPRECATED




## -- Issue with // processing --
#def test_kw():
#    def f(patent):
#        return extract_keywords(patent[1]+". "+patent[2],patent[0])
#
#    p = Pool(4)
#    print(p.map(f, get_patent_data(2000,1000)))




#def termhood_extraction():
#    corpus = io.get_patent_data(2000,10000)
#    dicos = io.import_kw_dico('../../Data/processed/keywords_y2000_10000.sqlite3')
#    [relevantkw,relevant_dico] = keywords.extract_relevant_keywords(corpus,1000,dicos)
#    #for k in relevant_dico.keys():
#    #    print(k+' : '+str(relevant_dico[k]))
#    utils.export_dico_csv(relevant_dico,'../../data/processed/relevantDico_y2000_size10000_kwLimit4000')
#    utils.export_list(relevantkw,'../../data/processed/relevantkw_y2000_size10000_kwLimit4000')
#
#def extract_all_keywords() :
#    corpus = get_patent_data(2000,10000)
#    [p_kw_dico,kw_p_dico] = construct_occurrence_dico(corpus)
#    export_kw_dico('../../Data/processed/keywords_y2000_10000.sqlite3',p_kw_dico)
#
#def extract_remaining_keywords() :
#    mongo = pymongo.MongoClient()
#    existing = mongo['patents_keywords'].keywords.find({},{'id'})
