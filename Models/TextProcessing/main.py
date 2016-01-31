import time,bootstrap

# import nltk,sqlite3,time,locale,datetime,operator,math,numpy


def run():
    #test_dico()
    #import_kw_dico('../../data/processed/keywords.sqlite3')
    #extract_all_keywords()
    #termhood_extraction()
    bootstrap.test_bootstrap()



def main():

        start = time.time()

        run()

        print('Ellapsed Time : '+str(time.time() - start))


main()
