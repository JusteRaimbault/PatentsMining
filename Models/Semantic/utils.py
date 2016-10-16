#import datetime


def export_dico_csv(dico,filename,delimiter):
    outfile=open(filename,'w')
    for k in dico.keys():
        outfile.write(str(k)+delimiter)
        for i in range(len(dico[k])-1):
            outfile.write(str(dico[k][i])+delimiter)
        outfile.write(str(dico[k][len(dico[k])-1])+'\n')



##
#
def export_matrix_sparse_csv(matrix,firstcols,filename,delimiter):
    outfile=open(filename,'w')
    for i in range(len(matrix)):
        head=""
        for k in range(len(firstcols)):
            head=head+str(firstcols[k][i])+delimiter
        for j in range(len(matrix[i])-1):
            # export one line per non-zero element ; looses a bit repeating id but so easier to read
            if matrix[i][j] > 0.0 :
                outfile.write(head+str(j)+delimiter+str(matrix[i][j])+'\n')

def export_csv(data,filename,delimiter,header):
    outfile=open(filename,'w')
    outfile.write(header+'\n')
    for row in data:
        for i in range(len(row)-1):
            outfile.write(str(row[i])+delimiter)
        outfile.write(str(row[len(row)-1])+'\n')


def import_csv(csvfile,delimiter):
    infile = open(csvfile,'r')
    res = []
    for line in infile.readlines():
        res.append(line.replace('\n','').split(delimiter))
    return(res)
