/**
 * 
 */
package patents;

import java.util.Comparator;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TimeComparator implements Comparator<Patent> {
	
	
	private String dateType;
	
	
	public TimeComparator(String type){
		dateType = type;
	}
	
	
	public int compare(Patent p1,Patent p2){
		Long l1 = p1.dates.get(dateType);
		Long l2 = p2.dates.get(dateType);
		if(l1!=null&&l2!=null){
			return(l1.compareTo(l2));
		}
		else{return 0;}
	}
	
}
