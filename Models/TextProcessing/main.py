import time,bootstrap

# import nltk,sqlite3,time,locale,datetime,operator,math,numpy


def run():
    #test_dico()
    #import_kw_dico('../../data/processed/keywords.sqlite3')
    #extract_all_keywords()
    #termhood_extraction()
    #bootstrap.test_bootstrap()
    bootstrap.init_bootstrap('bootstrap/test')
    bootstrap.run_bootstrap('bootstrap/test',10,10,2)
    #bootstrap.run_bootstrap('bootstrap/run_kw1000_csize2000_b20',1000,2000,20)

def main():

        start = time.time()

        run()

        print('Ellapsed Time : '+str(time.time() - start))


main()
