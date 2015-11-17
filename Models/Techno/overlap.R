setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining'))

overlap <- read.table('Models//Techno//TechnoClasses//res//overlap.csv',sep=";")

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
