/*
 * Copyright (c) 2005, The haXe Project Contributors
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
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 *
 */
package net;


class Host {

	public var ip(default,null) : haxe.Int32;
	var name : String;

	public function new( name : String ) {
		#if neko
			ip = host_resolve(untyped name.__s);
		#else
			ip = haxe.Int32.ofInt(0);
		#end
		this.name = name;
	}

	public function toString() : String {
		#if neko
			return new String(host_to_string(ip));
		#else
			return name;
		#end
	}

	public function reverse() {
		#if neko
			return new String(host_reverse(ip));
		#else
			return name;
		#end
	}

	public static function localhost() : String {
		#if neko
			return new String(host_local());
		#else
			return "127.0.0.1";
		#end
	}

#if neko
	static function __init__() {
		neko.Lib.load("std","socket_init",0)();
	}

	private static var host_resolve = neko.Lib.load("std","host_resolve",1);
	private static var host_reverse = neko.Lib.load("std","host_reverse",1);
	private static var host_to_string = neko.Lib.load("std","host_to_string",1);
	private static var host_local = neko.Lib.load("std","host_local",0);
#end

}
