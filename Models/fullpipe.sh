
# full semantic nw/anal construction process
# (run in //)

PARAM_FILE="conf/parameters.csv"

WINDOW=`cat $PARAM_FILE|grep window-size|awk -F";" '{print $2}'`
START=`cat $PARAM_FILE|grep start-year|awk -F";" '{print $2}'`
END=`cat $PARAM_FILE|grep end-year|awk -F";" '{print $2}'`
NRUNS=`cat $PARAM_FILE|grep nruns|awk -F";" '{print $2}'`

# tasks : relevant ; network ; sensitivity ; probas ; network-python ; probas-python
#TASK=probas
#TASK=sensitivity
#TASK=network-python
TASK=$1

##########
##########

####
# generate year files

cd TextProcessing

#remove old
for file in `seq 1 $NRUNS`
do
    rm kwyears/run$file
done

# single year files (kw extraction)
file=1
for y in `seq $START $((END + WINDOW - 1))`
do
  echo $y >> kwyears/run$file
  file=$(((file % NRUNS ) + 1 ))
done



# command : python main.py yearfile
if [ "$TASK" == "keywords" ]
then
  echo "Running keywords extraction..."
  ./parrunnum "python main.py --keywords kwyears/run" $NRUNS
fi


if [ "$TASK" == "kw-consolidation" ]
then
  echo "Running keywords consolidation"
  python main.py --kw-consolidation
fi


############
############

cd ../Semantic
#echo "Semantic construction..."


# year files slightly different for R
for file in `seq 1 $NRUNS`
do
    rm relevantyears/runmv$file
done


# moving window files
file=1
for y in `seq $START $END`
do
    line=$y
    for i in `seq 1 $((WINDOW - 1))`
    do
	   line=$line";"$((y+i))
    done
    echo $line >> relevantyears/runmv$file
    file=$(((file % NRUNS ) + 1 ))
done




if [ "$TASK" == "raw-network" ]
then
  mkdir pickled
  mkdir sensitivity
  ./parrunnum "python main.py --raw-network relevantyears/runmv" $NRUNS
fi


if [ "$TASK" == "classification" ]
then
  mkdir classification
  ./parrunnum "python main.py --classification relevantyears/runmv" $NRUNS
fi

if [ "$TASK" == "custom-python" ]
then
  ./parrunnum "python main.py --custom relevantyears/runmv" $NRUNS
fi
