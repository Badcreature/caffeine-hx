package {

public class E4X {
	public var xml:XML =
<data>
	<user user_id="1" group_name="friends">
		<name>Surly Craigsworth</name>
		<country>USA</country>
		<weight>400</weight>
	</user>
	<user user_id="2" group_name="work">
		<name>Nordan Jordan</name>
		<country>Canada</country>
		<weight>90</weight>
	</user>
	<user user_id="3" group_name="friends">
		<name>Jophas Morian</name>
		<country>Italy</country>
		<weight>150</weight>
	</user>
	<user user_id="4" group_name="work">
		<name>Garth Riddleberg</name>
		<country>USA</country>
		<weight>450</weight>
	</user>
	<group group_id="1" group_name="work">
		<user user_id="5" group_name="work">
			<name>James Spade</name>
			<country>Egypt</country>
			<weight>250</weight>
		</user>
	</group>
</data>;

	public static function main() {
		var e = new E4X();
		e.getFirstUser();
		e.iterateOver();
		e.iterate2();
		e.findUser();
		e.filter();
	}

	public function getFirstUser() {
		var userXml:XML = xml.user[0];
		// userXml here is a FastXML object
		trace(userXml);
	}

	public function iterateOver() {
		var numUsers:uint = xml.user.length();
		for (var i:uint = 0; i < numUsers; i++) {
			var iUser:XML = xml.user[i];
			// iUser.@user_id should parse to iUser.att.user_id
			// iUser.name should parse to iUser.node.name.innerData
			trace(iUser.@user_id + " " + iUser.name);
		}
	}

	public function iterate2() {
		for each (var iUser:XML in xml.user) {
			trace(iUser.@user_id + " " + iUser.name);
		}
	}

	public function findUser() {
		var user3:XMLList = xml.user.(@user_id == 3);
		trace(user3[0].name);
	}

	public function filter() {
		var bigUsers:XMLList = xml.user.(weight > 300);
		for each (var iUser:XML in bigUsers)
			trace("Big user is " + iUser.name + " from group " + iUser.@group_name);
	}

/*
	public function filterWithDescending() {
		// this should include users in the <group> as well
		var bigUsers:XMLList = xml.descendants().user.(weight > 300);
	}

	public function setAttribute() {
		var userXml:XML = xml.user[0];
		userXml.@["group_name"] = "enemies";
		trace(userXml.@group_name.toString());
	}
*/

}
}