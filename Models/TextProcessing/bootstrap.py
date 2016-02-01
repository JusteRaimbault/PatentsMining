import numpy
import utils,io,keywords



def run_bootstrap(kwLimit,subCorpusSize,bootstrapSize):
    corpus = io.get_patent_data(-1,-1,False)
    bootstrap_subcorpuses(corpus,kwLimit,subCorpusSize,bootstrapSize)




def test_bootstrap():
    year = -1
    N = -1
    kwLimit=50000
    subCorpusSize=100000
    bootstrapSize=100
    corpus = get_patent_data(year,N,False)
    [relevantkw,relevant_dico] = bootstrap_subcorpuses(corpus,kwLimit,subCorpusSize,bootstrapSize)
    export_dico_csv(relevant_dico,'res/bootstrap_relevantDico_y'+str(year)+'_size'+str(N)+'_kwLimit'+str(kwLimit)+'_subCorpusSize'+str(subCorpusSize)+'_bootstrapSize'+str(bootstrapSize))
    export_list(relevantkw,'res/relevantkw_y'+str(year)+'_size'+str(N)+'_kwLimit'+str(kwLimit)+'_subCorpusSize'+str(subCorpusSize)+'_bootstrapSize'+str(bootstrapSize))







## Functions


# tests for a bootstrap technique to avoid subcorpus relevance bias
def bootstrap_subcorpuses(corpus,kwLimit,subCorpusSize,bootstrapSize):
    N = len(corpus)

    print('Bootstrapping on corpus of size '+str(N))


    # compute occurence_dicos
    # Results stored in db or file to not recompute them at each step.
    #occurence_dicos = construct_occurrence_dico(corpus)
    #occurence_dicos = import_kw_dico('../../Data/processed/keywords.sqlite3')
    occurence_dicos = io.import_kw_dico('data/keywords.sqlite3')

    # generate bSize extractions
    #   -> random subset of 1:N of size subCorpusSize
    extractions = [numpy.random.random_integers(0,(N-1),subCorpusSize) for b in range(bootstrapSize)]

    mean_termhoods = dict() # mean termhoods progressively updated
    p_kw_dico = dict() # patent -> kw dico : cumulated on repetitions. if a kw is relevant a few time, counted as 0 in mean.
    # for each extraction, extract subcorpus and get relevant kws
    # for each patent, mean termhoods computed cumulatively, ; recompute relevant keywords later

    for eind in range(len(extractions)) :
        print("bottstrap : run "+str(eind))
	extraction = extractions[eind]
        subcorpus = [corpus[i] for i in extraction]
        [keywords,p_kw_local_dico] = keywords.extract_relevant_keywords(subcorpus,kwLimit,occurence_dicos)

        # add termhoods
        for kw in keywords.keys() :
            if kw not in mean_termhoods : mean_termhoods[kw] = 0
            mean_termhoods[kw] = mean_termhoods[kw] + keywords[kw]

        # update p->kw dico
        for p in p_kw_local_dico.keys() :
            if p not in p_kw_dico : p_kw_dico[p] = set()
            for kw in p_kw_local_dico[p] :
		p_kw_dico[p].add(kw)

    # sort on termhoods (no need to normalize) adn returns
    return(extract_from_termhood(mean_termhoods,p_kw_dico,kwLimit))
