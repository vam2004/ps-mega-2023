package database;
import java.sql.*;
public class Database {
	private Connection db;

	public Database(String url, String username, String password) throws SQLException {
		this.db = DriverManager.getConnection(url, username, password);
	}
	static public SQLException nothrow_query(Statement database, String query) {
		try {
			database.executeUpdate(query);
			return null;
		} catch (SQLException error) {
			return error;
		}
	}
	static public void create_tables(Connection database) throws SQLException {
		Statement st = database.createStatement();
		String ItempackQuery = "CREATE TYPE Itempack AS (amount INT, itemid INT);";
		if(Database.nothrow_query(st, ItempackQuery) != null){
			System.out.println("[SILENT ERROR] 'Itempack' may exists");
		}
		String ItemsQuery = "CREATE TABLE IF NOT EXISTS Items (itemid SERIAL PRIMARY KEY,"
							+ "name VARCHAR(32), units INT, min_prize NUMERIC(11, 2),"
							+ "max_prize NUMERIC(11,2), prize NUMERIC(11,2), typeid INT);";
		String BoxesQuery = "CREATE TABLE IF NOT EXISTS Boxes (itemid INT REFERENCES Items(itemid),"
							+ "item Itempack[], min_key REAL, max_key REAL);";
		st.executeUpdate(ItemsQuery);
		st.executeUpdate(BoxesQuery);
	}
	static public void test() throws SQLException {
		String url = "jdbc:postgresql:hello";
		// System.out.println("Connecting with: " + url);
		Connection con = DriverManager.getConnection(url, "postgres", "");
		Statement st = con.createStatement();
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
			create_tables(con);
		} finally {
			con.rollback(original_state);
			con.setAutoCommit(true);
		}
		
	}
}
