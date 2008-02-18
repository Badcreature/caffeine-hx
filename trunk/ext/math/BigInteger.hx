/*
 * Copyright (c) 2008, The Caffeine-hx project contributors
 * Original author : Russell Weir
 * Contributors: Mark Winterhalder
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
 * Derived from javascript implementation Copyright (c) 2005 Tom Wu
 *
 */
package math;

import math.reduction.ModularReduction;
import math.reduction.Barrett;
import math.reduction.Classic;
import math.reduction.Montgomery;

class BigInteger {
	public static var MAX_RADIX : Int = 36;
	public static var MIN_RADIX : Int = 2;

	//dbits (DB) TODO: assumed to be 16 < DB < 32
	public static var DB : Int 		= 30;
	public static var DM : Int 		= ((1<<30)-1);
	public static var DV : Int 		= (1<<30);

	public static var BI_FP : Int 	= 52;
	public static var FV : Float 	= Math.pow(2,BI_FP);
	public static var F1 : Int 		= BI_FP-30;
	public static var F2 : Int		= 2*30-BI_FP;

	public static var ZERO(getZERO,null)	: BigInteger;
	public static var ONE(getONE, null)		: BigInteger;

	// Digit conversions
	static var BI_RM : String ;
	static var BI_RC : Array<Int>;

	public static var lowprimes : Array<Int>;
	static var lplim : Int;

	static function __init__() {
		BI_RM = "0123456789abcdefghijklmnopqrstuvwxyz";
		var rr : Int = "0".charCodeAt(0);
		for(vv in 0...10)
			BI_RC[rr++] = vv;
		rr = "a".charCodeAt(0);
		for(vv in 10...37)
			BI_RC[rr++] = vv;
		rr = "A".charCodeAt(0);
		for(vv in 10...37)
			BI_RC[rr++] = vv;

		lowprimes = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,181,191,193,197,199,211,223,227,229,233,239,241,251,257,263,269,271,277,281,283,293,307,311,313,317,331,337,347,349,353,359,367,373,379,383,389,397,401,409,419,421,431,433,439,443,449,457,461,463,467,479,487,491,499,503,509];
		lplim = Std.int((1<<26)/lowprimes[lowprimes.length-1]);

#if js

		// Bits per digit
		var dbits; This is th DB static

		// JavaScript engine analysis
		var canary = 0xdeadbeefcafe;
		var j_lm = ((canary&0xffffff)==0xefcafe);

		if(j_lm && (navigator.appName == "Microsoft Internet Explorer")) {
			BigInteger.prototype.am = am2;
			dbits = 30;
		}
		else if(j_lm && (navigator.appName != "Netscape")) {
			BigInteger.prototype.am = am1;
			dbits = 26;
		}
		else { // Mozilla/Netscape seems to prefer
			BigInteger.prototype.am = am3;
			dbits = 28;
		}

