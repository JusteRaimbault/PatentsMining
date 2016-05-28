
# data export


setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

years = 1976:2012

kmin = 0;freqmin = 50;edge_th = 50;kmaxdec=0.25;freqmaxdec=0.25
sizeTh=10
semprefix = paste0('full_100000_kmin',kmin,'_kmaxdec',kmaxdec,'_freqmin',freqmin,'_freqmaxdec',freqmaxdec,'_eth',edge_th)

export_dir = paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Data/processed/semantic/',semprefix)
dir.create(export_dir)

for(year in years){
  load(paste0('probas/relevant_',year,'_',semprefix,'.RData'))
  export_probas = probas[,3:ncol(probas)]
  write.table(export_probas,file=paste0(export_dir,'/',year,'_patentsprobas.csv'),sep = ";",quote = FALSE,row.names = TRUE,col.names = NA)
  # export communities : construct kwdf
  ckws=c();ccoms=c()
  for(i in 1:length(sub$com)){
    for(k in sub$com[[i]]){ckws=append(ckws,k);ccoms=append(ccoms,i)}
  }
  kwdf = data.frame(ckws,ccoms)
  write.table(kwdf,file=paste0(export_dir,'/',year,'_keywords.csv'),sep = ";",quote=FALSE,row.names = FALSE,col.names =FALSE )
}

