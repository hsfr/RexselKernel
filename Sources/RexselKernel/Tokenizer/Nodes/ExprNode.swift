//
//  ExprNode.swift
//
//  Created by Hugh Field-Richards on 10/01/2024.
//  Copyright (c) 2024 Hugh Field-Richards. All rights reserved.

import Foundation

class ExprNode: NSObject {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Common instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    var exprNodeType = TerminalSymbolEnum.unknownToken

    var isRootNode: Bool = false

    /// The parent node for this now.
    var parentNode: ExprNode!

    /// A list of children below this node.
    var nodeChildren: [ExprNode]!

    var sourceLine = 0

    /// Name of this node (proc name etc)
    ///
    /// Mostly overriden
    var name = ""

    var sourcePosition = 0

    /// Check on required children.
    var requiredChildren: [TerminalSymbolEnum]!

    /// List of zero or one children.
    var zeroOrOneChildren: [TerminalSymbolEnum: TokenType]!

    /// Maintain a check on whether the child is not supported.
    var notSupported: [TerminalSymbolEnum]!

    /// Where the syntax definition is held.
    var allowableChildrenDict: AllowableSyntaxDictType

    /// The current compiler being invoked.
    ///
    /// There is one instance of the compiler for each open document.
    var thisCompiler: RexselKernel

    /// Whether we are processing a enclosed block.
    var isInBlock = false

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    /// A dictionary of declared XML namespaces (only used at root level)
    var xmlnsDict = XmlnsSymbolTableType()

    /// A dictionary of declared variables/parameters within this node's scope.
    ///
    /// Variables and Parameters are considered identical when considering
    /// duplication and missing symbols. The symbol table does distinguish
    /// but only for outputting the symbol table.
    var variablesDict: SymbolTable

    /// A dictionary of declared procs with this node's scope
    var procDict: SymbolTable

    /// This is a list of symbol tables that is added to as internal
    /// contexts are traversed (down).
    var currentVariableContextList = [SymbolTable]()

    /// A list of children that are present in the BNF syntax
    var childrenDict = [ TerminalSymbolEnum: AllowableSyntaxEntryStruct ]()

    /// A list of options (attributes) that are present in the BNF syntax
    var optionsDict = [ TerminalSymbolEnum: AllowableSyntaxEntryStruct ]()

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise Node base.

