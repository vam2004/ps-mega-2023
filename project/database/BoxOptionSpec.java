package project.database;
public class BoxOptionSpec {
	private double probability;
	private Itempack[] items;
	public BoxOptionSpec(double probability, Itempack[] items){
		this.probability = probability;
		this.items = items;
	}
}

