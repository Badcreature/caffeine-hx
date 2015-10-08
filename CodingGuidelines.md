# Classes #
  * Classes must have a descriptive header doc to explain the use of the class
  * Functions should be well commented for user documentation.
  * Public variables should be commented
  * Where possible, document @PARAM and @THROW


# General #

  * Whenever possible, avoid highly complex haxe code. Caffeine should be easy to maintain for a haxe programmer not at your skill level.
  * Avoid Dynamic
  * Avoid untyped
  * Avoid cast
  * Avoid Reflect

# Haxe Std Library #

Caffeine-hx includes files from the Haxe standard library that have been modified by Caffeine developers. When modifying a standard library file, any function that is modified _must be_ enclosed within a special comment block.
```
/* This sample is of a new change to submit */
    //*/2008-02-07//Russell Weir/Function created
    public static function isFile( path : String ) : Bool {
        return kind(path) == kfile;
    }
    //*///

/* This one has been submitted on the 21st */
    //*/2008-01-20/2008-01-21/Russell Weir/Fix path bug
    public static function readDirectory( path : String ) : Array<String> {
        var l : Array<Dynamic> = sys_read_dir(untyped path.__s);
        var a = new Array();
        while( l != null ) {
            a.push(new String(l[0]));
            l = l[1];
        }
        return a;
    }
    //*/2008-02-01//
/* And was accepted on 2008-02-01 */
```
  * The top comment is `//*/Created Date/Submit Date/Author/Comment`
  * The bottom is `//*/Accepted Date/Rejected Date/Reason`