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
package haxe;

// std
import Array;
import ByteStringTools;
import ByteString;
import Class;
import Constants;
import Date;
import DateTools;
import EReg;
import Hash;
import I32;
import I64;
import IntHash;
import IntIter;
import Lambda;
import List;
import Math;
import Reflect;
import Std;
import StdTypes;
import String;
import StringBuf;
import StringTools;
import Type;
import Xml;

import config.DotConfig;
import config.XmlConfig;

import crypt.Aes;
import crypt.IV;
import crypt.ModeCBC;
import crypt.ModeECB;
import crypt.PadNull;
import crypt.PadPkcs1Type1;
import crypt.PadPkcs1Type2;
import crypt.PadPkcs5;
import crypt.RSA;
import crypt.RSAEncrypt;
import crypt.Tea;
import crypt.cert.X509CertificateCollection;
import crypt.cert.X509Certificate;
import crypt.cert.MozillaRootCertificates;

import dates.GmtDate;

import formats.Base64;
import formats.der.DERByteString;
import formats.der.DER;
import formats.der.Integer;
import formats.der.ObjectIdentifier;
import formats.der.OID;
import formats.der.PEM;
import formats.der.PrintableString;
import formats.der.Sequence;
import formats.der.Set;
import formats.der.Types;
import formats.der.UTCTime;

import hash.HMAC;
import hash.Md5;
import hash.Sha1;
import hash.Sha256;
import hash.Util;

#if !neko
import haxe.Firebug;
#end
import haxe.Http;
import haxe.ImportAll;
import haxe.Log;
import haxe.Md5;
import haxe.PosInfos;
import haxe.Serializer;
import haxe.Stack;
import haxe.Template;
import haxe.Timer;
import haxe.Unserializer;
import haxe.UUID;

import haxe.remoting.AsyncAdapter;
import haxe.remoting.AsyncConnection;
import haxe.remoting.AsyncDebugConnection;
import haxe.remoting.AsyncProxy;
import haxe.remoting.Connection;
import haxe.remoting.DelayedConnection;
import haxe.remoting.EncRemotingAdaptor;

#if !neko
import haxe.remoting.FlashJsConnection;
#end
#if flash
import haxe.remoting.LocalConnection;
#end
#if neko
import haxe.remoting.NekoSocketConnection;
#end
import haxe.remoting.Proxy;
import haxe.remoting.SocketConnection;
import haxe.remoting.SocketProtocol;
#if flash
import haxe.remoting.SocketWrapper;
#end

import haxe.rtti.Infos;
import haxe.rtti.Type;
import haxe.rtti.XmlParser;

import haxe.xml.Check;
import haxe.xml.Fast;
import haxe.xml.Proxy;

import haxe.unit.TestCase;
import haxe.unit.TestResult;
import haxe.unit.TestRunner;
import haxe.unit.TestStatus;

#if flash9

