library(rgexf)

source('Models/Test/utils.R')

# reconstruct maps 
p_kw <- readMappingFile('Data/processed/test_pkw_2000_1000_2015-10-19 09:40:23.085621.csv',sep=";")
kw_p <- readMappingFile('Data/processed/test_kwp_2000_1000_2015-10-19 09:40:23.368437.csv',sep=";")

# test gexf export

# patent graph, link if same kw
pids=list();id=1;for(n in names(p_kw)){pids[[n]]=id;id=id+1;}
nodes = data.frame(id=1:length(pids),label=names(p_kw))

# edges
rawedges=c();k=1;
edgeLabels = c();
keywords=names(kw_p);
for(kw in kw_p){
  show(k)
  if(length(kw)>1){
    for(i in 1:(length(kw)-1)){
      for(j in (i+1):length(kw)){
        rawedges=append(rawedges,pids[[kw[i]]],pids[[kw[j]]])
        edgeLabels=append(edgeLabels,keywords[k])
      }
    }
  }
  k=k+1;
}

# quite slow ; may be not that powerful on larger dataset ? -> filter keywords before in python script ; by score on subcorpuses

# construct the edges dataframe
edgesmat=matrix(data=rawedges,ncol=2,byrow=TRUE)
colnames(edgesmat)<-c('source','target')

write.gexf(nodes=nodes,
           edges=edgesmat,
           output='Data/processed/test_patentNW.gexf')



