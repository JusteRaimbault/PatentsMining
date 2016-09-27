#patent = read.table(file="C:/DataPatentMining/patent_class.txt",
#                sep=',', header=TRUE)

#class = read.csv(file="C:/DataPatentMining/tech_class.csv",
#                   sep=';', header=TRUE)

citation = read.table(file="C:/DataPatentMining/yoann.txt",
                    sep=',', header=FALSE, nrows=100000)
names(citation)=c("citing", "cited", "y_cited", "y_citing", "class_citing", "class_cited", "app_date_citing", "grant_date_citing", "app_date_cited", "grant_date_cited")

#technoProba = load(file="C:/Users/yoann/OneDrive/Documents/DataPatentMining/technoProbas_1977_sizeTh10.RData", envir = parent.frame(), verbose = FALSE)

#exportSubset = read.table(file="C:/Users/yoann/OneDrive/Documents/DataPatentMining/exportSubset.txt",
#                    sep=',', header=TRUE)

#patent10000 = patent[1:10000,]
#p =patent10000[order(patent10000$app_date),] 
#p = p[complete.cases(p),] #remove observations with NA

#c = citation[1:1000000,]
c = citation[order(citation$app_date_citing),] 
c = c[complete.cases(c),] #remove observations with NA


# compute the parameter for technological classes
t = table(factor(c[,"class_citing"])) #make a table of factors
lt = length(t)
for (i in 1:lt)
{
  t[[i]]=0
}

tpat = table(factor(c[,"citing"])) #make a table of patents
nb_patents = length(tpat)
for (i in 1:nb_patents)
{
  tpat[[i]]=0
}
PatList = unique(c$citing)
theta = seq(0.01, 1, by=0.01) #parameter of the model
log_lik=rep(0,100)
for (i in 1:nb_patents)
{
  id = PatList[i]
  subc = c[c$citing==id,]
  tsubc = table(subc$class_citing)
  nbC= length(tsubc) # number of patent's classes 
  n1 = sum(t[tsubc])# nb of patents from the patent's classes
  n2 = length(tpat[tpat >0]) # nb of patents
  if (n2 == 0)
  {
    n2=1
  }
  pr = pmin(1,n1/n2 + theta) # theoretical probability to cite patents from its own classes
  pcited = unique(subc$cited)
  nb_cited = length(pcited)
  for (k in 1:nb_cited)
  {
    idcited=pcited[k]
    if (idcited %in% names(tpat))
    {
      if (tpat[toString(idcited)] == 1)
      {
        Cl_cited = unique(subc[subc$cited==idcited,"class_cited"])# list of classes from the cited patent
        nb_cl = length(Cl_cited)
        for (l in 1:nb_cl)
        {
          if (Cl_cited[l] %in% names(tsubc))
          {
            log_lik = log_lik + log (pr)
            #print(log (pr))
          }
          else
          {
            log_lik = log_lik + log(1 - pr)
            #print(log(1 - pr))
          }
        }
      }
    }
  }
  tpat[toString(id)]=1 #add the cited patents in the table
  for (j in 1:nbC) # add the corresponding classes
  {
    t[names(tsubc)[j]] = t[names(tsubc)[j]] + 1
  }
}
plot(theta, log_lik)