		DB = dbits;
		F1 = BI_FP - dbits;
		F2 = 2 * dbits - BI_FP;
#end

	}

	public static function getZERO() : BigInteger {
		return nbv(0);
	}

	public static function getONE() : BigInteger {
		return nbv(1);
	}

	/**
		Create a new big integer from the int value i
		TODO: function name
	**/
	public static function nbv(i : Int) {
		var r = nbi();
		r.fromInt(i);
		return r;
	}

	/**
		// return new, unset BigInteger
		TODO: function name
	**/
	public static function nbi() {
		return new BigInteger(null);
	}

	public var t(default,null) : Int; // number of chunks.
	public var s(default,null) : Int; // sign
	public var chunks(default,null) : Array<Int>; // chunks

	public function new(?int : Int, ?str : String, ?radix : Int) {
		chunks = new Array<Int>();
		if(int != null)	this.fromInt(int);
		else if( str != null && radix == null) this.fromString(str,256);
	}

	/**
		Absolute value
	**/
	public function abs() {
		return (this.s<0)?this.negate():this;
	}

	/**
		This is so Montgomery Reduction can pad. Used to be (in Montgomery):
		while(x.t <= this.mt2)	// pad x so am has enough room later
			x.chunks[x.t++] = 0;
	**/
	public function padTo ( n : Int ) : Void {
		while( t < n )	chunks[ t++ ] = 0;
	}

	/**
		Modulus division bn % bn
	**/
	public function mod(a) {
		var r = nbi();
		this.abs().divRemTo(a,null,r);
		if(this.s < 0 && r.compareTo(BigInteger.ZERO) > 0) a.subTo(r,r);
		return r;
	}

	/**
		this^e % m, 0 <= e < 2^32
	**/
	public function modPowInt(e,m : BigInteger) {
		var z : ModularReduction;
		if(e < 256 || m.isEven()) z = new Classic(m);
		else z = new Montgomery(m);
		return this.exp(e,z);
	}

	/**
		return the number of bits in "this"
	**/
	public function bitLength() {
		if(t <= 0) return 0;
		return DB*(t-1)+nbits(chunks[t-1]^(this.s&DM));
	}

	/**
		return + if this > a, - if this < a, 0 if equal
	**/
	public function compareTo(a) {
		var r = this.s-a.s;
		if(r != 0) return r;
		var i = t;
		r = i-a.t;
		if(r != 0) return r;
		while(--i >= 0) if((r=chunks[i]-a.chunks[i]) != 0) return r;
		return 0;
	}

	/**
		-this
	**/
	public function negate() {
		var r = nbi();
		BigInteger.ZERO.subTo(this,r);
		return r;
	}


	/**
		return string representation in given radix
		TODO: rename function. Conflict with toString()
	**/
	public function toString(b) {
		if(this.s < 0) return "-"+this.negate().toString(b);
		var k;
		if(b == 16) k = 4;
		else if(b == 8) k = 3;
		else if(b == 2) k = 1;
		else if(b == 32) k = 5;
		else if(b == 4) k = 2;
		else return toRadix(b);
		var km = (1<<k)-1, d, m = false, r = "", i = t;
		var p = DB-(i*DB)%k;
		if(i-- > 0) {
			if(p < DB && (d = chunks[i]>>p) > 0) { m = true; r = int2char(d); }
			while(i >= 0) {
			if(p < k) {
				d = (chunks[i]&((1<<p)-1))<<(k-p);
				d |= chunks[--i]>>(p+=DB-k);
			}
			else {
				d = (chunks[i]>>(p-=k))&km;
				if(p <= 0) { p += DB; --i; }
			}
			if(d > 0) m = true;
			if(m) r += int2char(d);
			}
		}
		return m?r:"0";
	}


	//////////////////////////////////////////////////////////////
	//					Private methods							//
	//////////////////////////////////////////////////////////////

	// (protected) copy this to r
	public function copyTo(r : BigInteger) {
		r.chunks = chunks.copy();
		r.t = t;
		r.s = this.s;
	}

	// (protected) set from integer value x, -DV <= x < DV
	function fromInt(x : Int) {
		t = 1;
		this.s = (x<0)?-1:0;
		if(x > 0) chunks[0] = x;
		else if(x < -1) chunks[0] = x+DV;
		else t = 0;
	}

	// (protected) set from string and radix
	function fromString(s : String, b : Int) {
		var k;
		if(b == 16) k = 4;
		else if(b == 8) k = 3;
		else if(b == 256) k = 8; // byte array
		else if(b == 2) k = 1;
		else if(b == 32) k = 5;
		else if(b == 4) k = 2;
		else { this.fromRadix(s,b); return; }
		t = 0;
		this.s = 0;
		var i = s.length, mi = false, sh = 0;
		while(--i >= 0) {
			var x = (k==8)?s.charCodeAt( i )&0xff:intAt(s,i);
			if(x < 0) {
				if(s.charAt(i) == "-") mi = true;
				continue;
			}
			mi = false;
			if(sh == 0)
				chunks[t++] = x;
			else if(sh+k > DB) {
				chunks[t-1] |= (x&((1<<(DB-sh))-1))<<sh;
				chunks[t++] = (x>>(DB-sh));
			}
			else
				chunks[t-1] |= x<<sh;
			sh += k;
			if(sh >= DB) sh -= DB;
		}
		if(k == 8 && (s.charCodeAt( 0 )&0x80) != 0) {
			this.s = -1;
			if(sh > 0) chunks[t-1] |= ((1<<(DB-sh))-1)<<sh;
		}
		this.clamp();
		if(mi) BigInteger.ZERO.subTo(this,this);
	}

	// (protected) convert from radix string
	function fromRadix(s : String, b : Int) {
	  this.fromInt(0);
	  if(b == null) b = 10;
	  var cs = Math.floor(0.6931471805599453*DB/Math.log(b));
	  var d = Std.int( Math.pow(b,cs) ), mi = false, j = 0, w = 0;
	  for(i in 0...s.length) {
	    var x = intAt(s,i);
	    if(x < 0) {
	      if(s.charAt(i) == "-" && this.s == 0) mi = true;
	      continue;
	    }
	    w = b*w+x;
	    if(++j >= cs) {
		  dMultiply( d );
	      this.dAddOffset(w,0);
	      j = 0;
	      w = 0;
	    }
	  }
	  if(j > 0) {
	    dMultiply(Std.int( Math.pow(b,j) ));
	    this.dAddOffset(w,0);
	  }
	  if(mi) BigInteger.ZERO.subTo(this,this);
	}

	// (protected) convert to radix string
	public function toRadix(b : Int) : String {
		if(b == null) b = 10;
		if(s == 0 || b < 2 || b > 36) return "0";
		var cs = Math.floor(0.6931471805599453*DB/Math.log(b)); // Math.LN2
		var a = Std.int(Math.pow(b,cs));
		var d = nbv(a);
		var y = nbi();
		var z = nbi();
		var r = "";
		divRemTo(d,y,z);
		while(y.s > 0) {
			r = I32.baseEncode31(a + z.intValue(), b).substr(1) + r;
			y.divRemTo(d,y,z);
		}
		return I32.baseEncode31(z.intValue(), b) + r;
	}

