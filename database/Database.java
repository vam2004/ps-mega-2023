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
		try {
			st.executeQuery("CREATE DATABASE hello;");
		} catch(SQLException error){
			// pass
		}
		con.setAutoCommit(false);
		Savepoint original_state = con.setSavepoint();
		try {
			st.execute("CREATE TABLE world(key INT PRIMARY KEY, data VARCHAR(10));");
			st.execute("INSERT INTO world VALUES(1, 'I am buzy');");
			st.execute("INSERT INTO world VALUES(2, 'Give up!');");
			ResultSet rs = st.executeQuery("SELECT * FROM world;");
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
