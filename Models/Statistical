patent = read.table(file="C:/Users/yoann/OneDrive/Documents/work/research/004-PatentMining(WithAntoninBergeudJusteRaimbault)/R/patent_class.txt",
                sep=',', header=TRUE)

class = read.csv(file="C:/Users/yoann/OneDrive/Documents/work/research/004-PatentMining(WithAntoninBergeudJusteRaimbault)/R/tech_class.csv",
                   sep=';', header=TRUE)


technoProba = load(file="C:/Users/yoann/OneDrive/Documents/work/research/004-PatentMining(WithAntoninBergeudJusteRaimbault)/R/technoProbas_1977_sizeTh10.RData", envir = parent.frame(), verbose = FALSE)

exportSubset = read.table(file="C:/Users/yoann/OneDrive/Documents/work/research/004-PatentMining(WithAntoninBergeudJusteRaimbault)/R/exportSubset.txt",
                    sep=',', header=FALSE)

patent10000 = patent[1:10000,]


#compute the parameter for technological classes
t = table(factor(class[,"class"])) #make a table of factors
for (i in 1:451)
{
  t[[i]]=0
}
theta = 0 #parameter of the model
p = patent[complete.cases(patent),] #remove observations with NA
idstart=3930271
for (i in 1:10000)
{
  id = p[i,1]
  cl = p[i,4]
  #to continue
}