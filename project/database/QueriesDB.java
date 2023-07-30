package project.database;
public class QueriesDB {
	public static String create_type_itempack(){
		return "CREATE TYPE Itempack AS (amount INT, itemid INT);";
	}
	public static String create_table_items(){
		return "CREATE TABLE IF NOT EXISTS Items (itemid SERIAL PRIMARY KEY, name VARCHAR(32), units INT, min_prize NUMERIC(11, 2), max_prize NUMERIC(11,2), prize NUMERIC(11,2), typeid INT);";
	}
	public static String create_table_boxes(){
		return  "CREATE TABLE IF NOT EXISTS Boxes (boxid INT REFERENCES Items(itemid), min_key REAL, max_key REAL, items Itempack[], UNIQUE(boxid, min_key, max_key));";
	}
	public static String create_table_users(){
		return "CREATE TABLE IF NOT EXISTS Users(userid SERIAL PRIMARY KEY, name VARCHAR(64), hashpass BYTEA, pass_salt UUID, last_login TIME, profile_image VARCHAR(12), balance NUMERIC(11,2));";
	}
	public static String create_table_invetory(){
		return "CREATE TABLE IF NOT EXISTS Invetory(userid INT" + /*"REFERENCES Users(userid)"*/", itemid INT REFERENCES Items(itemid), amount INT, UNIQUE(userid, itemid));";
	}
	public static String item_create(){
		return "INSERT INTO Items VALUES (DEFAULT, ?, 0, ?, ?, ?, 0);"; // (:name, :min, :max, :prize)
	}
	public static String item_select_by_id(){
		return "SELECT * FROM Items WHERE itemid = ? LIMIT 1;"; // (:itemid)
	}
	public static String item_select_by_name(){
		return "SELECT * FROM Items WHERE name = ? LIMIT 1;"; // (:name)
	}
	public static String select_avaliable(){
		return "SELECT * FROM Invetory WHERE userid = ? AND single = itemid";
	}
	public static String create_table_exchange(){
		return null;
	}
}
