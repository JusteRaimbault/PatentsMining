/**
 * 
 */
package patents;

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Distances {

	

	
	
	protected static void computeDistancesOnSecondOrderOverlaps(HashMap<String,LinkedList<Patent>> sortedClasses){
		System.out.println("second order overlap...");
		
		int n = sortedClasses.keySet().size();
		String[] classNames = new String[n];
		int r = 0;for(String s:sortedClasses.keySet()){classNames[r]=s;r++;}
		
		HashSet<TechnoDistance> distances = new HashSet<TechnoDistance>(10000000);
		
		//r = 0;
		for(int i=0;i<n-2;i++){
			System.out.println("i : "+i);
			for(int j=i;j<n-1;j++){
				System.out.println("	j : "+j);
				LinkedList<Patent> overlap2 = Overlap.overlap(sortedClasses.get(classNames[i]),sortedClasses.get(classNames[j]));
				// then computes snd order overlap
				//System.out.println("Sorting overlap : "+overlap2.size());
				Collections.sort(overlap2);
				
				// then computes for any k != i, != j the 2nd order overlap ;
				// concatenates, compute distance on it AND between 1st order only and 2nd order
				// (not totally optimal in time but better in memory, avoids to keep old overlaps in memory
				HashSet<Patent> fullOverlap3 = new HashSet<Patent>();
				for(int k=1;k<n;k++){
					
					if(k!=i&&k!=j){
						System.out.println("		k : "+k);
						LinkedList<Patent> overlap3 = Overlap.overlap(overlap2,sortedClasses.get(classNames[k]));
						for(Patent p:overlap3){fullOverlap3.add(p);}
					}
				}
				
				// dirty -> converts the hashset to list
				LinkedList<Patent> fullOverlap3List = new LinkedList<Patent>();
				for(Patent p:fullOverlap3){fullOverlap3List.add(p);}
				
				LinkedList<Patent> firstOrderOnly = Overlap.setDiff(overlap2,fullOverlap3List);
				
				// converts both to array
				Patent[] fullOverlap3Array = Patent.listToArray(fullOverlap3List);
				Patent[] firstOrderOnlyArray = Patent.listToArray(firstOrderOnly);
				
				// inside overlap
				for(int p1 = 0;p1<fullOverlap3Array.length - 1;p1++){
					for(int p2=p1+1;p2<fullOverlap3Array.length;p2++){
						distances.add(new TechnoDistance(fullOverlap3Array[p1],fullOverlap3Array[p2]));
					}
				}
				
				// outside
				for(int p1 = 0;p1<firstOrderOnlyArray.length - 1;p1++){
					for(int p2=p1+1;p2<fullOverlap3Array.length;p2++){
						distances.add(new TechnoDistance(firstOrderOnlyArray[p1],fullOverlap3Array[p2]));
					}
				}
				
			}
		}
		
		Writer.writeSet(distances, "res/distances_2nd_order_extended.csv");
	}
	
	
	
	
	
	
	/**
	 * Techno distances on overlapping patents
	 * 
	 *   -- DOES NOT WORK WITH 32G Memory --
	 * 
	 * 
	 */
	private static void computeDistanceOnOverlap(HashMap<String,LinkedList<Patent>> sortedClasses){
		System.out.println("Computing distances on overlaps...");
		
		int n = sortedClasses.keySet().size();
		String[] classNames = new String[n];
		int k = 0;
		for(String s:sortedClasses.keySet()){classNames[k]=s;k++;}
		
		HashSet<TechnoDistance> distances = new HashSet<TechnoDistance>();
		for(int i=0;i<n-1;i++){
			System.out.println(i);
			System.out.println(" dists : "+distances.size());
			for(int j=i+1;j<n;j++){
				System.out.println(j);
				Patent[] overlap = Overlap.overlap_array(sortedClasses.get(classNames[i]),sortedClasses.get(classNames[j]));
				System.out.println("  s : "+overlap.length);
				for(int p1 = 0;p1<overlap.length - 1;p1++){
					for(int p2=p1+1;p2<overlap.length;p2++){
						distances.add(new TechnoDistance(overlap[p1],overlap[p2]));
					}
				}
			}
		}
		
		Writer.writeSet(distances, "res/distances_on_overlaps.csv");
		
	}
	
	
	
	
	
}
