



#pwd
#ls -lh

# NOTE : for this part, rmongodb fails to authenticate -> relaunch db without auth

# command for graph construction : R -f allYears.R --args yearfile
if [ "$TASK" == "network-r" ]
then
  ./parrunnum "R -f allYears.R --args relevantyears/runmv" $NRUNS
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
