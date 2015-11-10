/**
 * 
 */
package patents;

import java.util.HashMap;
import java.util.HashSet;

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
		System.out.println(bound);
	}
	
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		constructClassNetwork("../../../Data/raw/classesTechno/class.csv");
	}

}
