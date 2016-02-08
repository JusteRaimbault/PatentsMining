/**
 * 
 */
package patents;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Patent implements Comparable<Patent>{
	
	
	/**
	 * Hashconsing on all patents
	 */
	public static final HashMap<Patent,Patent> patents = new HashMap<Patent,Patent>(10000000);
	
	/**
	 * unique id
	 */
	public String id;
	
	/**
	 * techno classes for this patent
	 */
	public HashSet<String> classes;
	
	
	/**
	 * dates : AppDate and/or GDate
	 */
	public HashMap<String,Long> dates;
	
	
	/**
	 * Citing patents.
	 */
	public HashSet<Citation> citing;
	
	/**
	 * Cited patents.
	 */
	public HashSet<Citation> cited;
	
	
	
	public Patent(String s){id=s;}
	
	public static Patent construct(String s){
		Patent newP = new Patent(s);
		if(patents.containsKey(newP)){
			return patents.get(newP);
		}else{
			newP.classes = new HashSet<String>();
			newP.dates = new HashMap<String,Long>();
			newP.citing = new HashSet<Citation>();newP.cited = new HashSet<Citation>();
			patents.put(newP, newP);
			return(newP);
		}
	}
	
	
	/**
	 * set fields -- only date implemented for now. 
	 *  
	 * @param entries
	 */
	public void setFields(HashMap<String,String> entries){
		for(String field:entries.keySet()){
			if(field.equals("AppDate")||field.equals("GDate")){
				try{
					String sdate = entries.get(field);
					// parse date
					DateFormat dfm = new SimpleDateFormat("yyyy-MM-dd");
					Long date = new Long(dfm.parse(sdate).getTime());
					dates.put(field,date);
				}catch(Exception e){
					e.printStackTrace();
				}
			}
		}
	}
	
	
	
	/**
	 * Computes common classes.
	 * 
	 * @param p
	 * @return
	 */
	public HashSet<String> commonClasses(Patent p){
		// 2-3 classes per patent, can do it dirty
		HashSet<String> res = new HashSet<String>();
		for(String c:classes){
			for(String c2:p.classes){
				if(c.equals(c2)){res.add(c);}
			}
		}
		return res;
	}
	
	/**
	 * computes originality assuming 
	 * @return
	 */
	public double originality(){
		int totalCited = 0;
		HashMap<String,Integer> citationClasses = new HashMap<String,Integer>();
		for(Citation cit:cited){
			for(String c:cit.cited.classes){
				if(!citationClasses.containsKey(c)){citationClasses.put(c, new Integer(0));}
				citationClasses.put(c,new Integer(citationClasses.get(c).intValue()+1));
				totalCited++;
			}
		}
		double res = 1;
		for(String c:classes){
			if(citationClasses.containsKey(c)){res = res - ((citationClasses.get(c)*1.0/totalCited)* (citationClasses.get(c)*1.0/totalCited));}
		}
		return(res);
	}
	
	
	@Override
	public int hashCode(){
		return id.hashCode();
	}
	
	@Override
	public boolean equals(Object o){
		return (o instanceof Patent)&&(((Patent)o).id.equals(id));
	}
	
	@Override
	public int compareTo(Patent p){
		return id.compareTo(p.id);
	}
	
	
	public static Patent[] listToArray(LinkedList<Patent> l){
		Patent[] res = new Patent[l.size()];
		int i=0;
		for(Patent p:l){
			res[i]=p;
			i++;
		}
		return res;
	}
	
	
	
}
