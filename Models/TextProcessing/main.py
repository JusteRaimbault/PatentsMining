import time

# tests

def run():
    #test_dico()
    #import_kw_dico('../../data/processed/keywords.sqlite3')
    #extract_all_keywords()
    #termhood_extraction()
    test_bootstrap()





def main():

        # import utils
        execfile('../Utils/utils.py')

        start = time.time()

        run()

        print('Ellapsed Time : '+str(time.time() - start))


main()
