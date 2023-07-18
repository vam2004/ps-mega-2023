package src;
import java.sql.*;
public class Database {
	private Connection db;
	public Database(String url, String username, String password) throws SQLException {
		this.db = DriverManager.getConnection(url, username, password);
	}
	static public void test() throws SQLException {
		String url = "jdbc:postgresql:postgres";
		Database tmp = new Database(url, "postgres", "");
	}
}