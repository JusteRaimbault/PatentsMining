/**
 * 
 */
package patents;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Reader {
	
	
	/**
	 * read data in place
	 *   -- PATENTS ASSUMED ALREADY CONSTRUCTED -- (if not does not construct classes)
	 * 
	 * @param fields : field names of csv file
	 */
	public static void readPatentData(String file,LinkedList<String> fields){
		try{
			BufferedReader r = new BufferedReader(new FileReader(new File(file)));
			String currentLine = r.readLine();
			// read and parse first line, assumed to have required fields -> find index
			String[] csvFields = currentLine.split(",");HashMap<String,Integer> fieldIndexes = new HashMap<String,Integer>();
			for(int k=0;k<csvFields.length;k++){
				for(String f:fields){if(f.equals(csvFields[k])){fieldIndexes.put(f, new Integer(k));}}
			}
			
			Patent currentPatent = null;
			HashMap<String,String> entries = new HashMap<String,String>();
			// read the whole file
			int i=0;currentLine = r.readLine();
			while(currentLine != null){
				String[] t = currentLine.split(",");
				currentPatent = Patent.construct(t[0]);entries.clear();
				for(String f:fieldIndexes.keySet()){entries.put(f, t[fieldIndexes.get(f).intValue()]);}
				currentPatent.setFields(entries);
				currentLine = r.readLine();i++;if(i % 100000 == 0){System.out.println(i);}
			}
			
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	
	/**
	 * Import patents from class file
	 * 
	 * @param file
	 * @return
	 */
	public static HashMap<String,HashSet<Patent>> importFromFile(String file){
		HashMap<String,HashSet<Patent>> res = new HashMap<String,HashSet<Patent>>();
		try{
		   BufferedReader r = new BufferedReader(new FileReader(new File(file)));
		   String currentLine = r.readLine();int i = 0;
		   while(currentLine != null){
			   String[] t = currentLine.split(",");
			   Patent p = Patent.construct(t[0]);
			   p.classes.add(t[2]);
			   if(res.containsKey(t[2])){
				   res.get(t[2]).add(p);
			   }else{
				   HashSet<Patent> c = new HashSet<Patent>(500000);
				   c.add(p);
				   res.put(t[2], c);
			   }
			   currentLine = r.readLine();i++;if(i % 100000 == 0){System.out.println(i);}
		   }
		}catch(Exception e){e.printStackTrace();}
		return res;
	}
	
	
	public static LinkedList<String[]> readCSV(String file,String delimiter){
		LinkedList<String[]> res = new LinkedList<String[]>();
		try{
		   BufferedReader r = new BufferedReader(new FileReader(new File(file)));
		   String currentLine = r.readLine();
		   while(currentLine != null){
			   res.add(currentLine.split(delimiter));
			   currentLine=r.readLine();
		   }
		}catch(Exception e){e.printStackTrace();}
		return(res);
	}
	
	
}
