

############
# Workflow corpus processing
############

import nltk
# sqlite reader package ?

##
# read patents id from temp file
##
patents_id = []

## get abstracts and titles from sqlite / OR sql ?
def read_fromSqlite(type):
    []

raw_text = read_fromSqlite("abstract")
raw_titles = read_fromSqlite("title")


# normalize words and construct text.

tokens = nltk.word_tokenize(raw_text)

# normalize

# text
texts = [nltk.Text(token) for token in tokens]
# merge texts, titles.

###
#   POS tagging
###

tagged_text = nltk.pos_tag(texts)

# -> then filter and extract multi-stems

# first stem
#porter = nltk.PorterStemmer()
stems = [porter.stem(token) for token in tokens]
# construct association matrix words -> stems



 # construct subsets (NN^ADJ,NN^ADJ,...,NN^ADJ)
#for tagged in tagged_text


############
# normalization ?
#  -> use levenstein distance. O(N_multiStems)
#
#  stemize it
#
############


#  -> set of candidate multi-stems


####### Processing #################

##########
# 1) Counting
######
## Counting stems frequency -> need to keep a trace of stem origin.
######



##########
# 2) Unithood
#  u = log(1 + l)*f
# -> keep kN terms with highest C-value --> see [Frantzi, K., and Ananiadou, S, 2000]

##########
# 3) Termhood sorting
## : compute cooccurrence matrix

# \theta(i) = \sum{j\neq i} \frac{ (M_{ij} - \sum_k{M_{ik}}\sum_k{M_{jk}} )^2 }{\sum_k{M_{ik}}\sum_k{M_{jk}}}

# -> keep N terms with best termhood.




################
# Write terms in tmp file ?

# -> define archi of communication python text processing <-> core appli. (R : igraph ?)