// generated by haxe
import flash.Boot;
import flash.Lib;
import flash.FlashXml__;
import flash.accessibility.Accessibility;
import flash.accessibility.AccessibilityImplementation;
import flash.accessibility.AccessibilityProperties;
import flash.display.ActionScriptVersion;
import flash.display.AVM1Movie;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.BlendMode;
import flash.display.CapsStyle;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.FrameLabel;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.IBitmapDrawable;
import flash.display.InteractiveObject;
import flash.display.InterpolationMethod;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.MorphShape;
import flash.display.MovieClip;
import flash.display.PixelSnapping;
import flash.display.Scene;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.SpreadMethod;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageQuality;
import flash.display.StageScaleMode;
import flash.display.SWFVersion;
import flash.events.ActivityEvent;
import flash.events.AsyncErrorEvent;
import flash.events.ContextMenuEvent;
import flash.events.DataEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.EventPhase;
import flash.events.FocusEvent;
import flash.events.FullScreenEvent;
import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;
import flash.events.IMEEvent;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NetFilterEvent;
import flash.events.NetStatusEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.StatusEvent;
import flash.events.SyncEvent;
import flash.events.TextEvent;
import flash.events.TimerEvent;
import flash.events.WeakFunctionClosure;
import flash.events.WeakMethodClosure;
import flash.external.ExternalInterface;
import flash.filters.BevelFilter;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterQuality;
import flash.filters.BitmapFilterType;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.filters.ConvolutionFilter;
import flash.filters.DisplacementMapFilter;
import flash.filters.DisplacementMapFilterMode;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.filters.GradientBevelFilter;
import flash.filters.GradientGlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;
import flash.media.Camera;
import flash.media.ID3Info;
import flash.media.Microphone;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundLoaderContext;
import flash.media.SoundMixer;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.DynamicPropertyOutput;
import flash.net.FileFilter;
import flash.net.FileReference;
import flash.net.FileReferenceList;
import flash.net.IDynamicPropertyOutput;
import flash.net.IDynamicPropertyWriter;
import flash.net.LocalConnection;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.ObjectEncoding;
import flash.net.Responder;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;
import flash.net.Socket;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLStream;
import flash.net.URLVariables;
import flash.net.XMLSocket;
import flash.printing.PrintJob;
import flash.printing.PrintJobOptions;
import flash.printing.PrintJobOrientation;
import flash.system.ApplicationDomain;
import flash.system.Capabilities;
import flash.system.FSCommand;
import flash.system.IME;
import flash.system.IMEConversionMode;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.system.SecurityDomain;
import flash.system.SecurityPanel;
import flash.system.System;
import flash.text.AntiAliasType;
import flash.text.CSMSettings;
import flash.text.Font;
import flash.text.FontStyle;
import flash.text.FontType;
import flash.text.GridFitType;
import flash.text.StaticText;
import flash.text.StyleSheet;
import flash.text.TextColorType;
import flash.text.TextDisplayMode;
import flash.text.TextExtent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextFormatDisplay;
import flash.text.TextLineMetrics;
import flash.text.TextRenderer;
import flash.text.TextRun;
import flash.text.TextSnapshot;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuBuiltInItems;
import flash.ui.ContextMenuItem;
import flash.ui.Keyboard;
import flash.ui.KeyLocation;
import flash.ui.Mouse;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Endian;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;
import flash.utils.ObjectInput;
import flash.utils.ObjectOutput;
import flash.utils.Proxy;
import flash.utils.SetIntervalTimer;
import flash.utils.Timer;
import flash.xml.XMLDocument;
import flash.xml.XMLNode;
import flash.xml.XMLNodeType;
import flash.xml.XMLParser;
import flash.xml.XMLTag;

#else flash

import flash.Boot;
import flash.Lib;

import flash.Accessibility;
import flash.Button;
import flash.Camera;
import flash.Color;
import flash.ContextMenu;
import flash.ContextMenuItem;
import flash.ExtendedKey;
import flash.Key;
import flash.LoadVars;
import flash.LocalConnection;
import flash.Microphone;
import flash.Mouse;
import flash.MovieClip;
import flash.MovieClipLoader;
import flash.NetConnection;
import flash.NetStream;
import flash.PrintJob;
import flash.Selection;
import flash.SharedObject;
import flash.Sound;
import flash.Stage;
import flash.System;
import flash.TextField;
import flash.TextFormat;
import flash.TextSnapshot;
import flash.Video;
import flash.XMLRequest;
import flash.XMLSocket;

import flash.text.StyleSheet;
import flash.system.Capabilities;
import flash.system.Security;

