/**
 * 
 */
package patents;

import java.io.File;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Classes {

	
	public static void exportClassesTimeSeries(String classFile,String patentFile,String dateType,int sizeThreshold,String outDir){
		(new File(outDir)).mkdir();
		HashMap<String,LinkedList<Patent>> sclasses = constructTimelySortedClasses(classFile,patentFile,dateType);
		for(String className:sclasses.keySet()){
			if(sclasses.get(className).size()>sizeThreshold){
				LinkedList<String[]> c = new LinkedList<String[]>();
				for(Patent p:sclasses.get(className)){String[] d = {p.id,p.dates.get(dateType).toString()};c.add(d);}
				Writer.writeCSV(c, outDir+"/"+className);
			}
		}
	}
	
	
	
	public static HashMap<String,LinkedList<Patent>> constructTimelySortedClasses(String classFile,String patentFile,String dateType){
		// import raw classes
		HashMap<String,HashSet<Patent>> classes = Reader.importFromFile(classFile);
		
		// import dates
		LinkedList<String> fields = new LinkedList<String>();fields.add(dateType);
		Reader.readPatentData(patentFile,fields);
		
		return(sortClasses(classes,new TimeComparator(dateType)));
		
	}
	

	public static HashMap<String,LinkedList<Patent>> constructSortedClasses(String file){
		HashMap<String,HashSet<Patent>> classes = Reader.importFromFile(file);
		return sortClasses(classes,null);
	}	
	
	/**
	 * 
	 * @param classes
	 * @return
	 */
	private static HashMap<String,LinkedList<Patent>> sortClasses(HashMap<String,HashSet<Patent>> classes,Comparator<Patent> comparator){
		HashMap<String,LinkedList<Patent>> sortedClasses = new HashMap<String,LinkedList<Patent>>();
		int i = 0;
		for(String k:classes.keySet()){
			LinkedList<Patent> l = new LinkedList<Patent>(classes.get(k));
			System.out.println("sorting class : i ; size : "+l.size());
			
			if(comparator==null){
				Collections.sort(l);
			}
			else{
				Collections.sort(l,comparator);		
			}
			
			sortedClasses.put(k, l);
		}
		return sortedClasses;
	}
	
	
	
}
