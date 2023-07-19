package database;
import java.sql.*;
public class Database {
	/*private Connection db;
	public Database(String url, String username, String password) throws SQLException {
		this.db = DriverManager.getConnection(url, username, password);
	}*/
	static public void test() throws SQLException {
		String url = "jdbc:postgresql:postgres";
		/*try {
			Class.forName("org.postgresql.Driver");
		} catch(ClassNotFoundException exception) {
			System.out.println("Cannot initialize the driver");
			return;
		}*/
		System.out.println("Connecting with: " + url);
		//Database tmp = new Database(url, "postgres", "");
	}
}