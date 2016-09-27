#import datetime


def export_dico_csv(dico,filename,delimiter):
    outfile=open(filename,'w')
    for k in dico.keys():
        outfile.write(str(k)+delimiter)
        outfile.write(str(dico[k])+'\n')


        
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
