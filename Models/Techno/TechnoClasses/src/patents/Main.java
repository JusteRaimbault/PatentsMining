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
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		//HashMap<String,LinkedList<Patent>> sortedClasses = Classes.constructSortedClasses("../../../Data/raw/classesTechno/class.csv");
		//computeOverlap(sortedClasses);
		//computeDistanceOnOverlap(sortedClasses);
		//computeSecondOrderOverlaps(sortedClasses);
		//Distances.computeDistancesOnSecondOrderOverlaps(sortedClasses);
		Classes.exportClassesTimeSeries("../../../Data/raw/classesTechno/class.csv",
				"../../../Data/raw/patent/patent.csv", "GDate", 1000, "res/sizes_gdate");
		
		
	}

}
