package syntax;

import unit.Assert;

class ArraySyntax {
	public function new() {}
	
	public function testCreateEmpty() {
		var o = [];
		Assert.isNotNull(o);
	}
	
	public function testCreateFilled() {
		var o = [ "haXe" , "Neko" ];
		Assert.equals(2, o.length);
	}
	
	public function testAccessElement() {
		var o = [ "haXe" , "Neko" ];
		Assert.equals("haXe", o[0]);
		Assert.equals("Neko", o[1]);
	}
	
	public function testReplaceElement() {
		var o = [ "haXe" , "Neko" ];
		Assert.equals("haXe", o[0]);
		o[0] = "swfmill";
		Assert.equals("swfmill", o[0]);
		Assert.equals("Neko", o[1]);
	}	
}