package database;
import java.sql.SQLException;
import java.sql.Statement;
public class NoThrowUpdateQuery {
	private int affected;
	private boolean sucess;
	public static NoThrowUpdateQuery run(Statement database, String query) {
		try {
			int affected = database.executeUpdate(query);
			return new NoThrowUpdateQuery(affected, true);
		} catch (SQLException error) {
			return new NoThrowUpdateQuery(0, false);
		}
	}
	private NoThrowUpdateQuery(int affected, boolean sucess) {
		this.affected = affected;
		this.sucess = sucess;
	}
	public boolean issucess(){
		return sucess;
	}
	public boolean iserror(){
		return !sucess;
	}
}
