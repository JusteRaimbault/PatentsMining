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

	
	
	public static void exportYearlyClasses(String classFile,String patentFile,String dateType,int[] years,int sizeThreshold,String outdir){
		(new File(outdir)).mkdir();
		HashMap<String,HashSet<Patent>> allclasses = classesWithDates(classFile,patentFile,dateType);
		for(int year:years){
			System.out.println("Exporting year "+year);
			HashMap<String,HashSet<Patent>> yearlyclasses = getYearlyClasses(allclasses,dateType,year,sizeThreshold);
			int clind = 0;HashMap<String,Integer> clinds = new HashMap<String,Integer>();
			HashSet<Patent> uniquePatents = new HashSet<Patent>();
			for(String cl:yearlyclasses.keySet()){
				clinds.put(cl, new Integer(clind));clind++;
				for(Patent p:yearlyclasses.get(cl)){uniquePatents.add(p);}
			}
			LinkedList<String[]> c = new LinkedList<String[]>();
			String[] header = new String[yearlyclasses.keySet().size()+1];
			for(String cl:yearlyclasses.keySet()){header[clinds.get(cl).intValue()+1]=cl;};header[0]="ID";
			c.add(header);
			for(Patent p:uniquePatents){
				String[] row = new String[yearlyclasses.keySet().size()+1];
				row[0]=p.id;
				if(p.classes.size()>0){
					for(String pcl:p.classes){
						if(clinds.containsKey(pcl)){
							row[clinds.get(pcl).intValue()+1]=(new Double(1.0/p.classes.size())).toString();
						}
					}
				}
				c.add(row);
			}
			Writer.writeCSV(c, outdir+"/technoProbas_"+year+"_sizeTh"+sizeThreshold);
		}
		
	}
	
	
	
	public static void exportClassesTimeSeries(String classFile,String patentFile,String dateType,int sizeThreshold,String outdir){
		(new File(outdir)).mkdir();
		HashMap<String,LinkedList<Patent>> sclasses = constructTimelySortedClasses(classFile,patentFile,dateType);
		for(String className:sclasses.keySet()){
			if(sclasses.get(className).size()>sizeThreshold){
				LinkedList<String[]> c = new LinkedList<String[]>();
				for(Patent p:sclasses.get(className)){String[] d = {p.id,p.dates.get(dateType).toString()};c.add(d);}
				Writer.writeCSV(c, outdir+"/"+className);
			}
		}
	}
	
	
	
	public static HashMap<String,HashSet<Patent>> getYearlyClasses(HashMap<String,HashSet<Patent>> classes,String dateType,int year,int sizeThreshold){
		
		HashMap<String,HashSet<Patent>> res = new HashMap<String,HashSet<Patent>>();
		for(String cl:classes.keySet()){
			HashSet<Patent> pcl = new HashSet<Patent>();
			for(Patent p:classes.get(cl)){if(p.years.get(dateType).intValue()==year){pcl.add(p);}}
			if(pcl.size()>=sizeThreshold){res.put(cl, pcl);}
		}
		return(res);
	}
	
	
	public static HashMap<String,LinkedList<Patent>> constructTimelySortedClasses(String classFile,String patentFile,String dateType){
		// import raw classes
		HashMap<String,HashSet<Patent>> classes = classesWithDates(classFile,patentFile,dateType);
		return(sortClasses(classes,new TimeComparator(dateType)));
	}
	
	private static HashMap<String,HashSet<Patent>> classesWithDates(String classFile,String patentFile,String dateType){
		// import raw classes
		HashMap<String,HashSet<Patent>> classes = Reader.importFromFile(classFile);

		// import dates
		LinkedList<String> fields = new LinkedList<String>();fields.add(dateType);
		Reader.readPatentData(patentFile,fields);

		ensureConsistentDates(classes,dateType);
		
		return(classes);
	}

	
	private static void ensureConsistentDates(HashMap<String,HashSet<Patent>> classes,String dateType){
		for(String c:classes.keySet()){
			HashSet<Patent> toremove = new HashSet<Patent>();
			for(Patent p:classes.get(c)){
				if(!p.dates.containsKey(dateType)){toremove.add(p);}
			}
			for(Patent r:toremove){classes.get(c).remove(r);}
		}
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