/*
	// (protected) alternate constructor
	function fromNumber(a,b,c) {
		if("number" == typeof b) {
			// new BigInteger(int,int,RNG)
			if(a < 2) this.fromInt(1);
			else {
				this.fromNumber(a,c);
				if(!testBit(a-1))	// force MSB set
					this.bitwiseTo(BigInteger.ONE.shiftLeft(a-1),op_or,this);
				if(this.isEven()) this.dAddOffset(1,0); // force odd
				while(!this.isProbablePrime(b)) {
					this.dAddOffset(2,0);
					if(this.bitLength() > a) 	this.subTo(BigInteger.ONE.shiftLeft(a-1),this);
				}
			}
		}
		else {
			// new BigInteger(int,RNG)
			var x = new Array(), t = a&7;
			x.length = (a>>3)+1;
			b.nextBytes(x);
			if(t > 0) x[0] &= ((1<<t)-1); else x[0] = 0;
			this.fromString(x,256);
		}
	}
*/

	// (public) convert to bigendian byte array
	function toByteArray() : Array<Int> {
		var i = t;
		var r = new Array();
		r[0] = this.s;
		var p = DB-(i*DB)%8, d, k = 0;
		if(i-- > 0) {
			if(p < DB && (d = chunks[i]>>p) != (this.s&DM)>>p)
			r[k++] = d|(this.s<<(DB-p));
			while(i >= 0) {
				if(p < 8) {
					d = (chunks[i]&((1<<p)-1))<<(8-p);
					d |= chunks[--i]>>(p+=DB-8);
				}
				else {
					d = (chunks[i]>>(p-=8))&0xff;
					if(p <= 0) { p += DB; --i; }
				}
				if((d&0x80) != 0) d |= -256;
				if(k == 0 && (this.s&0x80) != (d&0x80)) ++k;
				if(k > 0 || d != this.s) r[k++] = d;
			}
		}
		return r;
	}

	// (protected) r = this op a (bitwise)
	function bitwiseTo(a : BigInteger, op:Int->Int->Int, r:BigInteger) {
		var f : Int;
		var m : Int = Std.int(Math.min(a.t,t));
		for(i in 0...m) r.chunks[i] = op(chunks[i],a.chunks[i]);
		if(a.t < t) {
			f = a.s & DM;
			for(i in m...t) r.chunks[i] = op(chunks[i],f);
			r.t = t;
		}
		else {
			f = this.s&DM;
			for(i in m...a.t) r.chunks[i] = op(f,a.chunks[i]);
			r.t = a.t;
		}
		r.s = op(this.s,a.s);
		r.clamp();
	}

	// (public) this & a
	public function op_and(x:Int, y:Int) { return x&y; }
	public function and(a) { var r = nbi(); this.bitwiseTo(a,op_and,r); return r; }

	// (public) this | a
	public function op_or(x:Int, y:Int) { return x|y; }
	public function or(a) { var r = nbi(); this.bitwiseTo(a,op_or,r); return r; }

	// (public) this ^ a
	public function op_xor(x:Int, y:Int) { return x^y; }
	public function xor(a) { var r = nbi(); this.bitwiseTo(a,op_xor,r); return r; }

	// (public) this & ~a
	public function op_andnot(x:Int, y:Int) { return x&~y; }
	public function andNot(a) { var r = nbi(); this.bitwiseTo(a,op_andnot,r); return r; }

	/**
		(public) this += n << w words, this >= 0
	**/
	public function dAddOffset(n,w) {
	  while(t <= w) chunks[t++] = 0;
	  chunks[w] += n;
	  while(chunks[w] >= DV) {
	    chunks[w] -= DV;
	    if(++w >= t) chunks[t++] = 0;
	    ++chunks[w];
	  }
	}

	/**
		(protected) this *= n, this >= 0, 1 < n < DV
	**/
	function dMultiply ( n : Int ) {
		chunks[ t ] = am(0,n-1,this,0,0,t);
		t++;
		clamp();
	}

	function intValue() : Int {
		if(s < 0) {
			if(t == 1) return chunks[0]-DV;
			else if(t == 0) return -1;
		}
		else if(t == 1) return chunks[0];
		else if(t == 0) return 0;
		// assumes 16 < DB < 32
		return ((chunks[1]&((1<<(32-DB))-1))<<DB)|chunks[0];
	}

	// (protected) clamp off excess high words
	public function clamp() {
		var c = this.s&DM;
		while(t > 0 && chunks[t-1] == c) --t;
	}

	// (protected) r = this << n*DB
	public function dlShiftTo(n : Int, r : BigInteger) {
		var i;
//		for(i = t-1; i >= 0; --i) r.chunks[i+n] = chunks[i];
//		for(i = n-1; i >= 0; --i) r.chunks[i] = 0;
		var padding = new Array<Int>();
		while( n-- > 0 ) 	padding.push( 0 );
		r.chunks = padding.concat( chunks.copy() );
		r.t = t+n;
		r.s = this.s;
	}

	// (protected) r = this >> n*DB
	public function drShiftTo(n : Int, r : BigInteger) {
//		for(var i = n; i < t; ++i) r.chunks[i-n] = chunks[i];
		r.chunks = chunks.slice( n );
		r.t = Std.int( Math.max(t-n,0) );
		r.s = this.s;
	}

	// (protected) r = this << n
	public function lShiftTo(n : Int, r : BigInteger) {
		var bs = n%DB;
		var cbs = DB-bs;
		var bm = (1<<cbs)-1;
		var ds = Math.floor(n/DB), c = (this.s<<bs)&DM, i;
//		for(i = t-1; i >= 0; --i) {
		var i = t-1;
		while( i-- > 0 ) {
			r.chunks[i+ds+1] = (chunks[i]>>cbs)|c;
			c = (chunks[i]&bm)<<bs;
		}
//		for(i = ds-1; i >= 0; --i) r.chunks[i] = 0;
		i = ds - 1;
		while( i-- > 0 ) r.chunks[i] = 0;
		r.chunks[ds] = c;
		r.t = t+ds+1;
		r.s = this.s;
		r.clamp();
	}

	// (protected) r = this >> n
	public function rShiftTo(n : Int, r : BigInteger) {
		r.s = this.s;
		var ds = Math.floor(n/DB);
		if(ds >= t) { r.t = 0; return; }
		var bs = n%DB;
		var cbs = DB-bs;
		var bm = (1<<bs)-1;
		r.chunks[0] = chunks[ds]>>bs;
//		for(var i = ds+1; i < t; ++i) {
		for( i in (ds + 1)...t ) {
			r.chunks[i-ds-1] |= (chunks[i]&bm)<<cbs;
			r.chunks[i-ds] = chunks[i]>>bs;
		}
		if(bs > 0) r.chunks[t-ds-1] |= (this.s&bm)<<cbs;
		r.t = t-ds;
		r.clamp();
	}

	/**
		(public) ~this
	**/
	function not() {
		var r = nbi();
		for(i in 0...t) r.chunks[i] = DM&~chunks[i];
		r.t = t;
		r.s = ~this.s;
		return r;
	}

	/**
		(public) this << n
	**/
	function shiftLeft(n) {
	var r = nbi();
	if(n < 0) this.rShiftTo(-n,r); else this.lShiftTo(n,r);
	return r;
	}

	/**
		(public) this >> n
	**/
	function shiftRight(n) {
		var r = nbi();
		if(n < 0) this.lShiftTo(-n,r); else this.rShiftTo(n,r);
		return r;
	}

	// (protected) r = this - a
	public function subTo(a : BigInteger, r : BigInteger) {
		var i = 0, c = 0, m = Math.min(a.t,t);
		while(i < m) {
			c += chunks[i]-a.chunks[i];
			r.chunks[i++] = c&DM;
			c >>= DB;
		}
		if(a.t < t) {
			c -= a.s;
			while(i < t) {
				c += chunks[i];
				r.chunks[i++] = c&DM;
				c >>= DB;
			}
			c += this.s;
		}
		else {
			c += this.s;
			while(i < a.t) {
				c -= a.chunks[i];
				r.chunks[i++] = c&DM;
				c >>= DB;
			}
			c -= a.s;
		}
		r.s = (c<0)?-1:0;
		if(c < -1) r.chunks[i++] = DV+c;
		else if(c > 0) r.chunks[i++] = c;
		r.t = i;
		r.clamp();
	}

	// (protected) r = this * a, r != this,a (HAC 14.12)
	// "this" should be the larger one if appropriate.
	public function multiplyTo(a : BigInteger, r : BigInteger) {
		var x = this.abs(), y = a.abs();
		var i = x.t;
		r.t = i+y.t;
		while(--i >= 0) r.chunks[i] = 0;
//		for(i = 0; i < y.t; ++i) r.chunks[i+x.t] = x.am(0,y[i],r,i,0,x.t);
		for( i in 0...y.t ) r.chunks[i+x.t] = x.am(0,y.chunks[i],r,i,0,x.t);
		r.s = 0;
		r.clamp();
		if(this.s != a.s) BigInteger.ZERO.subTo(r,r);
	}

	// (protected) r = this^2, r != this (HAC 14.16)
	public function squareTo(r : BigInteger) {
		var x = this.abs();
		var i = r.t = 2*x.t;
		while(--i >= 0) r.chunks[i] = 0;
//		for(i = 0; i < x.t-1; ++i) {
		for(i in 0...x.t-1) {
			var c = x.am(i,x.chunks[i],r,2*i,0,1);
			if((r.chunks[i+x.t]+=x.am(i+1,2*x.chunks[i],r,2*i+1,c,x.t-i-1)) >= DV) {
			r.chunks[i+x.t] -= DV;
			r.chunks[i+x.t+1] = 1;
			}
		}
		if(r.t > 0) r.chunks[r.t-1] += x.am(i,x.chunks[i],r,2*i,0,1);
		r.s = 0;
		r.clamp();
	}

	/**
		(protected) divide this by m, quotient and remainder to q, r (HAC 14.20)
		r != q, this != m.  q or r may be null.
	**/
	public function divRemTo(m : BigInteger, q : BigInteger ,?r : BigInteger) {
		var pm = m.abs();
		if(pm.t <= 0) return;
		var pt = this.abs();
		if(pt.t < pm.t) {
			if(q != null) q.fromInt(0);
			if(r != null) this.copyTo(r);
			return;
		}
		if(r == null) r = nbi();
		var y = nbi(), ts = this.s, ms = m.s;
		var nsh = DB-nbits(pm.chunks[pm.t-1]);	// normalize modulus
		if(nsh > 0) { pm.lShiftTo(nsh,y); pt.lShiftTo(nsh,r); }
		else { pm.copyTo(y); pt.copyTo(r); }
		var ys = y.t;
		var y0 = y.chunks[ys-1];
		if(y0 == 0) return;
		var yt = y0*(1<<F1)+((ys>1)?y.chunks[ys-2]>>F2:0);
		var d1 = FV/yt, d2 = (1<<F1)/yt, e = 1<<F2;
		var i = r.t, j = i-ys, t = (q==null)?nbi():q;
		y.dlShiftTo(j,t);
		if(r.compareTo(t) >= 0) {
			r.chunks[r.t++] = 1;
			r.subTo(t,r);
		}
		BigInteger.ONE.dlShiftTo(ys,t);
		t.subTo(y,y);	// "negative" y so we can replace sub with am later
		while(y.t < ys) y.chunks[y.t++] = 0;
		while(--j >= 0) {
			// Estimate quotient digit
			var qd = (r.chunks[--i]==y0)?DM:Math.floor(r.chunks[i]*d1+(r.chunks[i-1]+e)*d2);
			if((r.chunks[i]+=y.am(0,qd,r,j,0,ys)) < qd) {	// Try it out
			y.dlShiftTo(j,t);
			r.subTo(t,r);
			while(r.chunks[i] < --qd) r.subTo(t,r);
			}
		}
		if(q != null) {
			r.drShiftTo(ys,q);
			if(ts != ms) BigInteger.ZERO.subTo(q,q);
		}
		r.t = ys;
		r.clamp();
		if(nsh > 0) r.rShiftTo(nsh,r);	// Denormalize remainder
		if(ts < 0) BigInteger.ZERO.subTo(r,r);
	}

	// (protected) return "-1/this % 2^DB"; useful for Mont. reduction
	// justification:
	//         xy == 1 (mod m)
	//         xy =  1+km
	//   xy(2-xy) = (1+km)(1-km)
	// x[y(2-xy)] = 1-k^2m^2
	// x[y(2-xy)] == 1 (mod m^2)
	// if y is 1/x mod m, then y(2-xy) is 1/x mod m^2
	// should reduce x and y(2-xy) by m^2 at each step to keep size bounded.
	// JS multiply "overflows" differently from C/C++, so care is needed here.
	public function invDigit() {
		if(t < 1) return 0;
		var x = chunks[0];
		if((x&1) == 0) return 0;
		var y = x&3;		// y == 1/x mod 2^2
		y = (y*(2-(x&0xf)*y))&0xf;	// y == 1/x mod 2^4
		y = (y*(2-(x&0xff)*y))&0xff;	// y == 1/x mod 2^8
		y = (y*(2-(((x&0xffff)*y)&0xffff)))&0xffff;	// y == 1/x mod 2^16
		// last step - calculate inverse mod DV directly;
		// assumes 16 < DB <= 32 and assumes ability to handle 48-bit ints
		y = (y*(2-x*y%DV))%DV;		// y == 1/x mod 2^dbits
		// we really want the negative inverse, and -DV < y < DV
		return (y>0)?DV-y:-y;
	}

	// (protected) true if this is even
	public function isEven() {
		return ((t>0)?(chunks[0]&1):this.s) == 0;
	}

	/**
		Clone a BigInteger
	**/
	public function clone() {
		var r = nbi();
		copyTo(r);
		return r;
	}


	/**
		(public) return value as byte
	**/
	function byteValue() { return (t==0)?s:(chunks[0]<<24)>>24; }

	/**
		(public) return value as short (assumes DB>=16)
	**/
	public function shortValue() {
		return (t==0)?s:(chunks[0]<<16)>>16;
	}

	/**
		(protected) return x s.t. r^x < DV
	**/
	function chunkSize(r) {
		return Math.floor(0.6931471805599453*DB/Math.log(r));
	}

	/**
		(public) 0 if this == 0, 1 if this > 0
	**/
	public function signum() {
		if(s < 0) return -1;
		else if(t <= 0 || (t == 1 && chunks[0] <= 0)) return 0;
		else return 1;
	}

	// (protected) this^e, e < 2^32, doing sqr and mul with "r" (HAC 14.79)
	function exp(e,z : ModularReduction) {
		if(e > 0xffffffff || e < 1) return BigInteger.ONE;
		var r = nbi(), r2 = nbi(), g = z.convert(this), i = nbits(e)-1;
		g.copyTo(r);
		while(--i >= 0) {
			z.sqrTo(r,r2);
			if((e&(1<<i)) > 0) z.mulTo(r2,g,r);
			else { var t = r; r = r2; r2 = t; }
		}
		return z.revert(r);
	}

	// returns bit length of the integer x
	function nbits( x : Int ) {
		var r : Int = 1;
		var t : Int;
		if((t=x>>>16) != 0) { x = t; r += 16; }
		if((t=x>>8) != 0) { x = t; r += 8; }
		if((t=x>>4) != 0) { x = t; r += 4; }
		if((t=x>>2) != 0) { x = t; r += 2; }
		if((t=x>>1) != 0) { x = t; r += 1; }
		return r;
	}

	function intAt(s,i) {
		var c = BI_RC[s.charCodeAt(i)];
		return (c==null)?-1:c;
	}

	function int2char(n: Int) : String {
		return BI_RM.charAt(n);
	}

	/**
		return index of lowest 1-bit in x, x < 2^31
	**/
	public function lbit(x : Int) {
		if(x == 0) return -1;
		var r = 0;
		if((x&0xffff) == 0) { x >>= 16; r += 16; }
		if((x&0xff) == 0) { x >>= 8; r += 8; }
		if((x&0xf) == 0) { x >>= 4; r += 4; }
		if((x&3) == 0) { x >>= 2; r += 2; }
		if((x&1) == 0) ++r;
		return r;
	}

	/**
		(public) returns index of lowest 1-bit (or -1 if none)
	**/
	public function getLowestSetBit() {
		for(i in 0...t)
			if(chunks[i] != 0) return i*DB+lbit(chunks[i]);
		if(this.s < 0) return t*DB;
		return -1;
	}

	/**
		return number of 1 bits in x
	**/
	public function cbit(x) {
		var r = 0;
		while(x != 0) { x &= x-1; ++r; }
		return r;
	}

	/**
		(public) return number of set bits
	**/
	function bitCount() {
		var r = 0, x = this.s&DM;
		for(i in 0...t) r += cbit(chunks[i]^x);
		return r;
	}

	/**
		(public) true iff nth bit is set
	**/
	function testBit(n) {
		var j = Math.floor(n/DB);
		if(j >= t) return(this.s!=0);
		return((chunks[j]&(1<<(n%DB)))!=0);
	}

	/**
		(protected) this op (1<<n)
	**/
	public function changeBit(n,op) {
		var r = BigInteger.ONE.shiftLeft(n);
		this.bitwiseTo(r,op,r);
		return r;
	}

	/**
		(public) this | (1<<n)
	**/
	function setBit(n) { return this.changeBit(n,op_or); }

	/**
		(public) this & ~(1<<n)
	**/
	function clearBit(n) { return this.changeBit(n,op_andnot); }

	/**
		(public) this ^ (1<<n)
	**/
	function flipBit(n) { return this.changeBit(n,op_xor); }

	// (protected) r = this + a
	function addTo(a:BigInteger,r:BigInteger) : Void {
		var i :Int = 0, c:Int = 0, m:Int = Std.int(Math.min(a.t,t));
		while(i < m) {
			c += chunks[i]+a.chunks[i];
			r.chunks[i++] = c&DM;
			c >>= DB;
		}
		if(a.t < t) {
			c += a.s;
			while(i < t) {
				c += chunks[i];
				r.chunks[i++] = c&DM;
				c >>= DB;
			}
			c += this.s;
		}
		else {
			c += this.s;
			while(i < a.t) {
				c += a.chunks[i];
				r.chunks[i++] = c&DM;
				c >>= DB;
			}
			c += a.s;
		}
		r.s = (c<0)?-1:0;
		if(c > 0) r.chunks[i++] = c;
		else if(c < -1) r.chunks[i++] = DV+c;
		r.t = i;
		r.clamp();
	}

	/**
		(public) this + a
	**/
	public function add(a) : BigInteger
	{ var r = nbi(); this.addTo(a,r); return r; }

	/**
		(public) this - a
	**/
	public function subtract(a) : BigInteger
	{ var r = nbi(); this.subTo(a,r); return r; }

	/**
		(public) this * a
	**/
	public function multiply(a) : BigInteger
	{ var r = nbi(); this.multiplyTo(a,r); return r; }

	/**
		(public) this / a
	**/
	public function divide(a) : BigInteger
	{ var r = nbi(); divRemTo(a,r,null); return r; }

	/**
		(public) this % a
	**/
	public function remainder(a) : BigInteger
	{ var r = nbi(); divRemTo(a,null,r); return r; }

	/**
		(public) [this/a,this%a]
	**/
	public function divideAndRemainder(a) : Array<BigInteger> {
		var q = nbi();
		var r = nbi();
		divRemTo(a,q,r);
		return [q,r];
	}

	/**
		(public) this^e
	**/
	public function pow(e : Int) : BigInteger {
		return this.exp(e,new math.reduction.Null());
	}

	/**
		(protected) r = lower n words of "this * a", a.t <= n
		"this" should be the larger one if appropriate.
	**/
	public function multiplyLowerTo(a:BigInteger,n : Int,r:BigInteger) : Void {
		var i : Int = Std.int(Math.min(this.t+a.t,n));
		r.s = 0; // assumes a,this >= 0
		r.t = i;
		while(i > 0) r.chunks[--i] = 0;
		var j : Int = r.t - this.t;
		for(i in 0...j)
			r.chunks[i+this.t] = this.am(0,a.chunks[i],r,i,0,this.t);
		j = Std.int(Math.min(a.t,n));
		for(i in 0...j)
			this.am(0,a.chunks[i],r,i,0,n-i);
		r.clamp();
	}

	/**
		(protected) r = "this * a" without lower n words, n > 0
		"this" should be the larger one if appropriate.
	**/
	public function multiplyUpperTo(a:BigInteger,n:Int,r:BigInteger) : Void {
		--n;
		var i : Int = r.t = t+a.t-n;
		r.s = 0; // assumes a,this >= 0
		while(--i >= 0)
			r.chunks[i] = 0;
		i = Std.int(Math.max(n-t,0));
		for(x in i...a.t)
			r.chunks[t+x-n] = this.am(n-x,a.chunks[x],r,0,0,t+x-n);
		r.clamp();
		r.drShiftTo(1,r);
	}

	// (public) this^e % m (HAC 14.85)
	public function modPow(e : BigInteger, m:BigInteger) : BigInteger {
		var i = e.bitLength();
		var k : Int;
		var r : BigInteger = nbv(1);
		var z : ModularReduction;
		if(i <= 0) return r;
		else if(i < 18) k = 1;
		else if(i < 48) k = 3;
		else if(i < 144) k = 4;
		else if(i < 768) k = 5;
		else k = 6;
		if(i < 8)
			z = new Classic(m);
		else if(m.isEven())
			z = new Barrett(m);
		else
			z = new Montgomery(m);

		// precomputation
		var g : Array<BigInteger> = new Array();
		var n : Int = 3;
		var k1 : Int = k-1;
		var km : Int = (1<<k)-1;
		g[1] = z.convert(this);
		if(k > 1) {
			var g2 : BigInteger = nbi();
			z.sqrTo(g[1],g2);
			while(n <= km) {
				g[n] = nbi();
				z.mulTo(g2,g[n-2],g[n]);
				n += 2;
			}
		}

		var j : Int = e.t-1;
		var w : Int;
		var is1 : Bool = true;
		var r2 : BigInteger = nbi();
		var t : BigInteger;
		i = nbits(e.chunks[j])-1;
		while(j >= 0) {
			if(i >= k1) w = (e.chunks[j]>>(i-k1))&km;
			else {
				w = (e.chunks[j]&((1<<(i+1))-1))<<(k1-i);
				if(j > 0) w |= e.chunks[j-1]>>(DB+i-k1);
			}

			n = k;
			while((w&1) == 0) { w >>= 1; --n; }
			if((i -= n) < 0) { i += DB; --j; }
			if(is1) {	// ret == 1, don't bother squaring or multiplying it
				g[w].copyTo(r);
				is1 = false;
			}
			else {
				while(n > 1) { z.sqrTo(r,r2); z.sqrTo(r2,r); n -= 2; }
				if(n > 0) z.sqrTo(r,r2);
				else { t = r; r = r2; r2 = t; }
				z.mulTo(r2,g[w],r);
			}

			while(j >= 0 && (e.chunks[j]&(1<<i)) == 0) {
				z.sqrTo(r,r2); t = r; r = r2; r2 = t;
				if(--i < 0) { i = DB-1; --j; }
			}
		}
		return z.revert(r);
	}


	// (public) gcd(this,a) (HAC 14.54)
	public function gcd(a:BigInteger) : BigInteger {
		var x = (this.s<0)?this.negate():this.clone();
		var y = (a.s<0)?a.negate():a.clone();
		if(x.compareTo(y) < 0) { var t = x; x = y; y = t; }
		var i = x.getLowestSetBit(), g = y.getLowestSetBit();
		if(g < 0) return x;
		if(i < g) g = i;
		if(g > 0) {
			x.rShiftTo(g,x);
			y.rShiftTo(g,y);
		}
		while(x.signum() > 0) {
			if((i = x.getLowestSetBit()) > 0) x.rShiftTo(i,x);
			if((i = y.getLowestSetBit()) > 0) y.rShiftTo(i,y);
			if(x.compareTo(y) >= 0) {
				x.subTo(y,x);
				x.rShiftTo(1,x);
			}
			else {
				y.subTo(x,y);
				y.rShiftTo(1,y);
			}
		}
		if(g > 0) y.lShiftTo(g,y);
		return y;
	}


	// (protected) this % n, n < 2^26
	public function modInt(n : Int) {
		if(n <= 0) return 0;
		var d = DV%n, r = (this.s<0)?n-1:0;
		if(this.t > 0)
			if(d == 0) r = chunks[0]%n;
			else {
				var i = this.t-1;
				while( --i >= 0)
					r = (d*r+chunks[i])%n;
			}
		return r;
	}