// generated by haxe
import flash9.Boot;
import flash9.Lib;
import flash9.FlashXml__;
import flash9.accessibility.Accessibility;
import flash9.accessibility.AccessibilityImplementation;
import flash9.accessibility.AccessibilityProperties;
import flash9.display.ActionScriptVersion;
import flash9.display.AVM1Movie;
import flash9.display.Bitmap;
import flash9.display.BitmapData;
import flash9.display.BitmapDataChannel;
import flash9.display.BlendMode;
import flash9.display.CapsStyle;
import flash9.display.DisplayObject;
import flash9.display.DisplayObjectContainer;
import flash9.display.FrameLabel;
import flash9.display.GradientType;
import flash9.display.Graphics;
import flash9.display.IBitmapDrawable;
import flash9.display.InteractiveObject;
import flash9.display.InterpolationMethod;
import flash9.display.JointStyle;
import flash9.display.LineScaleMode;
import flash9.display.Loader;
import flash9.display.LoaderInfo;
import flash9.display.MorphShape;
import flash9.display.MovieClip;
import flash9.display.PixelSnapping;
import flash9.display.Scene;
import flash9.display.Shape;
import flash9.display.SimpleButton;
import flash9.display.SpreadMethod;
import flash9.display.Sprite;
import flash9.display.Stage;
import flash9.display.StageAlign;
import flash9.display.StageQuality;
import flash9.display.StageScaleMode;
import flash9.display.SWFVersion;
import flash9.events.ActivityEvent;
import flash9.events.AsyncErrorEvent;
import flash9.events.ContextMenuEvent;
import flash9.events.DataEvent;
import flash9.events.ErrorEvent;
import flash9.events.Event;
import flash9.events.EventDispatcher;
import flash9.events.EventPhase;
import flash9.events.FocusEvent;
import flash9.events.FullScreenEvent;
import flash9.events.HTTPStatusEvent;
import flash9.events.IEventDispatcher;
import flash9.events.IMEEvent;
import flash9.events.IOErrorEvent;
import flash9.events.KeyboardEvent;
import flash9.events.MouseEvent;
import flash9.events.NetFilterEvent;
import flash9.events.NetStatusEvent;
import flash9.events.ProgressEvent;
import flash9.events.SecurityErrorEvent;
import flash9.events.StatusEvent;
import flash9.events.SyncEvent;
import flash9.events.TextEvent;
import flash9.events.TimerEvent;
import flash9.events.WeakFunctionClosure;
import flash9.events.WeakMethodClosure;
import flash9.external.ExternalInterface;
import flash9.filters.BevelFilter;
import flash9.filters.BitmapFilter;
import flash9.filters.BitmapFilterQuality;
import flash9.filters.BitmapFilterType;
import flash9.filters.BlurFilter;
import flash9.filters.ColorMatrixFilter;
import flash9.filters.ConvolutionFilter;
import flash9.filters.DisplacementMapFilter;
import flash9.filters.DisplacementMapFilterMode;
import flash9.filters.DropShadowFilter;
import flash9.filters.GlowFilter;
import flash9.filters.GradientBevelFilter;
import flash9.filters.GradientGlowFilter;
import flash9.geom.ColorTransform;
import flash9.geom.Matrix;
import flash9.geom.Point;
import flash9.geom.Rectangle;
import flash9.geom.Transform;
import flash9.media.Camera;
import flash9.media.ID3Info;
import flash9.media.Microphone;
import flash9.media.Sound;
import flash9.media.SoundChannel;
import flash9.media.SoundLoaderContext;
import flash9.media.SoundMixer;
import flash9.media.SoundTransform;
import flash9.media.Video;
import flash9.net.DynamicPropertyOutput;
import flash9.net.FileFilter;
import flash9.net.FileReference;
import flash9.net.FileReferenceList;
import flash9.net.IDynamicPropertyOutput;
import flash9.net.IDynamicPropertyWriter;
import flash9.net.LocalConnection;
import flash9.net.NetConnection;
import flash9.net.NetStream;
import flash9.net.ObjectEncoding;
import flash9.net.Responder;
import flash9.net.SharedObject;
import flash9.net.SharedObjectFlushStatus;
import flash9.net.Socket;
import flash9.net.URLLoader;
import flash9.net.URLLoaderDataFormat;
import flash9.net.URLRequest;
import flash9.net.URLRequestHeader;
import flash9.net.URLRequestMethod;
import flash9.net.URLStream;
import flash9.net.URLVariables;
import flash9.net.XMLSocket;
import flash9.printing.PrintJob;
import flash9.printing.PrintJobOptions;
import flash9.printing.PrintJobOrientation;
import flash9.system.ApplicationDomain;
import flash9.system.Capabilities;
import flash9.system.FSCommand;
import flash9.system.IME;
import flash9.system.IMEConversionMode;
import flash9.system.LoaderContext;
import flash9.system.Security;
import flash9.system.SecurityDomain;
import flash9.system.SecurityPanel;
import flash9.system.System;
import flash9.text.AntiAliasType;
import flash9.text.CSMSettings;
import flash9.text.Font;
import flash9.text.FontStyle;
import flash9.text.FontType;
import flash9.text.GridFitType;
import flash9.text.StaticText;
import flash9.text.StyleSheet;
import flash9.text.TextColorType;
import flash9.text.TextDisplayMode;
import flash9.text.TextExtent;
import flash9.text.TextField;
import flash9.text.TextFieldAutoSize;
import flash9.text.TextFieldType;
import flash9.text.TextFormat;
import flash9.text.TextFormatAlign;
import flash9.text.TextFormatDisplay;
import flash9.text.TextLineMetrics;
import flash9.text.TextRenderer;
import flash9.text.TextRun;
import flash9.text.TextSnapshot;
import flash9.ui.ContextMenu;
import flash9.ui.ContextMenuBuiltInItems;
import flash9.ui.ContextMenuItem;
import flash9.ui.Keyboard;
import flash9.ui.KeyLocation;
import flash9.ui.Mouse;
import flash9.utils.ByteArray;
import flash9.utils.Dictionary;
import flash9.utils.Endian;
import flash9.utils.IDataInput;
import flash9.utils.IDataOutput;
import flash9.utils.IExternalizable;
import flash9.utils.ObjectInput;
import flash9.utils.ObjectOutput;
import flash9.utils.Proxy;
import flash9.utils.SetIntervalTimer;
import flash9.utils.Timer;
import flash9.xml.XMLDocument;
import flash9.xml.XMLNode;
import flash9.xml.XMLNodeType;
import flash9.xml.XMLParser;
import flash9.xml.XMLTag;

