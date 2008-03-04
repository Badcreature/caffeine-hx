/*
 * Copyright (c) 2008, The Caffeine-hx project contributors
 * Original author : Russell Weir
 * Contributors:
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE CAFFEINE-HX PROJECT CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE CAFFEINE-HX PROJECT CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Derived from AS3 implementation Copyright (c) 2007 Henri Torgemane
 */
/**
 * Sequence
 *
 * An ASN1 type for a Sequence, implemented as an Array
 */

package formats.der;
import ByteString;


class Sequence implements IAsn1Type
{
	var type:Int;
	var len:Int;
	var _buf : Array<Dynamic>;

	public function Sequence(?type:Int, ?length:Int) {
		if(type == null)
			type = 0x30;
		if(length == null)
			length = 0x00;
		this.type = type;
		this.len = length;
		this._buf = new Array();
	}

	public function getLength():Int
	{
		return len;
	}

	public function getType():Int
	{
		return type;
	}

	public function toDER():ByteString {
		var tmp:ByteString = new ByteString();
		for (var i:Int=0;i<length;i++) {
			var e:IAsn1Type = _buf[i];
			if (e == null) { // XXX Arguably, I could have a der.Null class instead
				tmp.writeByte(0x05);
				tmp.writeByte(0x00);
			} else {
				tmp.writeBytes(e.toDER());
			}
		}
		return DER.wrapDER(type, tmp);
	}

	public function toString():String {
		var s:String = DER.indent;
		DER.indent += "    ";
		var t:String = "";
		for(i in 0..._buf.length) {
			if (_buf[i]==null) continue;
			var found:Bool = false;
			for (var key:String in this) {
				if ( (i.toString()!=key) && _buf[i]==_buf[key]) {
					t += key+": "+_buf[i]+"\n";
					found = true;
					break;
				}
			}
			if (!found) t+=_buf[i]+"\n";
		}
//			var t:String = join("\n");
		DER.indent= s;
		return DER.indent+"Sequence["+type+"]["+len+"][\n"+t+"\n"+s+"]";
	}

	/////////

	public function findAttributeValue(oid:String):IAsn1Type {
		for each (var set:* in this) {
			if (set is Set) {
				var child:* = set[0];
				if (child is Sequence) {
					var tmp:* = child[0];
					if (tmp is ObjectIdentifier) {
						var id:ObjectIdentifier = tmp as ObjectIdentifier;
						if (id.toString()==oid) {
							return child[1] as IAsn1Type;
						}
					}
				}
			}
		}
		return null;
	}
}
