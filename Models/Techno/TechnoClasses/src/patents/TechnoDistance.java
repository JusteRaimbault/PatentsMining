/**
 * 
 */
package patents;

/**
 * @author Raimbault Juste <br/> <a href="mailto:juste.raimbault@polytechnique.edu">juste.raimbault@polytechnique.edu</a>
 *
 */
public class TechnoDistance {

	Patent patent1;
	Patent patent2;
	
	int commonClasses;
	
	double distance;
	
	public TechnoDistance(Patent p1,Patent p2){
		patent1=p1;patent2=p2;
		commonClasses=patent1.commonClasses(patent2).size();
		distance = 2.0 * commonClasses / (patent1.classes.size() + patent2.classes.size());
	}
	
	@Override
	public String toString(){
		return patent1.id+";"+patent2.id+";"+patent1.classes.size()+";"+patent2.classes.size()+";"+commonClasses+";"+distance;
	}
	
	// no hash needed for techno distance ; requirement on overlap already met.
	/*
	@Override
	public int hashCode(){
		return patent1.hashCode()+patent2.hashCode();
	}
	
	@Override
	public boolean equals(Object o){
		return (o instanceof TechnoDistance)&&
				((((TechnoDistance)o).patent1.equals(patent1)&&((TechnoDistance)o).patent2.equals(patent2))||
				(((TechnoDistance)o).patent1.equals(patent2)&&((TechnoDistance)o).patent2.equals(patent1)));
	}
	*/
}
