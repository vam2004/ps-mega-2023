package project.database;
import java.util.List;
import java.util.Stack;
public class BoxBuilder {
	private List<BoxOptionSpec> options;
	public BoxBuilder(List<BoxOptionSpec> options) {
		this.options = options;
	}
	public BoxBuilder(){
		this(new Stack<BoxOptionSpec>());
	}
	public BoxOptionSpec getLast() {
		Stack<BoxOptionSpec> options = (Stack<BoxOptionSpec>) this.options;
		return options.peek();
	}
	public BoxBuilder pushContext(double probability) {
		this.options.add(new BoxOptionSpec(probability));
		return this;
	}
	public BoxBuilder push(BoxOptionSpec option) {
		this.options.add(option);
		return this;
	}
	public BoxBuilder push(Itempack item) {
		this.getLast().push(item);
		return this;
	}
	public BoxBuilder push(int amount, String name) {
		this.getLast().push(amount, name);
		return this;
	}
	public OptionFactory[] compile(double range, double min_selector) {
		BoxOptionSpec[] walker = options.toArray(new BoxOptionSpec[0]);
		int size = walker.length;
		OptionFactory[] result = new OptionFactory[size];
		for(int i = 0; i < size; i++) {
			BoxOptionSpec walker_item = walker[i];
			double max_selector = min_selector + range * walker_item.probability;
			Itempack[] items = walker_item.items.toArray(new Itempack[0]);
			result[i] = new OptionFactory(min_selector, max_selector, items);
			min_selector = max_selector;
		}
		return result;
	}
	public OptionFactory[] compile(double range) {
		return compile(range, 0.0);
	}
	public OptionFactory[] compile() {
		return compile(1.0, 0.0);
	}
}
