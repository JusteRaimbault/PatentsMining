
import nltk,sqlite3,time,locale



# tests

def test():
    # test_kw()
    test_db()


def test_db():
    for patent in get_patent_data(2000,100):
        print(patent)


def test_kw():
    for patent in res :
        print(extract_keywords(patent[1]+". "+patent[2],patent[0]))



## Functions


def get_patent_data(year,limit) :
    # connect to the database
    conn = sqlite3.connect('../../Data/raw/patdesc/patdesc.sqlite3')
    cursor = conn.cursor()
    # attach patent data
    cursor.execute('ATTACH DATABASE \'../../Data/raw/patent/patent.sqlite3\' as \'patent\'')

    #cursor.execute('SELECT patdesc.patent,patent.patent FROM patent,patdesc WHERE patent.patent=patdesc.patent LIMIT 10;')
    # retrieve records
    cursor.execute('SELECT title,abstract,GYear,patent.patent FROM patdesc,patent WHERE patdesc.patent = patent.patent AND abstract!=\'\' AND GYear = '+str(year)+' LIMIT '+str(limit)+";")
    res=cursor.fetchall()
    #first=res[0]
    #raw_text = first[0]+". "+first[1]
    return res


# tagged of the form (word,TAG)
def potential_multi_term(tagged) :
    res = True
    for tag in tagged :
        res = res and (tag[1]=='NN' or tag[1]=='NNP' or tag[1] == 'VBG' or tag[1] =='NNS'or tag[1] =='JJ' or tag[1] =='JJR')
    return res

#print(res)
def extract_keywords(raw_text,id):
    stemmer = nltk.PorterStemmer()

    #keywords = []

    # construct text
    text = nltk.Text(nltk.word_tokenize(raw_text))
    #print(text.tokens)

    # tag
    #   interesting tags are :

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
                    multistem = [stemmer.stem(tagged_text[k][0]).encode('ascii','ignore') for k in range(i,i+l)]
                    multistem.sort(key=str.lower)
                    multiterms.append(multistem)

    return multiterms


def main():
    #print(extract_keywords(raw_text))
    start = time.time()

    test()

    print(time.time() - start)


main()
