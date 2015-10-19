
# utils functions

readMappingFile <- function(file,sep){
  lines = readLines(file)
  res=list()
  for(l in lines){
    words = strsplit(l,sep)[[1]]
    # reconstruct a hashtable in the res list
    res[[words[1]]]=words[2:length(words)]
  }
  return(res)
}



