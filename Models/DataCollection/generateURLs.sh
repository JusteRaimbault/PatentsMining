
# from 2002 files are in xml :
# https://bulkdata.uspto.gov/data2/patent/grant/redbook/bibliographic/2002/2002_xml.zip

# from 1976 to 2001
# https://bulkdata.uspto.gov/data2/patent/grant/redbook/bibliographic/2001/2001.zip

# - no file for 2015 -

OUTFILE=$1

seq 1976 2001 | awk '{print "https://bulkdata.uspto.gov/data2/patent/grant/redbook/bibliographic/"$1"/"$1".zip"}' >> $OUTFILE
seq 2002 2014 | awk '{print "https://bulkdata.uspto.gov/data2/patent/grant/redbook/bibliographic/"$1"/"$1"_xml.zip"}' >> $OUTFILE

