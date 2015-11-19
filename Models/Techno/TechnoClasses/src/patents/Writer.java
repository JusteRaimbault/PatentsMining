/**
 * 
 */
package patents;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.LinkedList;
import java.util.Set;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Writer {

	
	public static <T extends Object> void writeSet(Set<T> data,String file){
		try{
			BufferedWriter w = new BufferedWriter(new FileWriter(new File(file)));
			for(T o:data){
				w.write(o.toString());
				w.write("\n");
			}
			w.close();
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	public static <T extends Object> void writeList(LinkedList<T> data,String file){
		try{
			BufferedWriter w = new BufferedWriter(new FileWriter(new File(file)));
			for(T o:data){
				w.write(o.toString());
				w.write("\n");
			}
			w.close();
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	public static void writeCSV(LinkedList<int[]> data,String file){
		try{
			BufferedWriter w = new BufferedWriter(new FileWriter(new File(file)));
			for(int[] r:data){
				for(int j = 0;j<r.length;j++){
					w.write(new Integer(r[j]).toString());if(j<r.length-1){w.write(";");}
				}
				w.write("\n");
			}


			w.close();
		}catch(Exception e){e.printStackTrace();}
	}
	
	
	public static void writeCSV(int[][] data,String file){
		try{
			BufferedWriter w = new BufferedWriter(new FileWriter(new File(file)));
			for(int i=0;i<data.length;i++){
				for(int j = 0;j<data[i].length;j++){
					w.write(new Integer(data[i][j]).toString());if(j<data[i].length-1){w.write(";");}
				}
				w.write("\n");
			}


			w.close();
		}catch(Exception e){e.printStackTrace();}
	}
	
	public static void writeCSV(int[] data,String file){
		try{
			BufferedWriter w = new BufferedWriter(new FileWriter(new File(file)));
			for(int i=0;i<data.length;i++){
				w.write(new Integer(data[i]).toString());
				w.write("\n");
			}
			w.close();
		}catch(Exception e){e.printStackTrace();}
	}


}
