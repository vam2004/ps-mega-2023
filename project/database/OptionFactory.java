package project.database;
import java.lang.StringBuilder;
public class OptionFactory {
	public double min_selector;
	public double max_selector;
	public Itempack[] items;
	public OptionFactory(double min_selector, double max_selector, Itempack[] items) {
		this.min_selector = min_selector;
		this.max_selector = max_selector;
		this.items = items;
	}
	public String toString() {
		String format = "{ (%f,%f), [%s]}";
		int size = items.length;
		StringBuilder builder = new StringBuilder();
		if(size > 0) {
			builder.append(items[0].toString());
		}
		for(int i = 1; i < size; i++){
			builder.append(", ");
			builder.append(items[i].toString());
		}
		
		return String.format(format, min_selector, max_selector, builder.toString());
	}
}