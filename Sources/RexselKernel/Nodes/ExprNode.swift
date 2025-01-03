//
//  ExprNode.swift
//
//  Created by Hugh Field-Richards on 10/01/2024.
//  Copyright 2024 Hugh Field-Richards. All rights reserved.

import Foundation

class ExprNode: NSObject {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Logging Properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Is logging required for this node?
    ///
    /// This is the base of a slightly crude logging system.
    /// I would prefer to use something like Hestia but the
    /// overheads were too great.

    var isLogging = false

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Common instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    var thisExprNodeType = TerminalSymbolEnum.unknownToken

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

    /// A dictionary of declared keys with this node's scope
    var keyDict: SymbolTable

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
        variablesDict = SymbolTable( thisCompiler, type: .variable )
        procDict = SymbolTable( thisCompiler, type: .proc )
        keyDict = SymbolTable( thisCompiler, type: .key )
        allowableChildrenDict = AllowableSyntaxDictType()

        childrenDict = [:]
        optionsDict = [:]

        isLogging = false

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
        if isLogging {
            rLogger.log( self, .debug, "Parsing \(thisCompiler.currentToken.what) statement in line \(sourceLine)")
        }
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
        if isLogging {
            rLogger.log( self, .debug, "Generating \(thisExprNodeType.description) node" )
        }
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
        }

        // Concentrate, this bit is a little tricky. Check for
        // allowed children.
        if let nodes = nodeChildren {
            for child in nodes {
                let childName = child.thisExprNodeType.description
                if let entry = allowableChildrenDict[ childName ] {
                    if !entry.duplicatesAllowed && entry.count > 1 && child.sourceLine != entry.defined {
                        try? markAlreadyDefined( what: child.thisExprNodeType,
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
                                                       inElement: thisExprNodeType,
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
    /// Set up the syntax based on the BNF.

    func setSyntax( options optionsList: TerminalSymbolEnumSetType, 
                    elements elementsList: TerminalSymbolEnumSetType ) {
        for keyword in optionsList {
            optionsDict[ keyword ] = AllowableSyntaxEntryStruct( min: 0, max: 1 )
        }

        for keyword in elementsList {
            childrenDict[ keyword ] = AllowableSyntaxEntryStruct( min: 0, max: Int.max )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check the syntax that was input against that defined
    /// in _setSyntax_. Any special requirements are done here
    /// such as required combinations of keywords.

    func checkSyntax()
    {
        for ( keyword, entry ) in optionsDict {
            checkOccurances( entry.count,
                             min: entry.min, max: entry.max,
                             name: keyword.description,
                             inKeyword: self )
        }
        for ( keyword, entry ) in childrenDict {
            checkOccurances( entry.count,
                             min: entry.min, max: entry.max,
                             name: keyword.description,
                             inKeyword: self )
        }
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
                          inKeyword: ExprNode )
    {
         switch ( minimum, maximum ) {

            // <x> x is required
            case ( 1, 1 ) where actual == 0 :
                markSyntaxRequiresElement( inLine: inKeyword.sourceLine,
                                           name: inName,
                                           inElement: inKeyword.thisExprNodeType.description )

            // (x)? zero or one instance of x
            case ( 0, 1 ) where actual >= 2 :
                markSyntaxRequiresZeroOrOneElement( inLine: inKeyword.sourceLine,
                                                    name: inName,
                                                    inElement: inKeyword.thisExprNodeType.description )

            // (x)* zero or more instances of x
            case ( 0, Int.max ) :
                ()

            // (x)+ one or more instances of x
            case ( 1, Int.max ) where actual == 0 :
                markSyntaxRequiresOneOrMoreElement( inLine: inKeyword.sourceLine,
                                                    name: inName,
                                                    inElement: inKeyword.thisExprNodeType.description )

            default :
                ()
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Helper function to detect valid block tokens.

    func isInChildrenTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return childrenDict.keys.contains(token)
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Helper function to detect valid option tokens.

    func isInOptionTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return optionsDict.keys.contains(token)
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Return a description of selected tokens for error report.

    func tokensDescription( _ tokens: TerminalSymbolEnumSetType ) -> String
    {
        var str = ""
        for entry in tokens {
            // Only output the token if it is within allowed version.
            let tokenValue = entry.rawValue
            let version = thisCompiler.xsltVersion
            let versionRangeMin = rexsel_versionRange[ version ]!.min
            let versionRangeMax = rexsel_versionRange[ version ]!.max
            let vRange = versionRangeMin..<versionRangeMax
            if vRange.contains( tokenValue ) {
                str += "\(entry.description), "
            }
        }
        // Clean up the output.
        if str.isNotEmpty {
            str.removeLast(2)
        }
        return str
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
    /// Mark error for string instead of character.
    ///
    /// Does not skip line as it just truncates.

    func markExpectedCharacterError() {
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
    /// Mark error if current keyword not supported.
    ///
    /// There is a special case where xsl:script is only
    /// supported in version 1.1.
    ///
    /// - Parameters:
    ///   - compiler: the compiler instance being used.

    func markIfInvalidKeywordForThisVersion( _ thisCompiler: RexselKernel ) -> Bool {
        let tokenValue = thisCompiler.currentToken.what.rawValue
        let version = thisCompiler.xsltVersion
        var illegalKeywordForThisVersion = false

        // Special case!
        if thisCompiler.currentToken.what == .script && version != rexsel_xsltversion11 {
            illegalKeywordForThisVersion = true
        }

        let versionRangeMin = rexsel_versionRange[ version ]!.min
        let versionRangeMax = rexsel_versionRange[ version ]!.max
        let vRange = versionRangeMin..<versionRangeMax
        if !vRange.contains( tokenValue ) {
            illegalKeywordForThisVersion = true
        }
        if illegalKeywordForThisVersion {
            try? markInvalidKeywordForVersion( thisCompiler.currentToken.value,
                                               version: thisCompiler.xsltVersion,
                                               at: thisCompiler.currentToken.line,
                                               skip: .toNextKeyword )
        }
        return illegalKeywordForThisVersion
    }
}

