
## Setup

 - having a running local `mongod` instance
 - mongo host, port, user and password to be configured in `conf/parameters.csv`
 - raw data import from gz file : use `mongorestore -d redbook -c raw --gzip $FILE`
 - specific python packages required : `pymongo`, `python-igraph`, `nltk` (with resources `punkt`, `averaged_perceptron_tagger`,`porter_test`)

## Running

The utility `fullpipe.sh` can launch most of the processing pipe.

## Options :
  (to be changed in `conf/parameters.csv`)
  - `$WINDOW` : window size in years
  - `$START` : beginning of first window
  - `$END` : beginning of last window
  - `$NRUNS` : number of parallel runs

## Tasks :

The tasks to be done in order : keywords extraction, relevance estimation, network construction, semantic probas construction, are launched with the following options :

\\!// `keywords` and `kw-consolidation` tested with python3 ; rest with python2 (igraph compatibility issues)

 - `keywords` : extracts keywords
 - `kw-consolidation` : consolidate keywords database (techno disp measure)
 - `raw-network` : estimates relevance, constructs raw network and perform sensitivity analysis
 - `classification` : classify and compute patent probability, keyword measures and patent measures

## Analysis

 - preprocess the data in `semanalfun.R`



## Data Collection

### Raw Data Collection

### Data Preprocessing

 - from csv technological classes to R-formatted sparse Matrix : use `Techno/prepareData.R`
 - from csv citation file to citation network in R-formatted graph and adjacency sparse matrix : use `Citation/constructNW.R`
