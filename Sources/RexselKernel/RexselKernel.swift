//
//  RexselKernel.swift
//  Compiler Package
//
//  Created by Hugh Field-Richards on 19/08/2014.
//  Copyright (c) 2014 Hugh Field-Richards. All rights reserved.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-* PUBLIC STRUCT *-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

public class RexselKernel {

    public static var sharedInstance = RexselKernel()

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Class Properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    /// Flag to mark that end of file has been reached
    static var endOfFile = false

    /// The actual line number in the view indexed by the source number
    static var listingLineNumbers = [Int: Int]()

    /// The actual line number in the view indexed by the source number
    static var currentListingLineNumber: Int = 0

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Public Properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    // Make sure  that this uses the Package scheme for tagged repository.
    public var version = "1.0.16"

    /// A list of the current errors
    public var rexselErrorList = RexselErrorList()

    /// The source string from the source window
    public var source = Source()

    /// Turn on debug logger.
    public var debugOn = false

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance Properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    /// Convenience for logging system
    let structName = "RexselKernel"

    /// Convenience for logging current token
    var currentTokenLog: String {
        return "[\(nestedLevel)] - currentToken = [\(currentToken.line):\(currentToken.position)][\(currentToken.type)][\(currentToken.what)][\(currentToken.value)]"
    }

    /// Convenience for logging current token + 1
    var nextTokenLog: String {
        return "nextToken = [\(nextToken.line):\(nextToken.position)][\(nextToken.type)][\(nextToken.what)][\(nextToken.value)]"
    }

    /// Convenience for logging current token + 2
    var nextNextTokenLog: String {
        return "nextNextToken = [\(nextNextToken.line):\(nextNextToken.position)][\(nextNextToken.type)][\(nextNextToken.what)][\(nextNextToken.value)]"
    }

    /// The source as an array of tokens
    var tokenizedSource: TokenizedFileType!

    /// The master index of the tokens
    var tokenizedSourceIndex = 0

    var isEndOfFile: Bool {
        guard tokenizedSourceIndex < tokenizedSource.count else { return true }
        return ( tokenizedSource[ tokenizedSourceIndex ].what == .endOfFile )
    }

    var totalNumberOfTokens: Int {
        return tokenizedSource.count
    }

    /// Is this the last token in the line?
    var isCurrentTokenLastTokenInLine: Bool {
        return currentLine != nextLine
    }

    var isNextTokenLastTokenInLine: Bool {
        return nextLine != nextNextLine
    }

    var currentSourceLineNumber: Int {
        return tokenizedSource[ tokenizedSourceIndex ].line
    }

    /// Where this element/expression is declared in the line.
    ///
    /// - Returns : position in line starting at zero. If beyond end of buffer return 0.
    ///
    /// Note that index starts at zero so if outputting line add 1.
    var sourcePosition: Int {
        guard tokenizedSourceIndex < tokenizedSource.count - 1 else {
            return 0
        }
        return tokenizedSource[ tokenizedSourceIndex ].position
    }

    /// The current token based on the thisCompiler.tokenizedSourceIndex.
    /// If beyond end of buffer mark as end of file.
    var currentToken: TokenType {
        guard !isEndOfFile else {
            return ( type: TokenEnum.unknown, what: .endOfFile, value: "", line: tokenizedSource.count, position: 0 )
        }
        return tokenizedSource[ tokenizedSourceIndex ]
    }

    /// The next token based on the thisCompiler.tokenizedSourceIndex + 1.
    /// If beyond end of buffer mark as end of file.
    var nextToken: TokenType {
        let nextIndex = tokenizedSourceIndex + 1
        guard !isEndOfFile && tokenizedSource.count > nextIndex else {
            return ( type: TokenEnum.unknown, what: .endOfFile, value: "", line: tokenizedSource.count, position: 0 )
        }
        let token = tokenizedSource[ nextIndex ]
        return token
    }

    /// The next + 1 token based on the thisCompiler.tokenizedSourceIndex + 2.
    /// If beyond end of buffer mark as end of file.
    var nextNextToken: TokenType {
        let nextNextIndex = tokenizedSourceIndex + 2
        guard !isEndOfFile && tokenizedSource.count > nextNextIndex else {
            return ( type: TokenEnum.unknown, what: .endOfFile, value: "", line: tokenizedSource.count, position: 0 )
        }
        return tokenizedSource[ nextNextIndex ]
    }

    /// The line number of the current token.
    var currentLine: Int {
        return currentToken.line
    }

    /// The line number of the current + 1 token.
    var nextLine: Int {
        return nextToken.line
    }

    /// The line number of the current + 2 token.
    var nextNextLine: Int {
        return nextNextToken.line
    }

    // Tracks the current bracket nested. Souold be zero at the end.
    var nestedLevel: Int = 0

    /// Holds the full source (convenient for tokenizer.
    var sourceString: String = ""

    /// Root of the compile tree
    var rootNode: ExprNode!

