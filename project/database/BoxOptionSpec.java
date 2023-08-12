package project.database;
import java.util.List;
import java.util.Stack;
public class BoxOptionSpec {
	public double probability;
	public List<Itempack> items;
	public BoxOptionSpec(double probability, List<Itempack> items){
		this.probability = probability;
		this.items = items;
	}
	public BoxOptionSpec(double probability) {
		this(probability, new Stack<Itempack>());
	}
	public BoxOptionSpec push(Itempack item){
		this.items.add(item);
		return this;
	}
	// shortcut to this.addItem(Itempack(amount, name))
	public BoxOptionSpec push(int amount, String name) {
		this.push(new Itempack(amount, name));
		return this;
	}
}

