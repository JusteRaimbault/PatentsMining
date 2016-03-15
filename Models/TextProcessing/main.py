import time,bootstrap



def run():
    #test_dico()
    #import_kw_dico('../../data/processed/keywords.sqlite3')
    #extract_all_keywords()
    #termhood_extraction()
    #bootstrap.test_bootstrap()
    #year=2005;limit=-1;kwLimit=3000;subCorpusSize=20000;bootstrapSize=10;nruns=2
    #year=2005;
    limit=-1;kwLimit=2000;subCorpusSize=10000;bootstrapSize=10;nruns=10 #test set
    #bootstrap.init_bootstrap(year,limit,kwLimit,subCorpusSize,bootstrapSize,nruns)
    for year in range(1975,2011) :
        bootstrap.run_bootstrap(year,limit,kwLimit,subCorpusSize,bootstrapSize,nruns)





def main():

        start = time.time()

        run()

        print('Ellapsed Time : '+str(time.time() - start))


main()
