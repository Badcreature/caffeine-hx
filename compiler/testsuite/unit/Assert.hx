package unit;

import haxe.PosInfos;

class Assert {
  public static function isTrue(c : Bool, ?message : String, ?p : PosInfos) {
    if(message == null)
	  message = "Assertion failed (is true)";
    if(!c) throw new AssertException(p, message);
  }
  
  public static function equals(a : Dynamic, b : Dynamic, ?message : String, ?p : PosInfos) {
    if(message == null) message = "Assertion failed: expected value was " + Std.string(a) + " but it is " + Std.string(b);
    isTrue(a == b, message, p);
  }
  
  public static function differents(a : Dynamic, b : Dynamic, ?message : String, ?p : PosInfos) {
    if(message == null) message = "Assertion failed: expected value was different from " + Std.string(a);
    isTrue(a != b, message, p);
  }
  
  public static function isNotNull(o : Dynamic, ?message : String, ?p : PosInfos) {
	if(message == null) message = "Assertion failed: expected NOT null";
    isTrue(o !== null, message, p);
  }
  
  public static function isNull(o : Dynamic, ?message : String, ?p : PosInfos) {
	if(message == null) message = "Assertion failed: expected null but it is " + Std.string(o);
    isTrue(o === null, message, p);
  }
  
  public static function fail(?message : String, ?p : PosInfos) {
    isTrue(false, "Assertion failed (force fail)", p);
  }
}