import hash.Sha1;
import hash.Md5;

class HashTestFunctions extends haxe.unit.TestCase {

	public function testSha() {
		assertEquals(
			"a9993e364706816aba3e25717850c26c9cd0d89d",
			Sha1.encode("abc")
		);
		assertEquals(
			"03cfd743661f07975fa2f1220c5194cbaff48451",
			Sha1.encode("abc\n")
		);
		assertEquals(
			"84983e441c3bd26ebaae4aa1f95129e5e54670f1",
			Sha1.encode("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq")
		);
	}

	function testMd5() {
		assertEquals("098f6bcd4621d373cade4e832627b4f6", Md5.encode("test"));
	}

	function testMd5Empty() {
		assertEquals("d41d8cd98f00b204e9800998ecf8427e", Md5.encode(""));
	}

#if neko
	public function testObjSha() {

		assertEquals(
			"a9993e364706816aba3e25717850c26c9cd0d89d",
			Sha1.objEncode("abc")
		);
		assertEquals(
			"03cfd743661f07975fa2f1220c5194cbaff48451",
			Sha1.objEncode("abc\n")
		);
		assertEquals(
			"84983e441c3bd26ebaae4aa1f95129e5e54670f1",
			Sha1.objEncode("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq")
		);

	}

	public function testPrintValues() {
		var o = {
			field1 : "abc",
			field2 : "def"
		}
		neko.Lib.println("\n"+ Sha1.objEncode(o));
		neko.Lib.println(Sha1.objEncode(this));

		assertEquals(1,1);
	}
#end

}

class HashTest {
	static function main() 
	{
		var r = new haxe.unit.TestRunner();
		r.add(new HashTestFunctions());
		r.run();
	}
}
