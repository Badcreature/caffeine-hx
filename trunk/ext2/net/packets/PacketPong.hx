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

/**
	Pong packet
**/
class PacketPong extends net.Packet {
	public var pingId : Int;
	public var ping_timestamp : Float;
	/** timestamp on other machine **/
	public var remote_timestamp(default,null) : Float;
	/** time at which this packet was received **/
	public var received_timestamp(default,null) : Float;

	public function new(p : PacketPing) {
		super();
		this.pingId = p.pingId;
		this.ping_timestamp = p.timestamp;
		this.remote_timestamp = Date.now().getTime();
		this.received_timestamp = this.remote_timestamp;
	}

	override function toBytes(buf:haxe.io.BytesOutput) : Void {
		buf.writeInt31(this.pingId);
		buf.writeFloat(this.ping_timestamp);
		buf.writeFloat(this.remote_timestamp);
	}

	override function fromBytes(buf : haxe.io.BytesInput) : Void {
		this.pingId = buf.readInt31();
		this.ping_timestamp = buf.readFloat();
		this.remote_timestamp = buf.readFloat();
	}

	inline static var VALUE : Int = 0x3B;

	static function __init__() {
		net.Packet.register(VALUE, PacketPong);
	}

	override public function getValue() : Int {
		return VALUE;
	}

	/**
		Get time required for ping/pong
	**/
	public function getRoundTripTime() : Float {
		return received_timestamp - ping_timestamp;
	}

	/**
		Returns the time offset for the remote system clock
	**/
	public function getRemoteTimeOffset() : Float {
		return remote_timestamp - ping_timestamp - (getRoundTripTime() / 2.0);
	}
}
