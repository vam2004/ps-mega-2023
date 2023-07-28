package database;
import java.sql.Connection;
public class InjectUser {
	private int userid;
	private Connection db;
	public InjectUser(int userid, Connection db){
		this.userid = userid;
		this.db = db;
	}
	public int get_userid(){
		return this.userid;	
	}
	public Connection get_db(){
		return this.db;
	}
}