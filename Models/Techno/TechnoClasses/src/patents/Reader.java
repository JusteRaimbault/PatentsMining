/**
 * 
 */
package patents;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.HashMap;
import java.util.HashSet;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Reader {
	
	public static HashMap<String,HashSet<Patent>> importFromFile(String file){
		HashMap<String,HashSet<Patent>> res = new HashMap<String,HashSet<Patent>>();
		try{
		   BufferedReader r = new BufferedReader(new FileReader(new File(file)));
		   String currentLine = r.readLine();int i = 0;
		   while(currentLine != null){
			   String[] t = currentLine.split(",");
			   Patent p = Patent.construct(t[0]);
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
	
}
