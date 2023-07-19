package database;
import java.sql.*;
public class Database {
	private Connection db;
	public Database(String url, String username, String password) throws SQLException {
		this.db = DriverManager.getConnection(url, username, password);
	}
	static public void test() throws SQLException {
		String url = "jdbc:postgresql:postgres";
		// System.out.println("Connecting with: " + url);
		Connection con = DriverManager.getConnection(url, "postgres", "");
		Statement st = con.createStatement();
		//st.executeQuery("CREATE DATABASE hello;");
		con.setAutoCommit(false);
		Savepoint original_state = con.setSavepoint();
		try {
			st.executeQuery("CREATE TABLE world(key INT PRIMARY KEY, data STRING);").close();
			st.executeQuery("INSERT INTO world VALUES(1, 'I am buzy'").close();
			st.executeQuery("INSERT INTO world VALUES(2, 'Give up!'").close();
			ResultSet rs = st.executeQuery("SELECT * FROM world");
			while(rs.next()) {
				String row = String.format("key: %d, data: %s", rs.getInt(1), rs.getString(2));
				System.out.println(row);
			}
		} finally {
			con.rollback(original_state);
			con.setAutoCommit(true);
			
		}
		
	}
}