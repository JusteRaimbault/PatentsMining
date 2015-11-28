setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models//Techno//TechnoClasses//res'))

#overlap <- read.table('Models//Techno//TechnoClasses//res//overlap.csv',sep=";")
overlap <- read.table('overlap.csv',sep=";")

links = 0

for(i in 1:nrow(overlap)){
  show(i)
  links = links + (overlap[i,i]^2)
  #if(i<nrow(overlap)){
  #  for(j in (i+1):ncol(overlap)){
  #    overlap[j,j] = overlap[j,j] - overlap[i,j]
  #  }
  #}
}



#########
##

o <- read.csv('overlap_snd_order_different.csv',sep=';')

hist(diag(as.matrix(overlap)))
diag(overlap) <- 0
max(overlap)


###########
##
# stats on class sizes -> power law ?

classSizes = diag(as.matrix(overlap))
hist(classSizes[classSizes> 100],breaks=200)

# rank-size law for classes size ?
plot(log(1:length(classSizes)),log(sort(classSizes,decreasing=TRUE)))
plot(log(1:length(classSizes[classSizes> 10000])),log(sort(classSizes[classSizes> 10000],decreasing=TRUE)))
plot(sort(classSizes,decreasing=TRUE))


###
# nw of non trivial techno distances



