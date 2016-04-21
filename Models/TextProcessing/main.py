import time,bootstrap,keywords
import sys


def run():
    f=open(sys.argv[1])
    kwLimit = 100000
    for year in f.readlines():
	print year
        bootstrap.relevant_full_corpus(str(year).replace('\n',''),kwLimit)
        #keywords.extract_keywords_year(str(year).replace('\n',''))
    #year=2005;limit=-1;kwLimit=3000;subCorpusSize=20000;bootstrapSize=10;nruns=2
    #year=2005;
    #kwLimit=20000
    #limit=-1;subCorpusSize=10000;bootstrapSize=10;nruns=10 #test set
    #bootstrap.init_bootstrap(year,limit,kwLimit,subCorpusSize,bootstrapSize,nruns)
    #for year in range(1998,2011) :
        #bootstrap.run_bootstrap(year,limit,kwLimit,subCorpusSize,bootstrapSize,nruns)
    #    bootstrap.relevant_full_corpus(year,kwLimit)





def main():

        start = time.time()

        run()

        print('Ellapsed Time : '+str(time.time() - start))


main()
