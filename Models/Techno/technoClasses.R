
setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining'))

raw <- read.csv('Data/raw//classesTechno//class.csv',colClasses=c('character','NULL','character','NULL'))

# construct classes table / patent class
# pb : with patent table, computational issue ?

patents = list()
classes = list()

# no SubClass for now
for(i in 1:nrow(raw)){
  pid=raw[i,1];c=raw[i,3]
  if(!is.null(patents[[pid]][[1]])){
    if(!c %in% patents[[pid]]){ patents[[pid]] == append(patents[[pid]],c)}
  }else{
    patents[[pid]] = list(c)
  }
  # add patent to class
  if(!is.null(classes[[c]][[1]])){
    if(!pid %in% classes[[c]]){classes[[c]] == append(classes[[c]],pid)}
  }else{
    classes[[c]] = list(pid)
  }
  
  if(i%%10000==0){show(i)}
}

