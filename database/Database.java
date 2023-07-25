package database;
import java.sql.*;
public class Database {
	private Connection db;
	public Database(String url, String username, String password) throws SQLException {
		this.db = DriverManager.getConnection(url, username, password);
	}
	static public void create_tables(Connection database) throws SQLException {
		Statement st = database.createStatement();
		String ItempackQuery = QueriesDB.create_type_itempack();
		String BoxpackQuery = QueriesDB.create_type_boxpack();
		if(new NoThrowUpdateQuery(st, ItempackQuery).iserror()){
			System.out.println("[SILENT ERROR] sql.type 'Itempack' may exists");
		}
		if(new NoThrowUpdateQuery(st, BoxpackQuery).iserror()) {
			System.out.println("[SILENT ERROR] sql.type 'Boxpack' may exists");
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
		String url = "jdbc:postgresql:hello";
		// System.out.println("Connecting with: " + url);
		Connection con = DriverManager.getConnection(url, "postgres", "");
		Statement st = con.createStatement();
		con.setAutoCommit(false);
		Savepoint original_state = con.setSavepoint();
		try {
			/*st.executeUpdate("CREATE TABLE world(key INT PRIMARY KEY, data VARCHAR(10));");
			st.executeUpdate("INSERT INTO world VALUES(1, 'I am buzy');");
			st.executeUpdate("INSERT INTO world VALUES(2, 'Give up!');");
			ResultSet rs1 = st.executeQuery("SELECT * FROM world;");
			while(rs1.next()) {
				String row = String.format("key: %d, data: %s", rs1.getInt(1), rs1.getString(2));
				System.out.println(row);
			}*/
			create_tables(con);
			String selectTableQuery = QueriesDB.Debug.select_table_name();
			String selectSchemaQuery = QueriesDB.Debug.select_table_schema();
			PreparedStatement selectSchema = con.prepareStatement(selectSchemaQuery);
			ResultSet rs2 = st.executeQuery(selectTableQuery);
			while(rs2.next()) {
				String table_name = rs2.getString(1);
				System.out.println(table_name);
				selectSchema.clearParameters();
				selectSchema.setString(1, table_name);
				ResultSet rs3 = selectSchema.executeQuery();
				while(rs3.next()){
					String column_name = rs3.getString(1);
					String data_type = rs3.getString(2);
					int char_max_len = rs3.getInt(3);
					String row = String.format("%s,%s,%d", column_name, data_type, char_max_len);
					System.out.println(row);
				}
				rs3.close();
			}
			
		} finally {
			con.rollback(original_state);
			con.setAutoCommit(true);
		}
		
	}
}