#end

#if flash8

import flash.display.BitmapData;
import flash.external.ExternalInterface;
import flash.filters.BevelFilter;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.filters.ConvolutionFilter;
import flash.filters.DisplacementMapFilter;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.filters.GradientBevelFilter;
import flash.filters.GradientGlowFilter;

import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;

import flash.net.FileReference;
import flash.net.FileReferenceList;

import flash.system.IME;
import flash.text.TextRenderer;

#end

#if neko

import neko.Boot;
import neko.FileSystem;
import neko.Int32;
import neko.Lib;
import neko.Random;
import neko.Sys;
import neko.Utf8;
import neko.Web;

import neko.io.Error;
import neko.io.File;
import neko.io.FileInput;
import neko.io.FileOutput;
import neko.io.Input;
import neko.io.Logger;
import neko.io.Multiple;
import neko.io.Output;
import neko.io.Path;
import neko.io.Process;
import neko.io.StringInput;
import neko.io.StringOutput;
import neko.io.TmpFile;

import neko.zip.Compress;
import neko.zip.CRC32;
import neko.zip.Flush;
import neko.zip.Reader;
import neko.zip.Uncompress;
import neko.zip.Writer;

import neko.db.Connection;
import neko.db.Manager;
import neko.db.Mysql;
import neko.db.Object;
import neko.db.ResultSet;
import neko.db.Sqlite;
import neko.db.Transaction;

import neko.net.Host;
import neko.net.InternalSocket;
import neko.net.InternalSocketInput;
import neko.net.InternalSocketOutput;
import neko.net.Poll;
import neko.net.ProxyDetect;
import neko.net.RemotingServer;
import neko.net.ServerLoop;
import neko.net.Socket;
import neko.net.SocketInput;
import neko.net.SocketOutput;
import neko.net.ThreadRemotingServer;
import neko.net.ThreadServer;
import neko.net.UdpReliableEvent;
import neko.net.UdpReliableSocket;
import neko.net.UdpReliableSocketInput;
import neko.net.UdpReliableSocketOutput;

import neko.net.servers.EncThrRemotingServer;
import neko.net.servers.GenericServer;
import neko.net.servers.InternalSocketRealtimeServer;
import neko.net.servers.MetaServer;
import neko.net.servers.RealtimeServer;
import neko.net.servers.TcpRealtimeServer;
import neko.net.servers.UdprRealtimeServer;

import neko.vm.Loader;
import neko.vm.Module;
import neko.vm.Thread;
import neko.vm.Lock;
import neko.vm.Ui;
import neko.vm.Gc;

#end

#if js

import js.Boot;
import js.Lib;
import js.Dom;
import js.Selection;
import js.XMLHttpRequest;
import js.XMLSocket;

#end

import math.BigInteger;
import math.prng.Random;
import math.prng.ArcFour;
import math.reduction.Barrett;
import math.reduction.Classic;
import math.reduction.Null;

import protocols.Mime;
import protocols.http.Cookie;

#if neko
import servers.http.Range;
//import servers.http.hive.Client;
//import servers.http.hive.Handler;
//import servers.http.hive.Logger;
//import servers.http.hive.Request;
//import servers.http.hive.Resource;
//import servers.http.hive.Response;
//import servers.http.hive.Server;
//import servers.http.hive.ServerConfig;
import servers.http.hive.ThreadPollServer;
import servers.http.hive.TypesHttp;
#end

#if neko
import xdiff.Tools;
#end

// TOOLS

#if neko

import tools.haxedoc.Main;
import tools.haxelib.Main;
import tools.haxelib.Site;
//import tools.hxinst.Main -> needs xCross
//import tools.HaxelibRelease;
//import tools.PrTool;

#end

