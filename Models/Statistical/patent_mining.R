patent = read.table(file="C:/DataPatentMining/patent_class.txt",
                sep=',', header=TRUE)

class = read.csv(file="C:/DataPatentMining/tech_class.csv",
                   sep=';', header=TRUE)

technoProba = load(file="C:/Users/yoann/OneDrive/Documents/DataPatentMining/technoProbas_1977_sizeTh10.RData", envir = parent.frame(), verbose = FALSE)

exportSubset = read.table(file="C:/Users/yoann/OneDrive/Documents/DataPatentMining/exportSubset.txt",
                    sep=',', header=TRUE)

patent10000 = patent[1:10000,]
p =patent10000[order(patent10000$app_date),] 
p = p[complete.cases(p),] #remove observations with NA

#compute the parameter for technological classes
t = table(factor(class[,"class"])) #make a table of factors
for (i in 1:451)
{
  t[[i]]=0
}
tpat = table(factor(p[,"patent"])) #make a table of factors
nb_patents = length(tpat)
for (i in 1:nb_patents)
{
  tpat[[i]]=0
}

theta = 0.01 #parameter of the model
log_lik=0
for (i in 1:nb_patents)
{
  #to continue
  id = p[i,1]
  cl = p[i,4]
  if (id > idstart)
  {
    if (id != p[i-1,1]) #two possibilities to find citation: 1) the patent has made previous citations, 2) it got cited by previous patents
    {
      #1)
      
    }
  }
  #add the class in table
  t[[cl]] = t[[cl]]+1
}