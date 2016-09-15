
# full semantic nw/anal construction process
# (run in //)



WINDOW=5
START=1976
END=2008
NRUNS=15

# tasks : relevant ; network ; sensitivity ; probas ; network-python ; probas-python
#TASK=probas
#TASK=sensitivity
#TASK=network-python
TASK=$1

##########
##########

cd TextProcessing

# generate year files
#remove old
for file in `seq 1 $NRUNS`
do
    rm relevantyears/runmv$file
done

file=1
for y in `seq $START $END`
do
    line=$y
    for i in `seq 1 $((WINDOW - 1))` # TODO
    do
	   line=$line";"$((y+i)) # TODO shell arithm
    done
    echo $line >> relevantyears/runmv$file # TODO : append
    file=$(((file % NRUNS ) + 1 )) # TODO
done

# command : python main.py yearfile
if [ "$TASK" == "relevant" ]
then
  echo "Running relevance estimation..."
  ./parrunnum "python main.py relevantyears/runmv" $NRUNS
fi


############
############

cd ../Semantic
echo "Semantic construction..."

# year files slightly different for R
for file in `seq 1 $NRUNS`
do
    rm relevantyears/runmv$file
done

file=1
for y in `seq $START $END`
do
    #echo $y"-"$((y+WINDOW)) >> relevantyears/runmv$file # TODO : append
    cp ../TextProcessing/relevantyears/runmv$file relevantyears/runmv$file
    file=$(((file % NRUNS ) + 1 ))  # TODO
done

#pwd
#ls -lh

# NOTE : for this part, rmongodb fails to authenticate -> relaunch db without auth

# command for graph construction : R -f allYears.R --args yearfile
if [ "$TASK" == "network" ]
then
  ./parrunnum "R -f allYears.R --args relevantyears/runmv" $NRUNS
fi



if [ "$TASK" == "network-python" ]
then
  ./parrunnum "python main.py --graph relevantyears/runmv" $NRUNS
fi


if [ "$TASK" == "probas-python" ]
then
  ./parrunnum "python main.py --probas relevantyears/runmv" $NRUNS
fi


# graphs stored in processed


# launch :
#  * semsensitivity : exploration of graphs
#   -> TODO : relative param values
#  * semthemprobas on same values
#
# then semoptimparams ; semoptimprobas to be launched by hand
#   -> TODO : adapt techno classes distrib with moving window
#   -> TODO : check analyses citations (2nd order interdisc).
#

# semsensitivity
if [ "$TASK" == "sensitivity" ]
then
  ./parrunnum "R -f semsensitivity.R --args relevantyears/runmv" $NRUNS
fi

if [ "$TASK" == "probas" ]
then
  # probas
  ./parrunnum "R -f semthemprobas.R --args relevantyears/runmv" $NRUNS
fi
