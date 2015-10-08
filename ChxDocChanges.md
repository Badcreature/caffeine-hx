# Introduction #

With the release of ChxDoc 1.2, there have been some major changes that will definitely affect existing templates and the command line.

# Details #

These things will need to be done in order to migrate:
  * References to _meta_ in templates changed. See [#Template\_changes](#Template_changes.md)
  * _--includeOnly_ and _-f_ do not do filtering. See [#Filtering](#Filtering.md)
  * _--templateDir_ switch removed. See [#Specifying\_templates](#Specifying_templates.md)
  * Switch _-f_ retasked See [#The\_-f\_switch](#The_-f_switch.md)
  * Xml configuration. See [ChxDoc#Configuration](ChxDoc#Configuration.md)
  * [tags](#Undocumented.md)
  * Switch _--macroFile_ changed to _--macros_

## Template changes ##

If you have a custom template, you must change the _meta_ references to _webmeta_. This is generally at the top of your .mtt files and has the three elements _data_, _keywords_ and _stylesheet_. See revision [r734](https://code.google.com/p/caffeine-hx/source/detail?r=734) for diffs to the default templates for examples. The _meta_ tag is now part of the _docs_ and will display the haxe metadata associated with a class or class field. See the diff of class.mtt for an example of how to change your template.

## Filtering ##

Filtering used to be done with the _-f_, _--ignoreRoot_ and _--includeOnly_ switches. This did not allow for very fine grained control over what documentation got created. The new system in version 1.2 works more like a firewall, where packages are passed through the filter engine, which will either _allow_ or _deny_ documentation.

The _-f_, _--ignoreRoot_ and _--includeOnly_ switches have been removed. Use -_-policy_, _--allow_ and _--deny_. Refer to [ChxDoc#Package\_and\_Type\_filtering](ChxDoc#Package_and_Type_filtering.md)

## Specifying templates ##

_--templateDir_ has been removed. The new switch _--templatesDir__(note the s) specifies a base template path, and_--template_specifies the template to use. If your old syntax was__--templateDir=/chxdoc/templates/default__, it would now be__--templatesDir=/chxdoc/templates --template=default__. The actual path is found by combining the two, so actually specifying the full path in either will work. However, beware of default settings you have in your home .chxdoc file._

## The -f switch ##

On the command line, the haxe generated xml files used to be specified without a command line switch. This is no longer the case, and must be specified with _-f_ or _--file_. ` chxdoc -o docs flash.xml ` is now ` chxdoc -o docs -f flash.xml `

## Undocumented tags ##

Chxdoc is supposed to improve the end user experience, but some things slip through the cracks. Two tags @since and @version have existed for eons, but escaped being added to the wiki [ChxDoc#Using\_Tags](ChxDoc#Using_Tags.md) page.