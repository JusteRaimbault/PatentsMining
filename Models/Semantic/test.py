
# tests

import pymongo,pickle
from igraph import *
import graph


years = ['1976','1977','1978','1979','1980']
kwLimit=100000.0
min_edge_th=10.0

graph.construct_graph(years,kwLimit,min_edge_th)
