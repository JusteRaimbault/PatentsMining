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
		//Classes.exportClassesTimeSeries("../../../Data/raw/classesTechno/class.csv",
		//		"../../../Data/raw/patent/patent.csv", "AppDate", 1000, "res/sizes_appdate");
		//String[] citFiles = {"../../../Data/raw/citation/citation75_99.csv","../../../Data/raw/citation/citation00_10.csv"};
		//CitationNetwork.computeOriginalities("../../../Data/raw/classesTechno/class.csv", 
		//		"../../../Data/raw/patent/patent.csv", "AppDate", citFiles, "res/originalities_appdate", 1000);
		
		int[] years=new int[37];for(int i = 0;i<37;i++){years[i]=i+1976;}
		Classes.exportYearlyClasses("../../../Data/raw/classesTechno/class.csv",
				"../../../Data/raw/patent/patent.csv", "GDate",years,10,"res/technoPerYear");
	}

}
