//
//  RexselKernel.swift
//
//  RexselKernel Package
//
//  Created by Hugh Field-Richards on 10/01/2024.
//  Copyright 2024 Hugh Field-Richards. All rights reserved.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-* PUBLIC STRUCT *-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

public class RexselKernel {

    public static var sharedInstance = RexselKernel()

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Logging Properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Is logging required?
    ///
    /// This is the base of a slightly crude logging system.
    /// I would prefer to use something like Hestia but the
    /// overheads were too great.

    var isLogging = false

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Public Properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    // Make sure that this uses the Package scheme for tagged repository.
    public var version = "1.0.41"

    /// The XSLT version being used (set to initial minimum)
    public var xsltVersion = "1.0"

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
        guard let tokenizedSrc = tokenizedSource else { return true }
        guard tokenizedSourceIndex < tokenizedSrc.count else { return true }
        return ( tokenizedSource[ tokenizedSourceIndex ].what == .endOfFile )
    }

    var totalNumberOfTokens: Int {
        guard let tokenizedSrc = tokenizedSource else { return 0 }
        return tokenizedSrc.count
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
        guard let tokenizedSrc = tokenizedSource else {
            return 0
        }
        guard tokenizedSourceIndex < tokenizedSrc.count - 1 else {
            return 0
        }
        return tokenizedSrc[ tokenizedSourceIndex ].position
    }

    /// The current token based on the thisCompiler.tokenizedSourceIndex.
    /// If beyond end of buffer mark as end of file.
    var currentToken: TokenType {
        guard let tokenizedSrc = tokenizedSource else {
            return ( type: TokenEnum.unknown, what: .endOfFile, value: "", line: 0, position: 0 )
        }
        guard !isEndOfFile else {
            return ( type: TokenEnum.unknown, what: .endOfFile, value: "", line: tokenizedSrc.count, position: 0 )
        }
        return tokenizedSrc[ tokenizedSourceIndex ]
    }

    /// The next token based on the thisCompiler.tokenizedSourceIndex + 1.
    /// If beyond end of buffer mark as end of file.
    var nextToken: TokenType {
        let nextIndex = tokenizedSourceIndex + 1
        guard let tokenizedSrc = tokenizedSource else {
            return ( type: TokenEnum.unknown, what: .endOfFile, value: "", line: 0, position: 0 )
        }
       guard !isEndOfFile && tokenizedSrc.count > nextIndex else {
            return ( type: TokenEnum.unknown, what: .endOfFile, value: "", line: tokenizedSrc.count, position: 0 )
        }
        let token = tokenizedSrc[ nextIndex ]
        return token
    }

    /// The next + 1 token based on the thisCompiler.tokenizedSourceIndex + 2.
    /// If beyond end of buffer mark as end of file.
    var nextNextToken: TokenType {
        let nextNextIndex = tokenizedSourceIndex + 2
        guard let tokenizedSrc = tokenizedSource else {
            return ( type: TokenEnum.unknown, what: .endOfFile, value: "", line: 0, position: 0 )
        }
       guard !isEndOfFile && tokenizedSrc.count > nextNextIndex else {
            return ( type: TokenEnum.unknown, what: .endOfFile, value: "", line: tokenizedSrc.count, position: 0 )
        }
        return tokenizedSrc[ nextNextIndex ]
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

    /// List of declared namespaces from 'xmlns "prefix" "uri"'
    /// statements, togther with the line they were declared in).
    public var namespaceList: [ String: ( uri: String, inLine: Int ) ] = [:]

    /// Table of proc names [name: line number]
    /// within scope of template.
    var procNameTable = [String: Int]()

    /// Conveniece variable for _xmlnsPrefix_
    ///
    ///  Not generally changed but could be in extremis in future versions.
    var _xmlnsPrefix = "xsl"

    /// xmlns prefix used throughout generation phase.
    public var xmlnsPrefix: String {
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
    public var xsltNamespace: String {
        if !useDefaultXSLNamespace {
            return "xmlns:\(_xmlnsPrefix)=\"\(_xsltNamespace)\""
        } else {
            return "xmlns=\"\(_xsltNamespace)\""
        }
    }

    /// Number of errors
    public var totalErrors: Int {
        return rexselErrorList.count
    }

    /// Where the compiled XSLT will be placed
    public var compiledXSL: String = ""

    let rexselLogger = RexselLogger()

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    public init() {
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

    public func run( showUndefined: Bool = false,
                     lineNumbers: Bool = false,
                     defaultNameSpace: Bool = false,
                     verbose: Bool = false,
                     debugOn: Bool = false ) -> ( codeListing: String,
                                                  errorListing: String,
                                                  symbolTable: String )
    {
        if isLogging {
            rLogger.loggingLevelRequired = .debug
        }

        showUndefinedErrors = showUndefined
        showLineNumbers = lineNumbers
        useDefaultXSLNamespace = defaultNameSpace
        showFullMessages = verbose

        // Set up a root node that everything falls under
        rootNode = ExprNode()
        rootNode.isRootNode = true

        // Clear symbol table and list of namespaces used.
        globalNameTable = [:]
        namespaceList = [:]

        rexselErrorList = RexselErrorList()
        tokenizeSource()
        if showFullMessages {
            print( "Tokenizer finished" )
        }

        if isLogging {
            for ( type, what, numberValue, line, position ) in tokenizedSource {
                rLogger.log( structName,
                             .debug,
                             "[\(line):\(position)][\(type)][\(what)][\(numberValue)]" )
            }
        }

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

        rootNode.checkVariableScope( self )
        if showFullMessages {
            print( "Variable scope checks finished" )
        }

        let symbolTable = rootNode.symbolListing()

        // Finally generate the actual code
        compiledXSL = rootNode.generate()

        // The code is returned so that the command line and app can deal with
        // the errors and symbol table differently.
        return( compiledXSL, rexselErrorList.description, symbolTable )
    }

}
