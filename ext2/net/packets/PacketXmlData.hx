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

package net.packets;

class PacketXmlData extends net.Packet {
	inline static var VALUE : Int = 0x3C;

	static function __init__() {
		net.Packet.register(VALUE, PacketXmlData);
	}

	public var data : String;

	override public function getValue() : Int {
		return VALUE;
	}

	override function toBytes(buf : haxe.io.Output) : Void {
		var b = haxe.io.Bytes.ofString(data);
		buf.writeBytes(b, 0, b.length);
		buf.writeByte(0);
	}

	override function fromBytes(buf : haxe.io.Input) : Void {
		var bb = new haxe.io.BytesBuffer();
		var byte = 255;
		while(true) {
			byte = buf.readByte();
			if(byte == 0)
				break;
			bb.addByte(byte);
		}
		data = bb.getBytes().toString();
	}
}