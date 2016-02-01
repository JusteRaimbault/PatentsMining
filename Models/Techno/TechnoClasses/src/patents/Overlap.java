/**
 * 
 */
package patents;

import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Overlap {

	
	
	protected static void computeOverlap(HashMap<String,LinkedList<Patent>> sortedClasses){
		System.out.println("computing overlaps...");
		
		int n = sortedClasses.keySet().size();
		int[][] overlapMatrix = new int[n][n];
		String[] classNames = new String[n];
		int[] classSizes = new int[n];
		int k = 0;
		// classes names and sizes
		for(String s:sortedClasses.keySet()){classNames[k]=s;classSizes[k]=sortedClasses.get(s).size();k++;}
		
		for(int i=0;i<n-1;i++){
			System.out.println(i);
			overlapMatrix[i][i]=classSizes[i];
			for(int j=i+1;j<n;j++){
				overlapMatrix[i][j]=(overlap_array(sortedClasses.get(classNames[i]),sortedClasses.get(classNames[j]))).length;
			}
		}
		
		overlapMatrix[n-1][n-1]=classSizes[n-1];
		
		for(int i=1;i<n;i++){
			for(int j=0;j<i;j++){
				overlapMatrix[i][j]=overlapMatrix[j][i];
			}
		}
		
		
		Writer.writeCSV(overlapMatrix, "res/overlap.csv");
		Writer.writeCSV(classSizes, "res/sizes.csv");
	}
	
	
	/**
	 * 
	 * 
	 * 
	 * @param sortedClasses
	 */
	protected static void computeSecondOrderOverlaps(HashMap<String,LinkedList<Patent>> sortedClasses){
		System.out.println("second order overlap...");
		
		int n = sortedClasses.keySet().size();
		//int[][] overlaps = new int[n][4];
		// use list, more simple (should be n*(n-1)/2 * (n-2) + n (for classes sizes) - NO ARRAY - to long to create in memory
		//int[][] overlaps = new int[(n*(n-1)*(n-2)/2) + n][4];
		LinkedList<int[]> overlaps = new LinkedList<int[]>();
		String[] classNames = new String[n];
		int r = 0;for(String s:sortedClasses.keySet()){classNames[r]=s;r++;}
		
		//r = 0;
		for(int i=0;i<n-2;i++){
			System.out.println(i);
			for(int j=i;j<n-1;j++){
				LinkedList<Patent> overlap2 = overlap(sortedClasses.get(classNames[i]),sortedClasses.get(classNames[j]));
				// then computes snd order overlap
				System.out.println("Sorting overlap : "+overlap2.size());
				Collections.sort(overlap2);
				for(int k=j+1;k<n;k++){
					/*if(i==j&&j==k){
						// add class size
						int[] nextrow = new int[4]; 
						nextrow[0]=i;nextrow[1]=i;nextrow[2]=i;nextrow[3]=sortedClasses.get(classNames[i]).size();
						overlaps.add(nextrow);
					}else{*/
						// check only if k ≠ i and k ≠ j -> will have some repetitions
						// -> having k > j should do the trick : take k >= j
						LinkedList<Patent> overlap3 = overlap(overlap2,sortedClasses.get(classNames[k]));
						if(overlap3.size()>0){
							int[] nextrow = new int[4]; 
							nextrow[0]=i;nextrow[1]=j;nextrow[2]=k;nextrow[3]=overlap3.size();
							overlaps.add(nextrow);
						}
					//}
					//r++;
				}
			}
		}
		
		Writer.writeIntCSV(overlaps, "res/overlap_snd_order_different.csv");
	}
	
	
	
	
	
	
	
	
	
	/**
	 * overlap assuming list are sorted.
	 * 
	 * @param l1
	 * @param l2
	 * @return
	 */
	protected static LinkedList<Patent> overlap(LinkedList<Patent> l1,LinkedList<Patent> l2){
		LinkedList<Patent> res = new LinkedList<Patent>();
		if(l1.size()>0&&l2.size()>0){
			Iterator<Patent> i1 = l1.iterator();Iterator<Patent> i2 = l2.iterator();
			Patent current1 = i1.next(),current2 = i2.next();
			while(i1.hasNext()&&i2.hasNext()){
				if(current1.equals(current2)){
					res.add(current1); current1 = i1.next();current2 = i2.next();
				}else{
					if(current1.compareTo(current2)<0){
						current1 = i1.next();
					}else{
						current2 = i2.next();
					}
				}
			}
		}
		return res;
	}
	
	
	

	protected static Patent[] overlap_array(LinkedList<Patent> l1,LinkedList<Patent> l2){
		LinkedList<Patent> res = overlap(l1,l2);
		Patent[] resarray = new Patent[res.size()];
		int i=0;for(Patent p:res){resarray[i]=p;i++;}
		return resarray;
	}
	
	
	
	
	/**
	 * assumes sorted sets -> computes l1 \ l2
	 * @param l1
	 * @param l2
	 * @return
	 */
	protected static LinkedList<Patent> setDiff(LinkedList<Patent> l1,LinkedList<Patent> l2){
		if(l2.size()==0){return l1;}
		LinkedList<Patent> res = new LinkedList<Patent>();
		if(l1.size()>0){
			Iterator<Patent> i1 = l1.iterator();Iterator<Patent> i2 = l2.iterator();
			Patent current1 = i1.next(),current2 = i2.next();
			while(i1.hasNext()&&i2.hasNext()){
				if(current1.equals(current2)){
					current1 = i1.next();current2 = i2.next();
				}else{
					if(current1.compareTo(current2)<0){
						current1 = i1.next();
						res.add(current1);
					}else{
						current2 = i2.next();
					}
				}
			}
		}
		return res;
	}
	
	
	
	
}
