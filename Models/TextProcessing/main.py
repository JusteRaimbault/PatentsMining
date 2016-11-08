import time,bootstrap,keywords
import sys


def run():
    task = sys.argv[1]
    f=open(sys.argv[2])
    kwLimit = 100000
    edge_th = 10
    # multiple years : csv files
    for years in f.readlines():
        print('Years : '+str(years).replace('\n',''))
        if task=='--relevant'
            bootstrap.relevant_full_corpus(str(years).replace('\n','').split(";"),kwLimit,edge_th)
        if task=='--keywords'
            keywords.extract_keywords_year(str(years).replace('\n',''))




def main():

        start = time.time()

        run()

        print('Ellapsed Time : '+str(time.time() - start))


main()
