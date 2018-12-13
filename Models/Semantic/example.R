
setwd(paste0(Sys.getenv('CS_HOME'),'/PatentsMining/Models/Semantic'))

library(dplyr)


classif04 = as.tbl(read.csv(
  file='classification/classification_window5_kwLimit100000_dispth0.06_ethunit4.1e-05/patent_2000-2004_kwLimit100000.0_dispth0.06_ethunit4.1e-05.csv',
  sep=';',colClasses = c('character',rep('numeric',11)))
  )

keywords04 = as.tbl(read.csv(
  file='classification/classification_window5_kwLimit100000_dispth0.06_ethunit4.1e-05/keywords_2000-2004_kwLimit100000.0_dispth0.06_ethunit4.1e-05.csv',
  sep = ';',colClasses = c('character',rep('numeric',10))
))


data.frame(classif04[classif04$betweennesscentrality==max(classif04$betweennesscentrality),])
#data.frame(classif04[classif04$classkws==max(classif04$classkws),])


#    patent kws classkws     tidf technodispersion docfreq     termhood degree weighteddegree betweennesscentrality
#1 6833896 172       81 18020.82         18.35517  343389 3.533676e+16  22969        3738107             133189045
#closenesscentrality eigenvectorcentrality
#1          0.05285423               7.51915

# Google prior art keywords : (layer) (method) (gate) (electrode) (substrate)

# stems :
keywords =c("gate insul layer", "amorph silicon", "use third mask", "use third", "pure", 
"electrod align layer", "activ layer pure", "data", "pattern second metal", "display devic",
"third mask", "thermal-tr furnac cure", "form gate", "second", "substrat", "have sourc electrod",
"insul", "metal", "transistor method", "devic", "form gate line", "crystal display", 
"transistor method form", "gate insul", "first mask", "have gate", "in-plan", "electrod align",
"first", "plural common", "data line have", "layer use", "pattern second", "electrod gate",
"layer semiconductor layer", "mask form data", "amorph silicon second", "anneal thin", "amorph",
"ohmic contact layer", "use second", "display devic have", "line have gate", "align layer",
"insul layer", "layer semiconductor", "insul layer use", "silicon", "common electrod", "crystal",
"metal layer semiconductor", "layer impurity-dop amorph", "substrat have", "layer impurity-dop", 
"mask", "form", "contact layer impurity-dop", "pure amorph silicon", "have", "common", "activ layer",
"connect line", "common line", "anneal thin film", "thin film", "have plural pixel", "form array substrat",
"method form", "film", "method", "array", "have sourc", "devic have align", "ohmic contact", "silicon second",
"connect", "devic have", "thermal-tr furnac", "switch liquid", "third mask form", "form data", "channel",
"sourc electrod", "line", "display", "sourc electrod channel", "align", "line have plural", "impurity-dop",
"align film", "drain", "array substrat", "common electrod gate", "plural pixel electrod", 
"have plural common", "first metal layer", "contact layer", "pixel electrod", "activ", 
"film transistor method", "use second mask", "gate electrod", "pattern", "drain electrod", "third", 
"line have sourc", "electrod gate insul", "layer use second", "second mask", "have align film", "have plural", 
"second metal", "line have", "have gate electrod", "metal layer", "gate", "connect line have", "pixel", "data line",
"cure", "transistor", "liquid crystal display", "film transistor", "first mask form", "thin", 
"plural pixel", "semiconductor", "contact", "form data line", "form array", "ohmic", "plural", 
"use first", "semiconductor layer", "common line have", "thermal-tr", "switch liquid crystal",
"layer pure", "portion", "switch", "electrod channel", "gate line", "method form array",
"pure amorph", "furnac", "etch", "second metal layer", "gate line have", "anneal", "crystal display devic",
"liquid", "use", "have align", "in-plan switch liquid", "use first mask", "sourc", "layer", "mask form",
"plural common electrod", "layer pure amorph", "thin film transistor", "impurity-dop amorph", 
"liquid crystal", "impurity-dop amorph silicon", "in-plan switch", "electrod", "drain electrod align",
"etch portion", "mask form gate", "first metal", "furnac cure", "silicon second metal")


selkws = keywords[keywords%in%keywords04$keyword]

rownames(keywords04)<-keywords04$keyword

selkwsmeasures = keywords04[selkws,]

# bw centrality
data.frame(selkwsmeasures[order(selkwsmeasures$betweennesscentrality,decreasing = T)[1:5],])

# eigenvector centrality
data.frame(selkwsmeasures[order(selkwsmeasures$eigenvectorcentrality,decreasing = T)[1:5],])
# -> idem bw

# closeness
data.frame(selkwsmeasures[order(selkwsmeasures$closenesscentrality,decreasing = T)[1:5],])
# bof

# weighted degree
data.frame(selkwsmeasures[order(selkwsmeasures$weighteddegree,decreasing = T)[1:5],])
# -> idem

# degree
data.frame(selkwsmeasures[order(selkwsmeasures$degree,decreasing = T)[1:5],])

# tfidf
data.frame(selkwsmeasures[order(selkwsmeasures$tidf,decreasing = T)[1:5],])
# -> confirms that shitty measure

# termhood
data.frame(selkwsmeasures[order(selkwsmeasures$termhood,decreasing = T)[1:5],])
# idem










