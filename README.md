# Rexsel Compiler #

*Rexsel* is a simplified (compact) version of XSLT. It does not use
XML to write the code, rather a simplified, easy to read language.
It has been successfully used on the [Paloose site](https://www.paloose.org)
generating all the necessary XSLT transform files.

*Rexsel* was conceived after many years of writing XSLT templates for translating XML
into various forms, including XML, XHTML, and even \LaTeX.
I believe the result will help users produce more concise,
readable stylesheets independent of XML or XSLT.
This will aid understanding of the actions of the various templates without the
confusion of XML constructs.

While *Rexsel* was developed on a Mac using Xcode and Swift
as the underlying language (the "uncompiler"
is written in *Rexsel* which is translated to XSLT)
the actual compiler kernel is "OS neutral" and could be compiled
on any system such as Linux that supports Swift. 

The compiler (RexselKernel) is written as a Swift Package
and can be built on any system that supports Swift.

Although there is no Apache Ant build system this could be
relatively quickly produced to support a Linux like system.  The compiler kernel is currently surrounded by 
a command line application and a simple editor app. The former could also be directly ported to a Linux system. 

### What is this repository for? ###

* Anyone who uses XSLT to transform XML based documents who wants a more concise approach to designing stylesheets.
* Latest Version 1.0.10h

### How do I get set up? ###

* Summary of set up
* Configuration
* Dependencies
* Database configuration
* How to run tests
* Deployment instructions

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact