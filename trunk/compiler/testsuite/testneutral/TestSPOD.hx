package testneutral;

import unit.Assert;

import neutral.db.Connection;
import neutral.db.Mysql;
import neutral.db.Manager;

class TestSPOD {
	public function new() { }
	
	function createSql() {
		return "CREATE TABLE User (
    id INT NOT NULL auto_increment,
    name VARCHAR(32) NOT NULL,
    age INT NOT NULL,
    PRIMARY KEY  (id)
) ENGINE=InnoDB;";
	}
	
	public function setup() {
		Manager.cnx = Mysql.connect({
			host     : "localhost",
			port     : null,
			user     : "root",
			pass     : "",
			socket   : null,
			database : "test"
		});
		if(Manager.cnx == null)
			throw "DB Connection Failed";
		Manager.initialize();
		Manager.cnx.request(createSql());
	}
	
	function dropSql() {
		return "DROP TABLE User;";
	}
	
	public function teardown() {
		if(Manager.cnx != null) {
			Manager.cnx.request(dropSql());
			Manager.cleanup();
			Manager.cnx.close();			
		}
	}
	
	public function testUse() {
		Assert.equals(0, User.manager.count());
		var user = new User();
		user.id   = 1;
		user.name = "haXe";
		user.age  = 3;
		user.insert();
		Assert.equals(1, User.manager.count());
		user = User.manager.get(1);
		Assert.equals(1, user.id);
		Assert.equals("haXe", user.name);
		Assert.equals(3, user.age);
		user.age++;
		user.update();
		user = User.manager.get(1);
		Assert.equals(4, user.age);
		user.delete();
		Assert.equals(0, User.manager.count());
	}
	
}

class User extends neutral.db.Object {
    public var id : Int;
    public var name : String;
    public var age : Int;
    
    public static var manager = new neutral.db.Manager<User>(User);
}