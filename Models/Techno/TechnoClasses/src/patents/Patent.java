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
public class Patent {
	
	
	public static final HashMap<Patent,Patent> patents = new HashMap<Patent,Patent>(10000000);
	
	public String id;
	
	public HashSet<String> classes;
	
	public Patent(String s){id=s;}
	
	public static Patent construct(String s){
		Patent newP = new Patent(s);
		if(patents.containsKey(newP)){
			return patents.get(newP);
		}else{
			newP.classes = new HashSet<String>();
			patents.put(newP, newP);
			return(newP);
		}
	}
	
	
	@Override
	public int hashCode(){
		return id.hashCode();
	}
	
	@Override
	public boolean equals(Object o){
		return (o instanceof Patent)&&(((Patent)o).id.equals(id));
	}
	
	
}
