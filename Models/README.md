
## Setup

 - having a running local `mongod` instance
 - config files : not flexible yet, uses port 29019 and user root (pwd root) - can be changed in code
 - raw data import : use `mongorestore -d redbook -c raw --gzip $FILE`

## Running

The utility `fullpipe.sh` can launch most of the processing pipe.

## Options :
  (to be changed in shell script)
  - `$WINDOW` : window size in years
  - `$START` : beginning of first window
  - `$END` : beginning of last window
  - `$NRUNS` : number of parallel runs

## Tasks :

The tasks to be done in order : keywords extraction, relevance estimation, network construction, semantic probas construction, are launched with the following options :

 - `keywords`
 - `relevant`
 - `network`
 - `probas`

Custom run of `main.py` in `Semantic` : `custom-python`

**Deprecated** R scripts.


## Analysis

 - preprocess the data in `semanalfun.R`



## Data Collection

### Raw Data Collection

### Data Preprocessing

 - from csv technological classes to R-formatted sparse Matrix : use `Models/Techno/prepareData.R`
