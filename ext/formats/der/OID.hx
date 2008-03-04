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
 * OID
 *
 * A list of various ObjectIdentifiers.
 */
package formats.der;
class OID
{

	public static RSA_ENCRYPTION:String				= "1.2.840.113549.1.1.1";
	public static MD2_WITH_RSA_ENCRYPTION:String	= "1.2.840.113549.1.1.2";
	public static MD5_WITH_RSA_ENCRYPTION:String 	= "1.2.840.113549.1.1.4";
	public static SHA1_WITH_RSA_ENCRYPTION:String	= "1.2.840.113549.1.1.5";
	public static MD2_ALGORITHM:String 				= "1.2.840.113549.2.2";
	public static MD5_ALGORITHM:String				= "1.2.840.113549.2.5";
	public static DSA:String						= "1.2.840.10040.4.1";
	public static DSA_WITH_SHA1:String				= "1.2.840.10040.4.3";
	public static DH_PUBLIC_NUMBER:String			= "1.2.840.10046.2.1";
	public static SHA1_ALGORITHM:String				= "1.3.14.3.2.26";

	public static COMMON_NAME:String				= "2.5.4.3";
	public static SURNAME:String					= "2.5.4.4";
	public static COUNTRY_NAME:String				= "2.5.4.6";
	public static LOCALITY_NAME:String				= "2.5.4.7";
	public static STATE_NAME:String					= "2.5.4.8";
	public static ORGANIZATION_NAME:String			= "2.5.4.10";
	public static ORG_UNIT_NAME:String				= "2.5.4.11";
	public static TITLE:String						= "2.5.4.12";

}