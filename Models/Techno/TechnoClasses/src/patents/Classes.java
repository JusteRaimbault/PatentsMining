/**
 * 
 */
package patents;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Classes {

	

	public static HashMap<String,LinkedList<Patent>> constructSortedClasses(String file){
		HashMap<String,HashSet<Patent>> classes = Reader.importFromFile(file);
		return sortClasses(classes);
		
	}	
	
	/**
	 * 
	 * @param classes
	 * @return
	 */
	private static HashMap<String,LinkedList<Patent>> sortClasses(HashMap<String,HashSet<Patent>> classes){
		HashMap<String,LinkedList<Patent>> sortedClasses = new HashMap<String,LinkedList<Patent>>();
		int i = 0;
		for(String k:classes.keySet()){
			LinkedList<Patent> l = new LinkedList<Patent>(classes.get(k));
			System.out.println("sorting class : i ; size : "+l.size());
			//Collections.sort(l);
			
			
			sortedClasses.put(k, l);
		}
		return sortedClasses;
	}
	
	
	
}
