
import nltk,sqlite3,time,locale

# connect to the database
conn = sqlite3.connect('../../Data/raw/patdesc/patdesc.sqlite3')
cursor = conn.cursor()

# retrieve records
cursor.execute('SELECT patent,title,abstract FROM patdesc WHERE abstract!=\'\' LIMIT 100')
res=cursor.fetchall()
first=res[0]
raw_text = first[0]+". "+first[1]

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



#print(extract_keywords(raw_text))
start = time.time()

for patent in res :
     print(extract_keywords(patent[1]+". "+patent[2],patent[0]))

print(time.time() - start)
