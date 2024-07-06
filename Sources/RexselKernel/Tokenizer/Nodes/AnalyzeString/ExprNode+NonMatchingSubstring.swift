//
//  ExprNode+NonMatchingSubstring.swift
//  RexselKernel
//
//  Created by Hugh Field-Richards on 06/07/2024.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//
// This is where the formal syntax is declared.

extension NonMatchingSubstringNode {

    static let tokens: StylesheetTokensType = TerminalSymbolEnum.blockTokens

    static let optionTokens: StylesheetTokensType = []

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Set up the syntax based on the BNF.
    ///
    /// Slightly crude way to do it but should suffice.
    ///
    /// ```xml
    ///   <non-matching-substring> ::= <bloclTokens>+
    /// ```

    func setSyntax() {
        for keyword in AnalyzeStringNode.optionTokens {
            optionsDict[ keyword ] = AllowableSyntaxEntryStruct( min: 0, max: 1 )
        }
        // Modify as necessary
        optionsDict[ .regex ] = AllowableSyntaxEntryStruct( min: 1, max: 1 )

        for keyword in AnalyzeStringNode.tokens {
            childrenDict[ keyword ] = AllowableSyntaxEntryStruct( min: 0, max: 1 )
        }
        // Modify as necessary
        childrenDict[ .fallback ] = AllowableSyntaxEntryStruct( min: 0, max: Int.max )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Helper function to detect valid block tokens.

    func isInBlockTokens( _ token: TerminalSymbolEnum ) -> Bool {
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

    func checkSyntax()
    {
        for ( keyword, entry ) in optionsDict {
            checkOccurances( entry.count,
                             min: entry.min, max: entry.max,
                             name: keyword.description,
                             inKeyword: thisCompiler.currentToken.value )
        }
        for ( keyword, entry ) in childrenDict {
            checkOccurances( entry.count,
                             min: entry.min, max: entry.max,
                             name: keyword.description,
                             inKeyword: thisCompiler.currentToken.value )
        }
        if childrenDict[ .matchingSubstring ]!.count == 0 && childrenDict[ .nonMatchingSubstring ]!.count == 0 {
            markMustHaveAtLeastOneOfElements(inLine: thisCompiler.currentToken.line,
                                             names: [ childrenDict[ .matchingSubstring ]!.value,
                                                      childrenDict[ .nonMatchingSubstring ]!.value ],
                                             inElement: thisCompiler.currentToken.value )
        }
    }
}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-* Version 2.0 and above *-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class NonMatchingSubstringNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    fileprivate var string: String = ""

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise Node base.

    override init()
    {
        super.init()
        exprNodeType = .nonMatchingSubstring
        string = ""

        setSyntax()
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Parse Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse match statement.

    override func parseSyntaxUsingCompiler( _ compiler: RexselKernel ) throws {

        defer {
            name = "\(exprNodeType.description)[\(thisCompiler.currentToken.line)]"
#if REXSEL_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif
        }

        thisCompiler = compiler
        sourceLine = thisCompiler.currentToken.line

#if REXSEL_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

        thisCompiler.tokenizedSourceIndex += 1

        while !thisCompiler.isEndOfFile {

#if REXSEL_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

            switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

                // Valid constructions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                case ( .expression, .terminal, _ ) where string.isEmpty &&
                                                         isInOptionTokens( thisCompiler.nextToken.what ) :
                    string = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .terminal, .expression, _ ) where isInOptionTokens( thisCompiler.currentToken.what ) :
                    optionsDict[ thisCompiler.currentToken.what ]?.value = thisCompiler.nextToken.value
                    if optionsDict[ thisCompiler.currentToken.what ]?.count == 0 {
                        optionsDict[ thisCompiler.currentToken.what ]?.defined = thisCompiler.currentToken.line
                    }
                    optionsDict[ thisCompiler.currentToken.what ]?.count += 1
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                case ( .terminal, .terminal, _ ) where thisCompiler.currentToken.what == .openCurlyBracket &&
                                                       thisCompiler.nextToken.what != .closeCurlyBracket :
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel += 1
                    isInBlock = true
                    continue

                // Process block -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                case ( .terminal, _, _ ) where isInBlockTokens( thisCompiler.currentToken.what ) && isInBlock :
#if REXSEL_LOGGING
                    rLogger.log( self, .debug, "Found \(thisCompiler.currentToken.value)" )
#endif
                    if !isTokenValidForThisVersion( thisCompiler.currentToken.what ) {
                        markInvalidKeywordForVersion( thisCompiler.currentToken.value,
                                                      version: thisCompiler.xsltVersion,
                                                      at: thisCompiler.currentToken.line)
                    }

                    let node: ExprNode = thisCompiler.currentToken.what.ExpreNodeClass
                    if self.nodeChildren == nil {
                        self.nodeChildren = [ExprNode]()
                    }
                    nodeChildren.append( node )
                    node.parentNode = self

                    // Record this node's details for later analysis.
                    // let nodeName = node.exprNodeType.description
                    let nodeLine = thisCompiler.currentToken.line

                    childrenDict[ thisCompiler.currentToken.what ]!.count += 1

                    if childrenDict[ node.exprNodeType ]!.count == 0 {
                        childrenDict[ node.exprNodeType ]!.defined = nodeLine
                    }
                    childrenDict[ node.exprNodeType ]!.count += 1

                    try node.parseSyntaxUsingCompiler( thisCompiler )
                    continue

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Exit block

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && isInBlock :
                    // Before exiting we must carry out checks
                    checkSyntax()
                    isInBlock = false
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel -= 1
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Early end of file

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    return

                // Invalid constructions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                case ( .terminal, .terminal, _ ) where thisCompiler.currentToken.what == .openCurlyBracket &&
                                                       thisCompiler.nextToken.what == .closeCurlyBracket :
                    try makeCannotHaveEmptyBlockError( inLine: thisCompiler.currentToken.line,
                                                       skip: .toNextkeyword )
                    return

                default :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   inElement: exprNodeType,
                                                   inLine: thisCompiler.currentToken.line )
                    return

            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Semantic Checking and Symbol Table Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    ///
    /// Only variable names are checked here. The variables
    /// list (_VariablesDict_) has already been formed, but no
    /// where used yet.

    override func buildSymbolTableAndSemanticChecks( allowedTokens tokenSet: Set<TerminalSymbolEnum> ) {

        variablesDict.title = "\(exprNodeType.description)[\(thisCompiler.currentToken.line)]"
        variablesDict.blockLine = sourceLine

        super.buildSymbolTableAndSemanticChecks( allowedTokens: TerminalSymbolEnum.matchTokens )

        // Check for parameter having to be first
        if let nodes = nodeChildren {
            var nonParameterFound = false
            for child in nodes {
                if child.exprNodeType != .parameter {
                    nonParameterFound = true
                }
                if nonParameterFound && child.exprNodeType == .parameter {
                    markParameterMustBeAtStartOfBlock( name: child.name,
                                                       within: "\(variablesDict.title)",
                                                       at: child.sourceLine )
                }
            }
        }

        // Set up the symbol table entries
        if let nodes = nodeChildren {
            for child in nodes {

                switch child.exprNodeType {

                    case .parameter, .variable :
                        do {
                            try variablesDict.addSymbol( name: child.name,
                                                         type: child.exprNodeType,
                                                         declaredInLine: child.sourceLine,
                                                         scope: variablesDict.title )
                            currentVariableContextList += [variablesDict]
                        } catch let err as RexselErrorData {
                            // Already in list so mark duplicate error
                            thisCompiler.rexselErrorList.add( err )
                        } catch {
                            thisCompiler.rexselErrorList.add(
                                RexselErrorData.init( kind: RexselErrorKind
                                    .unknownError( lineNumber: child.sourceLine+1,
                                                   message: "Unknown error with adding \"\(child.name)\" to symbol table") ) )
                        }

                    default :
                        ()
                }
                child.buildSymbolTableAndSemanticChecks()
            }
        }

        // Special checks go here

    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check variable scoping.
    ///
    /// At this stage the check for duplicates will have been run
    /// so the tables, _variableDict_ should be populated for this node.
    ///
    /// - Parameters:
    ///   - compiler: the current compiler for this stylesheet.

    override func checkVariableScope( _ compiler: RexselKernel ) {
        if let nodes = nodeChildren {
            scanForVariablesInBlock( compiler, nodes )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate a list of symbols for this node.
    ///
    /// - Returns: Symbol table for this node as string.

    override func symbolListing() -> String {
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
    // MARK: - Generation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate tag.
    ///
    /// - Returns: XSLT equivalent of node.

    override func generate() -> String {

        let lineComment = super.generate()

        var contents = ""

        if let children = nodeChildren {
            for child in children {
                contents += " \(child.generate())\n"
            }
        }

        let thisElementName = "\(thisCompiler.xmlnsPrefix)\(exprNodeType.xml)"
        if contents.isEmpty {
            return "\(lineComment)<\(thisElementName)/>\n"
        } else {
            return "\(lineComment)<\(thisElementName)>\n\(contents)\n</\(thisElementName)>"
        }
    }
}