/*
// (public) 1/this % m (HAC 14.61)
public function modInverse(m) {
  var ac = m.isEven();
  if((this.isEven() && ac) || m.signum() == 0) return BigInteger.ZERO;
  var u = m.clone(), v = this.clone();
  var a = nbv(1), b = nbv(0), c = nbv(0), d = nbv(1);
  while(u.signum() != 0) {
    while(u.isEven()) {
      u.rShiftTo(1,u);
      if(ac) {
        if(!a.isEven() || !b.isEven()) { a.addTo(this,a); b.subTo(m,b); }
        a.rShiftTo(1,a);
      }
      else if(!b.isEven()) b.subTo(m,b);
      b.rShiftTo(1,b);
    }
    while(v.isEven()) {
      v.rShiftTo(1,v);
      if(ac) {
        if(!c.isEven() || !d.isEven()) { c.addTo(this,c); d.subTo(m,d); }
        c.rShiftTo(1,c);
      }
      else if(!d.isEven()) d.subTo(m,d);
      d.rShiftTo(1,d);
    }
    if(u.compareTo(v) >= 0) {
      u.subTo(v,u);
      if(ac) a.subTo(c,a);
      b.subTo(d,b);
    }
    else {
      v.subTo(u,v);
      if(ac) c.subTo(a,c);
      d.subTo(b,d);
    }
  }
  if(v.compareTo(BigInteger.ONE) != 0) return BigInteger.ZERO;
  if(d.compareTo(m) >= 0) return d.subtract(m);
  if(d.signum() < 0) d.addTo(m,d); else return d;
  if(d.signum() < 0) return d.add(m); else return d;
}
*/

	// (public) test primality with certainty >= 1-.5^t
	public function isProbablePrime(t) {
		var i;
		var x = this.abs();
		if(x.t == 1 && x.chunks[0] <= lowprimes[lowprimes.length-1]) {
			for(i in 0...lowprimes.length)
			if(x.chunks[0] == lowprimes[i]) return true;
			return false;
		}
		if(x.isEven()) return false;
		i = 1;
		while(i < lowprimes.length) {
			var m = lowprimes[i];
			var j = i+1;
			while(j < lowprimes.length && m < lplim) m *= lowprimes[j++];
			m = x.modInt(m);
			while(i < j) if(m%lowprimes[i++] == 0) return false;
		}
		return x.millerRabin(t);
	}

	// (protected) true if probably prime (HAC 4.24, Miller-Rabin)
	public function millerRabin(t:Int) {
		var n1 = this.subtract(BigInteger.ONE);
		var k = n1.getLowestSetBit();
		if(k <= 0) return false;
		var r = n1.shiftRight(k);
		t = (t+1)>>1;
		if(t > lowprimes.length) t = lowprimes.length;
		var a = nbi();
		for(i in 0...t) {
			a.fromInt(lowprimes[i]);
			var y = a.modPow(r,this);
			if(y.compareTo(BigInteger.ONE) != 0 && y.compareTo(n1) != 0) {
				var j = 1;
				while(j++ < k && y.compareTo(n1) != 0) {
					y = y.modPowInt(2,this);
					if(y.compareTo(BigInteger.ONE) == 0) return false;
				}
				if(y.compareTo(n1) != 0) return false;
			}
		}
		return true;
	}

