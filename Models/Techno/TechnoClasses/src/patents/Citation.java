/**
 * 
 */
package patents;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class Citation {
	
	public Patent citing;
	
	public Patent cited;
	
	public long date;
	
	// simple constructor is ok, no need to do hashconsing on citation structure
	
	public Citation(Patent citi,Patent cite,long d){
		citing=citi;cited=cite;date=d;
	}
	
	public Citation(String citi,String cite,long d){
		citing=Patent.construct(citi);cited=Patent.construct(cite);date=d;
	}
	
	@Override
	public int hashCode(){
		return(citing.hashCode()+cited.hashCode());
	}
	
	@Override
	public boolean equals(Object o){
		return (o instanceof Citation)&&(((Citation)o).citing.equals(citing))&&(((Citation)o).cited.equals(cited));
	}
	
	
}