    override init() {
        zeroOrOneChildren = [TerminalSymbolEnum: TokenType]()
        requiredChildren = []
        notSupported = []
        isRootNode = false
        thisCompiler = RexselKernel()

        isInBlock = false
        name = ""

        xmlnsDict = XmlnsSymbolTableType()
        variablesDict = SymbolTable( thisCompiler )
        procDict = SymbolTable( thisCompiler )
        allowableChildrenDict = AllowableSyntaxDictType()

        childrenDict = [:]
        optionsDict = [:]

        super.init()
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Parsing/Generate Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse source (with tokens).
    ///
    /// Always overriden, but we set up various common variables.
    ///
    /// - Parameters:
    ///   - compiler: the current instance of the compiler.
    /// - Throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func parseSyntaxUsingCompiler( _ compiler: RexselKernel ) throws {
        thisCompiler = compiler
        sourceLine = thisCompiler.currentToken.line

        sourceLine = thisCompiler.tokenizedSource[ thisCompiler.tokenizedSourceIndex ].line
#if REXSEL_LOGGING
        rLogger.log( self, .debug, "Parsing \(thisCompiler.currentToken.what) statement in line \(sourceLine)")
#endif
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate XSLT tag.
    ///
    /// Always overriden, but line numbers added here if required.
    ///
    /// - Returns: Line number XML comment.

    func generate( ) -> String {
#if REXSEL_LOGGING
        rLogger.log( self, .debug, "Generating \(exprNodeType.description) node" )
#endif
        // Remember lines start at 0
        if showLineNumbers {
            return "<!-- Line: \(sourceLine+1) -->\n"
        }
        return ""
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check Duplicates Throughout Node Iree.
    ///
    /// Always overriden. All we do here is take in the variables
    /// list for scoping internal blocks.
    ///
    /// - Parameters:
    ///   - allowedTokens: A set of tokens (_TerminalSymbolEnum_)

    func buildSymbolTableAndSemanticChecks( allowedTokens tokenSet: Set<TerminalSymbolEnum> = [] ) {
        if !isRootNode {
            // Grab context list(s) from parent which conntains
            // all the scoping from higher contexts.
            currentVariableContextList = parentNode.currentVariableContextList
            // currentVariableContextList.append( SymbolTable() )
        }

        // Concentrate, this bit is a little tricky. Check for
        // allowed children.
        if let nodes = nodeChildren {
            for child in nodes {
                let childName = child.exprNodeType.description
                if let entry = allowableChildrenDict[ childName ] {
                    if !entry.duplicatesAllowed && entry.count > 1 && child.sourceLine != entry.defined {
                        try? markAlreadyDefined( what: child.exprNodeType,
                                                 this: child.sourceLine,
                                                 where: entry.defined )
                    }
                }
            }
        }

        // Now check for missing children
        if !tokenSet.isEmpty {
            for child in tokenSet {
                let childName = child.description
                if let entry = allowableChildrenDict[ childName ] {
                    if entry.required && entry.count == 0 {
                        // Raise an error
                        try? markExpectedKeywordError( expected: child,
                                                       inElement: exprNodeType,
                                                       inLine: sourceLine )
                    }
                }
            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check scope of variables.
    ///
    /// - Parameters:
    ///   - compiler: the current instance of the compiler.

    func checkVariableScope( _ compiler: RexselKernel ) { }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Scan for variables in XPath string.
    ///
    /// - Parameters:
    ///   - value: the string to scan.
    ///   - usingPrefix: using the "$" prefix in scan (defaults to *true*).
    ///   - inLine: the line number being scanned.

    func scanVariablesInNodeValue( _ value: String, usingPrefix: Bool = true, inLine: Int ) {
        // Extract all the variables in this node
        var variableNameList: [String]
        if usingPrefix {
            variableNameList = value.matchRegex( using: xPathVariablePattern )
        } else {
            variableNameList = value.matchRegex( using: simpleVariablePattern )
        }

        // For each of the variables found.
        for variableName in variableNameList {
            var normalisedName = variableName
            // Remove $ if there
            if normalisedName.hasPrefix( "$" ) {
                _ = normalisedName.removeFirst()
            }
            _ = doesContextContainVariable( normalisedName, line: inLine )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Scan for variables in block.
    ///
    /// - Parameters:
    ///   - nodes: the enclosed block as a set of nodes.

    func scanForVariablesInBlock( _ compiler: RexselKernel, _ nodes: [ExprNode] ) {
        for child in nodes {
            child.checkVariableScope( compiler )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Does variable exist in this context?
    ///
    /// If not in the context then will return false (which
    /// indicates variable not in scope). Since this is at
    /// the root level no further action needs to be taken.
    ///
    /// We need to check each variable context table and gradually work upwards
    /// to the root. Therefor check the local table first, XSLT/XPath will assume
    /// that the variable refers to a local declared variable first. If we get
    /// to the root then it is marked as not existing and an error is flagged.
    ///
    /// - Parameters:
    ///   - normalisedName: the variable name (without leading $).
    ///   - whereUsed: the line where this variable is being used (not defined).
    /// - Returns: _true_ if variable found.

    func doesContextContainVariable( _ normalisedName: String, line whereUsed: Int ) -> Bool {

        // Is variable defined in its own node.
        if variablesDict.isNameDeclared( normalisedName ) {
            variablesDict.addNameToUsedList( normalisedName, inLine: whereUsed )
            return true
        }

        // Invoke parent to see whether the variable is defined there.
        if parentNode.variablesDict.isNameDeclared( normalisedName ) {
            parentNode.variablesDict.addNameToUsedList( normalisedName, inLine: whereUsed )
            return true
        }

        // Not found so go up a level
        if parentNode.doesContextContainVariable( normalisedName, line: whereUsed ) {
            return true
        }
        return false
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate a list of symbols.
    ///
    /// Overridden if special needs.

    func symbolListing() -> String {
        var childrenSymbols = ""
        if let nodes = nodeChildren {
            for child in nodes {
                childrenSymbols += child.symbolListing()
            }
        }

        let thisSymbolListing = variablesDict.description

        let separator = thisSymbolListing.isNotEmpty ? "\n" : ""
        return "\(separator)\(thisSymbolListing)\(childrenSymbols)"
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check actual occurance against syntax.
    ///
    /// No return because only job is to report errors.

    func checkOccurances( _ actual: Int,
                          min minimum: Int, max maximum: Int,
                          name inName: String,
                          inKeyword: String )
    {
        switch ( minimum, maximum ) {

            // <x> x is required
            case ( 1, 1 ) where actual == 0 :
                markSyntaxRequiresElement( inLine: thisCompiler.currentToken.line,
                                           name: inName,
                                           inElement: inKeyword )

            // (x)? zero or one instance of x
            case ( 0, 1 ) where actual >= 2 :
                markSyntaxRequiresZeroOrOneElement( inLine: thisCompiler.currentToken.line,
                                                    name: inName,
                                                    inElement: inKeyword )

            // (x)* zero or more instances of x
            case ( 0, Int.max ) :
                ()

            // (x)+ one or more instances of x
            case ( 1, Int.max ) where actual == 0 :
                markSyntaxRequiresOneOrMoreElement( inLine: thisCompiler.currentToken.line,
                                                    name: inName,
                                                    inElement: inKeyword )

            default :
                ()
        }
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - General Error Methods
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension ExprNode {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark error for unknown symbol.

    func markUnexpectedExpressionError() {
#if REXSEL_LOGGING
        let errorMessage = RexselErrorKind.foundUnexpectedExpression(lineNumber: sourceLine, found: thisCompiler.currentToken.value ).description
        rLogger.log( self, .debug, "**** \(errorMessage)." )
#endif
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .foundUnexpectedExpression( lineNumber: sourceLine,
                                                found: thisCompiler.currentToken.value ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark error for string instead of character.
    ///
    /// Does not skip line as it just truncates.

    func markExpectedCharacterError() {
#if REXSEL_LOGGING
        rLogger.log( self, .debug, "**** Expected character in line \(thisCompiler.currentToken.line+1)" )
#endif
        thisCompiler.rexselErrorList
            .add( RexselErrorData.init( kind: RexselErrorKind
                .expectedCharacterNotString( lineNumber: thisCompiler.currentToken.line+1,
                                             position: thisCompiler.currentToken.position,
                                             found: thisCompiler.currentToken.value ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark error for expected parameter name.
    ///
    /// - Returns: true if successful, false if end of file.

    func markExpectedParameterNameErrorAndSkipLine() -> Bool {
#if REXSEL_LOGGING
        rLogger.log( self, .debug, "**** Unknown symbol '\(thisCompiler.currentToken.value)' in line \(thisCompiler.currentToken.line+1)" )
#endif
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .missingParameterName( lineNumber: thisCompiler.currentToken.line+1 ) ) )
        // Error in this line so move onto the token in the next line.
        let currentLine = thisCompiler.currentToken.line
        while currentLine == thisCompiler.tokenizedSource[ thisCompiler.tokenizedSourceIndex ].line {
            thisCompiler.tokenizedSourceIndex += 1
            guard !thisCompiler.isEndOfFile else {
                return false
            }
        }
        return true
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //

    func parameterCannotAppearHereError() {
#if REXSEL_LOGGING
        let errorMessage = RexselErrorKind.parameterCannotAppearHere(lineNumber: thisCompiler.currentToken.line+1).description
        rLogger.log( self, .debug, "**** \(errorMessage)" )
#endif
        thisCompiler.rexselErrorList
            .add( RexselErrorData.init( kind: RexselErrorKind
                .parameterCannotAppearHere( lineNumber: thisCompiler.currentToken.line+1 ) ) )
        var found = false
        while !found {
            thisCompiler.tokenizedSourceIndex += 1
            guard !thisCompiler.isEndOfFile else {
                return
            }
            found = thisCompiler.tokenizedSource[ thisCompiler.tokenizedSourceIndex ].what.isTerminalSymbol
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Is this token/keyword supported in the current XSLT specification.
    ///
    /// It relies on the array _notSupported_ to be set up in the
    /// appropriate node.
    ///
    /// - Parameters:
    ///   - incrementIndexBy: The amount the index has to be increased.
    /// - Returns: _true_ if supported, otherwise generates an error and return _false_.

    func isTokenSupportedKeyword( incrementIndexBy: Int ) -> Bool {
        if notSupported.contains( thisCompiler.currentToken.what ) {
#if REXSEL_LOGGING
            rLogger.log( self, .debug, "**** '\(thisCompiler.currentToken.value)' not supported in line \(thisCompiler.currentToken.line+1)" )
#endif
            thisCompiler.rexselErrorList
                .add( RexselErrorData
                    .init( kind: RexselErrorKind
                        .notSupported( lineNumber: thisCompiler.currentToken.line+1,
                                       name: thisCompiler.currentToken.value,
                                       inElement: TerminalSymbolEnum.stylesheet.description ) ) )
            // Assume that the unsupported output is correct syntax
            thisCompiler.tokenizedSourceIndex += incrementIndexBy
            return false
        }
        return true
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Is this token/keyword supported in the current version.
    ///
    /// - Parameters:
    ///   - token: The token to be checked (_TerminalSymbolEnum_).
    /// - Returns: _true_ if supported, otherwise generates an error and return _false_.

   func isTokenValidForThisVersion( _ token: TerminalSymbolEnum ) -> Bool {
        let tokenValue = token.rawValue
        let version = thisCompiler.xsltVersion
        let versionRangeMin = rexsel_versionRange[ version ]!.min
        let versionRangeMax = rexsel_versionRange[ version ]!.max
        let vRange = versionRangeMin..<versionRangeMax
        return vRange.contains( tokenValue )
    }



}