#if !js
	public function am (i:Int,x:Int,w:BigInteger,j:Int,c:Int,n:Int) : Int {
		// same as JavaScript 'am2' variant
		var xl:Int = x&0x7fff;
		var xh:Int = x>>15;
		while(--n >= 0) {
			var l : Int = chunks[i]&0x7fff;
			var h : Int = chunks[i++]>>15;
			var m : Int = xh*l + h*xl;
			l = xl*l + ((m&0x7fff)<<15)+w.chunks[j]+(c&0x3fffffff);
			c = (l>>>30)+(m>>>15)+xh*h+(c>>>30);
			w.chunks[j++] = l&0x3fffffff;
		}
		return c;
	}

#else true
	public var am : Int->Int->BigInteger->Int->Int->Int->Int; // am function

	// am: Compute w_j += (x*this_i), propagate carries,
	// c is initial carry, returns final carry.
	// c < 3*dvalue, x < 2*dvalue, this_i < dvalue
	//
	// am2 avoids a big mult-and-extract completely.
	// Max digit bits should be <= 30 because we do bitwise ops
	// on values up to 2*hdvalue^2-hdvalue-1 (< 2^31)
	function am2(i:Int,x:Int,w:BigInteger,j:Int,c:Int,n:Int) : Int {
		var xl:Int = x&0x7fff;
		var xh:Int = x>>15;
		while(--n >= 0) {
			var l : Int = chunks[i]&0x7fff;
			var h : Int = chunks[i++]>>15;
			var m : Int = xh*l + h*xl;
			l = xl*l + ((m&0x7fff)<<15)+w.a.chunks[j]+(c&0x3fffffff);
			c = (l>>>30)+(m>>>15)+xh*h+(c>>>30);
			w.chunks[j++] = l&0x3fffffff;
		}
		return c;
	}

	// am1: use a single mult and divide to get the high bits,
	// max digit bits should be 26 because
	// max internal value = 2*dvalue^2-2*dvalue (< 2^53)
	function am1(i:Int,x:Int,w:BigInteger,j:Int,c:Int,n:Int) : Int {
		while(--n >= 0) {
			var v = x*chunks[i++]+w[j]+c;
			c = Math.floor(v/0x4000000);
			w[j++] = v&0x3ffffff;
		}
		return c;
	}

	// Alternately, set max digit bits to 28 since some
	// browsers slow down when dealing with 32-bit numbers.
	function am3(i:Int,x:Int,w:BigInteger,j:Int,c:Int,n:Int) : Int {
		var xl = x&0x3fff, xh = x>>14;
		while(--n >= 0) {
			var l = chunks[i]&0x3fff;
			var h = chunks[i++]>>14;
			var m = xh*l+h*xl;
			l = xl*l+((m&0x3fff)<<14)+w[j]+c;
			c = (l>>28)+(m>>14)+xh*h;
			w[j++] = l&0xfffffff;
		}
		return c;
	}
#end
}

