package syntax;

import unit.Assert;
import syntax.util.ImplementsDynamic;
import syntax.util.F9Dynamic;
import syntax.util.MethodVariable;

class DynamicFunction {
	public function new() {}

	public function testInline() {
		var f = function() { return "test"; };
		Assert.equals("test", f());
	}
  
	public function testLocalExecution() {
		Assert.equals("test", function() { return "test"; }());
	}
  
	public function testLocalExecutionWithParam() {
		Assert.equals("test1", function(i : Int) { return "test" + i; }(1));
	}

	function passFunction(f : Void -> String) {
		return f();
	}

	public function testArgument1() {
		var f = function() { return "test"; };
		Assert.equals("test", passFunction(f));
	}

	public function testArgument2() {
		Assert.equals("test", passFunction(function() { return "test"; }));
	}

	public function testAnonymousObject1() {
		var a = { f : function(){ return "test"; } };
		Assert.equals("test", a.f());
	}

	public function testAnonymousObject2() {
		var a : Dynamic = Reflect.empty();
		a.f = function(){ return "test"; };
		Assert.equals("test", a.f());
	}

	public function testAnonymousObject3() {
		var a = { f : f };
		Assert.equals("test", a.f());
	}

	public function testAnonymousObject4() {
		var a : Dynamic = Reflect.empty();
		a.f = f;
		Assert.equals("test", a.f());
	}

	public function testAnonymousObject5() {
		var a = { f : staticF };
		Assert.equals("test", a.f());
	}

	public function testAnonymousObject6() {
		var a : Dynamic = Reflect.empty();
		a.f = staticF;
		Assert.equals("test", a.f());
	}

	public function testImplementsDynamicAddMethod1() {
		var a = new ImplementsDynamic();
		a.f = function(){ return "test"; };
		Assert.equals("test", a.f());
	}

	public function testImplementsDynamicAddMethod2() {
		var a = new ImplementsDynamic();
		a.f = f;
		Assert.equals("test", a.f());
	}

	public function testImplementsDynamicAddMethod3() {
		var a = new ImplementsDynamic();
		a.f = staticF;
		Assert.equals("test", a.f());
	}

	public function testImplementsDynamicRedefineMethod1() {
		var a = new ImplementsDynamic();
		Assert.equals("stub", a.stub());
		a.stub = function(){ return "test"; };
		Assert.equals("test", a.stub());
	}

	public function testImplementsDynamicRedefineMethod2() {
		var a = new ImplementsDynamic();
		Assert.equals("stub", a.stub());
		a.stub = f;
		Assert.equals("test", a.stub());
	}

	public function testImplementsDynamicRedefineMethod3() {
		var a = new ImplementsDynamic();
		Assert.equals("stub", a.stub());
		a.stub = staticF;
		Assert.equals("test", a.stub());
	}

	public function testF9DynamicRedefineMethod1() {
		var a = new F9Dynamic();
		Assert.equals("stub", a.stub());
		a.stub = function(){ return "test"; };
		Assert.equals("test", a.stub());
	}

	public function testF9DynamicRedefineMethod2() {
		var a = new F9Dynamic();
		Assert.equals("stub", a.stub());
		a.stub = f;
		Assert.equals("test", a.stub());
	}

	public function testF9DynamicRedefineMethod3() {
		var a = new F9Dynamic();
		Assert.equals("stub", a.stub());
		a.stub = staticF;
		Assert.equals("test", a.stub());
	}

	public function testMethodVariable1() {
		var a = new MethodVariable();
		a.f = function(){ return "test"; };
		Assert.equals("test", a.f());
	}

	public function testMethodVariable2() {
		var a = new MethodVariable();
		a.f = f;
		Assert.equals("test", a.f());
	}

	public function testMethodVariable3() {
		var a = new MethodVariable();
		a.f = staticF;
		Assert.equals("test", a.f());
	}

	public function testStaticMethodVariable1() {
		MethodVariable.staticF = function(){ return "test1"; };
		Assert.equals("test1", MethodVariable.staticF());
	}

	public function testStaticMethodVariable2() {
		MethodVariable.staticF = f;
		Assert.equals("test", MethodVariable.staticF());
	}

	public function testStaticMethodVariable3() {
		MethodVariable.staticF = staticF;
		Assert.equals("test", MethodVariable.staticF());
		Assert.equals("test", syntax.util.MethodVariable.staticF());
	}
  
	public function testStaticMethodFullyQualifiedName() {
		Assert.equals("test", syntax.util.A.test());
		Assert.equals("test", syntax.util.A.s);
  	}

	private function f() {
		return "test";
	}

	private static function staticF() {
		return "test";
	}
}