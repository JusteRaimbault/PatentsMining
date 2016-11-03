
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
    rm kwyears/run$file
done

# single year files (kw extraction)
file=1
for y in `seq $START $((END + WINDOW - 1))`
do
  echo $y >> kwyears/run$file
  file=$(((file % NRUNS ) + 1 ))
done

# moving window files
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
if [ "$TASK" == "keywords" ]
then
  echo "Running keywords extraction..."
  ./parrunnum "python main.py --keywords kwyears/run" $NRUNS
fi

if [ "$TASK" == "relevant" ]
then
  echo "Running relevance estimation..."
  ./parrunnum "python main.py --relevant relevantyears/runmv" $NRUNS
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
if [ "$TASK" == "network-r" ]
then
  ./parrunnum "R -f allYears.R --args relevantyears/runmv" $NRUNS
fi



if [ "$TASK" == "network" ]
then
  ./parrunnum "python main.py --graph relevantyears/runmv" $NRUNS
fi


if [ "$TASK" == "probas" ]
then
  ./parrunnum "python main.py --probas relevantyears/runmv" $NRUNS
fi

if [ "$TASK" == "custom-python" ]
then
  ./parrunnum "python main.py --custom relevantyears/runmv" $NRUNS
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
if [ "$TASK" == "sensitivity-r" ]
then
  ./parrunnum "R -f semsensitivity.R --args relevantyears/runmv" $NRUNS
fi

if [ "$TASK" == "probas-r" ]
then
  # probas
  ./parrunnum "R -f semthemprobas.R --args relevantyears/runmv" $NRUNS
fi
