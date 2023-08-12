package project.database;
import java.sql.SQLException;
class Main {
	public static void main(String[] args) throws SQLException {
		System.out.println("[DEBUG] starting program!");
		Database.test();
		BoxBuilder tmp = new BoxBuilder();
		tmp.pushContext(0.2).push(5, "Hello World").push(16, "Ajax");
		tmp.pushContext(0.4).push(7, "Friend Oath").push(11, "Nothing");
		tmp.pushContext(0.2).push(4, "Wonderland").push(2, "Freak Show");
		OptionFactory[] options = tmp.compile();
		for(int i = 0; i < options.length; i++) {
			System.out.println(options[i].toString());
		}
	}
}
