import time,sys
import keywords,dbmanagement


def run():
    task = sys.argv[1]
    if task=='--kw-consolidation':
        # first update year records
        dbmanagement.update_year_records()
        # then compute techno classes
        dbmanagement.compute_kw_techno()
    else :
        f=open(sys.argv[2])
        # multiple years : csv files
        for years in f.readlines():
            print('Years : '+str(years).replace('\n',''))
            if task=='--keywords':
                keywords.extract_keywords_year(str(years).replace('\n',''))




def main():

        start = time.time()

        run()

        print('Ellapsed Time : '+str(time.time() - start))


main()
