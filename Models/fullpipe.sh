
# full semantic nw/anal construction process
# (run in //)



WINDOW=5
START=1976
END=2008
NRUNS=15




##########
##########

cd TextProcessing
echo "Running relevance estimation..."

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
#./parrunnum "python main.py relevantyears/runmv" $NRUNS



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
    echo $y"-"$((y+WINDOW)) >> relevantyears/runmv$file # TODO : append
    file=$(((file % NRUNS ) + 1 ))  # TODO
done

#pwd
#ls -lh

# command for graph construction : R -f allYears.R --args yearfile
./parrunnum "R -f allYears.R --args relevantyears/runmv" $NRUNS

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







