
DB=patent
PORT=29019
COLLECTION=keywords
FIELDS=id
QUERY='{"keywords":"inform"}'
TYPE=csv
FILE=inform_ids.csv

mongoexport --db $DB --port $PORT --collection $COLLECTION --fields $FIELDS --query $QUERY --type $TYPE --out $FILE



