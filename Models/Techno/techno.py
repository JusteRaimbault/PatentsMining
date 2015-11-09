from sets import Set



# include utils functions
execfile('../Utils/utils.py')

# Technological class distances
#  -> MEM ISSUE IN PY ! : do in R ? (mem ok but slower ? test java ?)


def main():
    classes = get_classes('../../Data/raw/classesTechno/class.csv')
    for c in classes :
        print(len(c))


# reports a dictionary of sets corresponding to classes : class_num -> class_set
def get_classes(file):
    raw = read_csv(file,',')
    classes = dict()

    n = len(raw)
    k = 0

    for p in raw :
        c = p[2];i = p[0]
        if not c in classes :
            s = Set(i);classes[c] = s
        else :
            classes[c].add(i)
        k = k + 1
        if k % 10000 == 0 : print(k/n)


    return(classes)








main()
