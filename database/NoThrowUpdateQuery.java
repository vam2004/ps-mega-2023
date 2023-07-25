package database;
import java.sql.SQLException;
import java.sql.Statement;
public class NoThrowUpdateQuery {
	private int affected;
	private boolean sucess;
	public NoThrowUpdateQuery(Statement database, String query) {
		try {
			affected = database.executeUpdate(query);
			sucess = true;
		} catch (SQLException error) {
			sucess = false;
		}
	}
	public boolean issucess(){
		return sucess;
	}
	public boolean iserror(){
		return !sucess;
	}
}