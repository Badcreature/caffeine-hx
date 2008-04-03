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
 */

/**
	The DateTools class contains some extra functionalities for [Date]
	manipulation. It's stored in a different class in order to prevent
	the standard [Date] of being bloated and thus increasing the size of
	each application using it.
**/
class DateTools {

	#if neko
	#else true
	private static function __jsflash_format_get( d : Date, e : String ) : String {
		switch( e ){
			case "%":
				return "%";
			case "C":
				return untyped StringTools.lpad(Std.string(Std.int(d.getFullYear()/100)),"0",2);
			case "d":
				return untyped StringTools.lpad(Std.string(d.getDate()),"0",2);
			case "D":
				return __jsflash_format(d,"%m/%d/%y");
			case "e":
				return untyped Std.string(d.getDate());
			case "H","k":
				return untyped StringTools.lpad(Std.string(d.getHours()),if( e == "H" ) "0" else " ",2);
			case "I","l":
				var hour = d.getHours()%12;
				return untyped StringTools.lpad(Std.string(hour == 0 ? 12 : hour),if( e == "I" ) "0" else " ",2);
			case "m":
				return untyped StringTools.lpad(Std.string(d.getMonth()+1),"0",2);
			case "M":
				return untyped StringTools.lpad(Std.string(d.getMinutes()),"0",2);
			case "n":
				return "\n";
			case "p":
				return untyped if( d.getHours() > 11 ) "PM"; else "AM";
			case "r":
				return __jsflash_format(d,"%I:%M:%S %p");
			case "R":
				return __jsflash_format(d,"%H:%M");
			case "s":
				return Std.string(Std.int(d.getTime()/1000));
			case "S":
				return untyped StringTools.lpad(Std.string(d.getSeconds()),"0",2);
			case "t":
				return "\t";
			case "T":
				return __jsflash_format(d,"%H:%M:%S");
			case "u":
				untyped{
					var t = d.getDay();
					return t == 0 ? "7" : Std.string(t);
				}
			case "w":
				return untyped Std.string(d.getDay());
			case "y":
				return untyped StringTools.lpad(Std.string(d.getFullYear()%100),"0",2);
			case "Y":
				return untyped Std.string(d.getFullYear());
			default:
				return throw "Date.format %"+e+"- not implemented yet.";
		}
	}

	private static function __jsflash_format( d : Date, f : String ) : String {
		var r = new StringBuf();
		var p = 0;
		while( true ){
			var np = f.indexOf("%", p);
			if( np < 0 )
				break;
			r.addSub(f,p,np-p);
			r.add( __jsflash_format_get(d, f.substr(np+1,1) ) );
			p = np+2;
		}
		r.addSub(f,p,f.length-p);
		return r.toString();
	}
	#end

	#if neko
		static var date_format = neko.Lib.load("std","date_format",2);
	#end

	/**
		Format the date [d] according to the format [f]. The format
		is compatible with the [strftime] standard format, except that there
		is no support in Flash and JS for day and months names (due to lack
		of proper internationalization API). On haXe/Neko/Windows, some
		formats are not supported.
	**/
	public static function format( d : Date, f : String ) : String {
		#if neko
			untyped return new String(date_format(d.__t, f.__s));
		#else js
			return __jsflash_format(d, f );
		#else flash
			return __jsflash_format(d, f );
		#else php
		/*
			var from = ['%%','%C','%d','%D','%e','%H','%I','%k','%l','%m','%M','%p','%r','%R','%s','%S','%T','%u','%w','%y','%Y'];
			var to   = [ '%', 'C', 'd', 'D', 'e', 'H', 'I', 'k', 'l', 'm', 'i', 'p', 'r', 'R', 's', 's', 'T', 'u', 'w', 'y', 'Y'];
			
//          "%% %C %d %D %e %H %I %k %l %m %M %p %r %R %s %S %T %u %w %y %Y"
//			'% 20 19 03/19/06 19 08 08  8  8 03 20 AM 08:20:03 AM 08:20 1142752803 03 08:20:03 7 0 06 2006' 
//			'% C 19 Sun Europe/London 08 0 k Sunday 03 20 p Sun, 19 Mar 2006 08:20:03 +0000 R 03 03 GMT 000000 0 06 2006'

			
			
			var len = from.length;
			for(i in 0...len)
				f = StringTools.replace(f, from[i], to[i]);
			return untyped __call__("date", f, d.getTime());
			*/
			return __jsflash_format(d, f );
		#else error
		#end
	}

	/**
		Returns a Date which time has been changed by [t] milliseconds.
	**/
	public static function delta( d : Date, t : Float ) : Date {
		return Date.fromTime( d.getTime() + t );
	}

	static var DAYS_OF_MONTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

	/**
		Returns the number of days in a month
	**/
	public static function getMonthDays( d : Date ) : Int {
		var month = d.getMonth();
		var year = d.getFullYear();

		if (month != 1)
			return DAYS_OF_MONTH[month];

		var isB = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
		return if (isB) 29 else 28;
	}

	/**
		Convert a number of seconds to a date-time
	**/
	public static function seconds( n : Float ) : Float {
		return n * 1000.0;
	}

	/**
		Convert a number of minutes to a date-time
	**/
	public static function minutes( n : Float ) : Float {
		return n * 60.0 * 1000.0;
	}

	/**
		Convert a number of hours to a date-time
	**/
	public static function hours( n : Float ) : Float {
		return n * 60.0 * 60.0 * 1000.0;
	}

	/**
		Convert a number of days to a date-time
	**/
	public static function days( n : Float ) : Float {
		return n * 24.0 * 60.0 * 60.0 * 1000.0;
	}

	/**
		Separate a date-time into several components
	**/
	public static function parse( t : Float ) {
		var s = t / 1000;
		var m = s / 60;
		var h = m / 60;
		return {
			ms : t % 1000,
			seconds : Std.int(s % 60),
			minutes : Std.int(m % 60),
			hours : Std.int(h % 24),
			days : Std.int(h / 24),
		};
	}

	/**
		Build a date-time from several components
	**/
	public static function make( o : { ms : Float, seconds : Int, minutes : Int, hours : Int, days : Int } ) {
		return o.ms + 1000.0 * (o.seconds + 60.0 * (o.minutes + 60.0 * (o.hours + 24.0 * o.days)));
	}

}
