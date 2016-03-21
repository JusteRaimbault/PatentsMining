
# preliminary steps for nw construction

import pymongo

##
#  Dico reconstruction, given relevant collection and full dico db
#    -> per year dico ?
def construct_first_order_dico():
    mongo = pymongo.MongoClient()