    /// Table of variable and parameter names [name: line number]
    /// at top (global) level.
    var globalNameTable = [String: Int]()

    /// Table of function names [name: line number]
    /// within scope of template.
    var functionNameTable = [String: Int]()

    /// Conveniece variable for _xmlnsPrefix_
    ///
    ///  Not generally changed but could be in extremis in future versions.
    var _xmlnsPrefix = "xsl"

    /// xmlns prefix used throughout generation phase.
    var xmlnsPrefix: String {
        get {
            if !useDefaultXSLNamespace {
                return "\(_xmlnsPrefix):"
            } else {
                return ""
            }
        }
        set (prefix) {
            _xmlnsPrefix = prefix
        }
    }

    /// Conveniece variable for _xsltNamespace_
    ///
    ///  Not generally changed but could be in extremis in future versions.
    var _xsltNamespace = "http://www.w3.org/1999/XSL/Transform"

    /// Convenience namespace constant for inserting in output.
    var xsltNamespace: String {
        if !useDefaultXSLNamespace {
            return "xmlns:\(_xmlnsPrefix)=\"\(_xsltNamespace)\""
        } else {
            return "xmlns=\"\(_xsltNamespace)\""
        }
    }

    /// Number of errors
    var totalErrors: Int {
        return rexselErrorList.count
    }

    /// Where the compiled XSLT will be placed
    var compiledXSL: String = ""

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    public init() {
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    public func uncompileXSL( _ inputFileName: String ) -> String
    {
        if debugOn {
            rLogger.loggingRequired = .debug
        }

#if os(macOS)
        guard let uncompileScript = Bundle.main.path( forResource: "xsl2rexsel", ofType: "xsl" ) else {
            print( "Cannot find uncompile stylesheet (xsl2rexsel.xsl) in RexselKernel package")
            return ""
        }
#elseif os(Linux)
        guard let uncompileScript = Bundle.main.path( forResource: "xsl2rexsel", ofType: "xsl" ) else {
            print( "Cannot find uncompile stylesheet (xsl2rexsel.xsl) in RexselKernel package")
            return ""
        }
#endif

        guard FileManager.default.fileExists( atPath: inputFileName ) else {
            print( "File '\(inputFileName)' does not exist, skipping")
            return ""
        }

        let uncompileScriptURL = URL( fileURLWithPath: uncompileScript )
        let inputFileURL = URL( string: inputFileName )!

        let ext = inputFileURL.pathExtension
        guard ext == "xsl" || ext == "xslt" else {
            print( "Unknown or missing extension: '\(ext)', skipping")
            return ""
        }


        let task = Process()
#if os(macOS)
        task.launchPath = "/usr/bin/xsltproc"
#elseif os(Linux)
        task.executableURL = URL( string: "/usr/bin/xsltproc" )
#endif
        task.arguments = [ uncompileScriptURL.absoluteString, inputFileURL.absoluteString ]
        let pipe = Pipe()
        task.standardOutput = pipe
#if os(macOS)
        task.launch()
#elseif os(Linux)
        try? task.run()
#endif
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let xsltResult = String(data: data, encoding: .utf8)!
        return xsltResult
    }


    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Public Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    ///
    /// Run Compiler.
    ///
    /// This is where we invoke the compiler.
    ///
    /// - Returns: Tuple ( codeListing, errorListing, symbolTable ) all `String`

    public func run( debugOn: Bool = false ) -> ( codeListing: String,
                                                  errorListing: String,
                                                  symbolTable: String )
    {
        if debugOn {
            rLogger.loggingRequired = .debug
        }

        // Set up a root node that everything falls under
        rootNode = ExprNode()
        rootNode.isRootNode = true

        // Clear symbol table
        globalNameTable = [:]

        rexselErrorList = RexselErrorList()
        tokenizeSource()
        if showFullMessages {
            print( "Tokenizer finished" )
        }

#if REXSEL_LOGGING
        for ( type, what, numberValue, line, position ) in tokenizedSource {
            rLogger.log( structName,
                         .debug,
                         "[\(line):\(position)][\(type)][\(what)][\(numberValue)]" )
        }
#endif

        do {
            RexselErrorList.undefinedErrorsFlag = false
            try parse()
            if showFullMessages {
                print( "Parse complete" )
            }
        } catch let error as RexselErrorData {
            print( error.errorMessage )
        } catch {
            print( "Unknown parse error!" )
        }

        // At this point we can apply a set of homomorphisisms
        // on the node tree to carry out further checks and
        // generate the XSL code.
        rootNode.buildSymbolTableAndSemanticChecks()
        if showFullMessages {
            print( "Semantic checks finished" )
        }
        rootNode.checkVariableScope()
        if showFullMessages {
            print( "Variable scope checks finished" )
        }
        let symbolTable = rootNode.symbolListing()

        // Finally generate the actual code
        compiledXSL = rootNode.generate()

        // The code is returned so that command line and app can deal with
        // the errors and symbol table differently.
        return( compiledXSL, rexselErrorList.description, symbolTable )
    }

}
