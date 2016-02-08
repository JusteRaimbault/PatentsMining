/**
 * 
 */
package patents;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.LinkedList;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class CitationNetwork {

	
	
	public static void computeOriginalities(String classFile,String patentFile,String dateType,String[] citationFiles,String outDir,int sizeThreshold){
		HashMap<String,LinkedList<Patent>> classes = Classes.constructTimelySortedClasses(classFile,patentFile,dateType);
		for(String citationFile:citationFiles){
		   fillCitationNetwork(citationFile);
		}
		for(String className:classes.keySet()){
			if(classes.get(className).size()>sizeThreshold){
				LinkedList<String[]> c = new LinkedList<String[]>();
				String[] header = {"id","ts","originality"};
				c.add(header);
				for(Patent p:classes.get(className)){
					String[] d = {p.id,p.dates.get(dateType).toString(),new Double(p.originality()).toString()};c.add(d);
				}
				Writer.writeCSV(c, outDir+"/"+className);
			}
		}
		
	}
	
	/**
	 * Fill citation network from a csv citation file.
	 * 
	 * @param citationFile
	 */
	public static void fillCitationNetwork(String citationFile){
		System.out.println("filling it network from file "+citationFile);
		LinkedList<String[]> data = Reader.readCSV(citationFile, ",");
		for(String[] row:data){
			String cited = row[0];String citing = row[5];
			DateFormat dfm = new SimpleDateFormat("yyyy-MM-dd");
			long date = 0;try{date=dfm.parse(row[1]).getTime();}catch(Exception e){}
			//Citation citation = new Citation(citing,cited,date);
			Patent pcited = Patent.construct(cited);Patent pciting = Patent.construct(citing);
			Citation citation = new Citation(pciting,pcited,date);
			pciting.cited.add(citation);pcited.cited.add(citation);
		}
	}
}
