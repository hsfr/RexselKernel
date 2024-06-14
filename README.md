# Rexsel Compiler #

*Rexsel* is a simplified (compact) version of XSLT. It does not use
XML to write the code, rather a simplified, easy to read language.
It has been successfully used on the [Paloose site](https://www.paloose.org)
and [Rexsel](https://www.rexsel.com/) sites generating all the necessary XSLT transform files.

It was conceived after many years of writing XSLT templates for translating XML into various forms: XML, XHTML, Swift code, and even LaTeX. While the underlying structure is virtually identical to XSLT, it is hoped that the result will help users produce more concise, readable stylesheets independent of XML.

```
stylesheet {
    version "1.0"
 
    function helloWorld {
        element "div" {
            attribute "class"  "simpleBox"
            text "Hello World!"
        }
    }
}

```

Rexsel was developed on a Mac using Xcode and Swift as the underlying language, however the actual compiler kernel is "OS neutral". The compiler (RexselKernel) is written as a Swift Package, currently here, and there is a command line application (CRexsel) currently here which is also also a Swift Package, that uses the RexselKernel package. Both can be built on any system that supports Swift. Currently it has been rxtensively tested on a MacOS system and a Parallels based Ubuntu and Fedora Linux, both running on MacOS 14.4.1 Sonora on a M2 Mac Mini.


Although there is no Apache Ant build system this could be
relatively quickly produced to support a Linux like system.
The compiler kernel is currently surrounded by 
a command line application and a simple editor app. The former
could also be directly ported to a Linux system. 

The CRexsel application also provides an "uncompiler" function that takes existing XSLT files and translates them to a basic Rexsel format (ignoring XML comments). This should make migrating XSLT stylesheets into Rexsel much easier.

There is a MacOS only application, using the same RexselKernel package, that provides an editor and real-time compile function.

### Caveats ###

The current version has a Tokenizer that is a little less than optimal and so
could be slower on large files (>800 lines). This will be investugated and
an updated version will be produced when I have the time.

### What is this repository for? ###

Anyone who uses XSLT to transform XML based documents who
wants a more concise approach to designing stylesheets.

### How do I get set up? ###

* There is an associated command line application that can be compiled on either MacOS or Linux.
It is supplied in the form of a Swift package.

* It uses both the Rexsel kernel and the ArgumentParser
package.

```
import PaItckageDescription

let package = Package(
    name: "crexsel",
    products: [
        .executable(name: "crexsel", targets: ["crexsel"]),
    ],
    dependencies: [
        .package(url: "https://bitbucket.org/hsfr/rexselkernel.git", branch: "master"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "crexsel",
            dependencies: [
                .product( name: "RexselKernel", package: "rexselkernel" ),
                .product( name: "ArgumentParser", package: "swift-argument-parser" ),
            ],
            resources: [
                .process( "Rexsel/Uncompile" )
            ]
        )
    ]
)
```
 
* The package can be downloaded by cloning the repository using

        git clone https://hsfr@bitbucket.org/hsfr/crexsel.git

### Who do I talk to? ###

* The author <hsfr@rexsel.com>
* [The oXygen XSLT Forum](https://www.oxygenxml.com/forum/xslt-and-fop/) 
