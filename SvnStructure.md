
---

# Basic concepts #

---

The haxe extended library is code licensed under the BSD license. Compiler extensions will be under the same license as Haxe itself, which is the GPL. Neko ndll source code can be under the LGPL, but not the GPL. The external dependency libraries may be LGPL as well.


---

# Directories #

---

# /compiler #
Haxe compiler and it's extensions. Current projects or proposals include
  * PHP
  * JVM

# /dll\_src #
> Where neko dll source code is to be located. The directory name should be the same, or very similar to, the haxe package name

# /ext #
This is the root of the extended standard library. Code in this directory itself is in null-package space.

### /ext/Tests ###
[Haxe unit tests](http://www.haxe.org/tutos/unittest) for all packages. All compiled test files are to be prefixed with _test. Neko would be_test.n, flash _test8.swf and_test9.swf, and javascript _test.js. An index.html file should be provided for testing javascript, index\_flash.html and index\_flash9.html for flash targets._

### /ext/Doc ###
Target directory for generated documentation. Documentation at this point is not to be committed.

### /ext/Tools ###
Client side tool source

### /ext/Bin ###
Compiled neko client side tools. Empty on svn.

# /tools #
Tools for building, cleaning, publishing caffeine-hx itself. Not client side tools, those would go in /ext/Tools