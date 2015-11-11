/**
 * 
 */
package patents;

import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Main {
	
	
	public static void constructClassNetwork(String file){
		HashMap<String,HashSet<Patent>> classes = Reader.importFromFile(file);
		//System.out.println(classes.keySet().size());
		
		long bound = 0;
		for(HashSet<Patent> h:classes.values()){
			//System.out.println(h.size());
			bound+=h.size()*h.size();
		}
		//System.out.println(bound);
		
		HashMap<String,LinkedList<Patent>> sortedClasses = new HashMap<String,LinkedList<Patent>>();
		for(String k:classes.keySet()){
			LinkedList<Patent> l = new LinkedList<Patent>(classes.get(k));
			System.out.println("sorting class : "+l.size());
			Collections.sort(l, new Comparator<Patent>() {
		         @Override
		         public int compare(Patent p1, Patent p2) {
		             return p1.id.compareTo(p2.id);
		         }
		     });
			sortedClasses.put(k, l);
		}
		
		// construct the overlap matrix
		int n = classes.keySet().size();
		int[][] overlapMatrix = new int[n][n];
		String[] classNames = new String[n];
		int[] classSizes = new int[n];
		int k = 0;for(String s:sortedClasses.keySet()){classNames[k]=s;classSizes[k]=sortedClasses.get(s).size();k++;}
		
		for(int i=0;i<n-1;i++){
			System.out.println(i);
			for(int j=i+1;j<n;j++){
				overlapMatrix[i][j]=overlap(sortedClasses.get(classNames[i]),sortedClasses.get(classNames[j]));
			}
		}
		
		Writer.writeCSV(overlapMatrix, "res/overlap.csv");
		Writer.writeCSV(classSizes, "res/sizes.csv");
		
	}
	
	
	/**
	 * overlap assuming list are sorted.
	 * 
	 * @param l1
	 * @param l2
	 * @return
	 */
	private static int overlap(LinkedList<Patent> l1,LinkedList<Patent> l2){
		int res = 0;
		Iterator<Patent> i1 = l1.iterator();Iterator<Patent> i2 = l2.iterator();
		Patent current1 = i1.next(),current2 = i2.next();
		while(i1.hasNext()&&i2.hasNext()){
			if(current1.id.equals(current2.id)){
				res++; current1 = i1.next();current2 = i2.next();
			}else{
				if(current1.id.compareTo(current2.id)<0){
					current1 = i1.next();
				}else{
					current2 = i2.next();
				}
			}
		}
		return res;
	}
	
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		constructClassNetwork("../../../Data/raw/classesTechno/class.csv");
	}

}
