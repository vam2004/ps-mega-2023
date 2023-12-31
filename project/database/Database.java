package project.database;
import java.sql.*;
public class Database {
	private Connection db;
	public Database(String url, String username, String password) throws SQLException {
		this.db = DriverManager.getConnection(url, username, password);
	}
	static public void create_tables(Connection database) throws SQLException {
		Statement st = database.createStatement();
		String ItempackQuery = QueriesDB.create_type_itempack();
		if(NoThrowUpdateQuery.run(st, ItempackQuery).iserror()){
			System.out.println("[SILENT ERROR] sql.type 'Itempack' may exists");
		}
		String ItemsQuery = QueriesDB.create_table_items();
		String BoxesQuery = QueriesDB.create_table_boxes();
		String UserQuery = QueriesDB.create_table_users();
		String InvetoryQuery = QueriesDB.create_table_invetory();
		st.executeUpdate(ItemsQuery);
		st.executeUpdate(BoxesQuery);
		st.executeUpdate(UserQuery);
		st.executeUpdate(InvetoryQuery);
	}
	static public void test() throws SQLException {
		String url = "jdbc:postgresql://db:5432/megadb";
		// System.out.println("Connecting with: " + url);
		Connection con = DriverManager.getConnection(url, "postgres", "asylium");
		Statement st = con.createStatement();
		create_tables(con);
		con.setAutoCommit(false);
		Savepoint original_state = con.setSavepoint();
		try {
			st.executeUpdate("CREATE TABLE world(key INT PRIMARY KEY, data VARCHAR(10));");
			st.executeUpdate("INSERT INTO world VALUES(1, 'I am buzy');");
			st.executeUpdate("INSERT INTO world VALUES(2, 'Give up!');");
			ResultSet rs1 = st.executeQuery("SELECT * FROM world;");
			while(rs1.next()) {
				String row = String.format("key: %d, data: %s", rs1.getInt(1), rs1.getString(2));
				System.out.println(row);
			}
		} finally {
			con.rollback(original_state);
			con.setAutoCommit(true);
		}
	}
	// set max_prize=0 to unset prize bondaries
	public void create_item(String name, double prize, double min_prize, double max_prize) throws SQLException {
		String query = QueriesDB.item_create();
		PreparedStatement st = this.db.prepareStatement(query);
	}
	public void create_item(String name, double prize, double min_prize) throws SQLException {
		create_item(name, prize, min_prize, 0.0);
	}
	public void create_item(String name, double prize) throws SQLException {
		create_item(name, prize, 0.0);
	}
}
