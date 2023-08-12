package project.database;
public class Itempack {
	private int itemid;
	private String name;
	private int amount;
	public static final int NO_ID = -1;
	public Itempack(int itemid, int amount, String name) {
		this.itemid = itemid;
		this.amount = amount;
		this.name = name;
	}
	public Itempack(int itemid, int amount) {
		this(itemid, amount, null);
	}
	public Itempack(int amount, String name) {
		this(NO_ID, amount, name);
	}
	public String toString() {
		if(name != null) {
			return String.format("(%d, \"%s\")", amount, name);
		} else {
			return String.format("(%d, \"%d\")", amount, itemid);
		}
	}
}
