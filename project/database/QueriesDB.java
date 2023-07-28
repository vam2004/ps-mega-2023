package database;
public class QueriesDB {
	public static String create_type_itempack(){
		return "CREATE TYPE Itempack AS (amount INT, itemid INT);";
	}
	public static String create_type_boxpack(){
		return "CREATE TYPE Boxpack AS (items Itempack[], min_key REAL, max_key REAL);";
	}
	public static String create_table_items(){
		return "CREATE TABLE IF NOT EXISTS Items (itemid SERIAL PRIMARY KEY, name VARCHAR(32),"
				+ "units INT, min_prize NUMERIC(11, 2), max_prize NUMERIC(11,2),"
				+ "prize NUMERIC(11,2), typeid INT);";
	}
	public static String create_table_boxes(){
		return  "CREATE TABLE IF NOT EXISTS Boxes (itemid INT PRIMARY KEY REFERENCES Items(itemid),"
				+ "options Boxpack[]);";
	}
	public static String create_table_users(){
		return "CREATE TABLE IF NOT EXISTS Users(userid SERIAL PRIMARY KEY, name VARCHAR(64),"
				+ "hashpass BYTEA, pass_salt UUID, last_login TIME, profile_image VARCHAR(12));";
	}
	public static String create_table_invetory(){
		return "CREATE TABLE IF NOT EXISTS Invetory(userid INT PRIMARY KEY"
				+ /*"REFERENCES Users(userid)"*/", avaliable Itempack[])";
	}
	public static String create_table_exchange(){
		return null;
	}
}
