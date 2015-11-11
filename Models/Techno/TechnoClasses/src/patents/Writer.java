/**
 * 
 */
package patents;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Writer {

	public static void writeCSV(int[][] data,String file){
		try{
			BufferedWriter w = new BufferedWriter(new FileWriter(new File(file)));
			for(int i=0;i<data.length;i++){
				for(int j = 0;j<data[i].length;j++){
					w.write(data[i][j]);if(j<data[i].length-1){w.write(";");}
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
				w.write(data[i]);
				w.write("\n");
			}
			w.close();
		}catch(Exception e){e.printStackTrace();}
	}


}
