//
//  ExprNode+Stylesheet.swift
//  RexselKernel
//
//  Copyright (c) 2024 Hugh Field-Richards. All rights reserved.

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Syntax properties
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension TerminalSymbolEnum {

    // Convenience for error messaging
    static var stylesheetTokensDescription: String {
        var returnString = ""
        for token in TerminalSymbolEnum.stylesheetTokens {
            returnString += "'\(token.description)',"
        }
        // Remove end comma
        _ = returnString.removeLast()
        return returnString
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension StylesheetNode {

    func setSyntax() {
        // Set up the allowed syntax. Set the min max as default.
        for keyword in TerminalSymbolEnum.stylesheetTokens {
            let entry = AllowableSyntaxEntryStruct( child: keyword, min: 0, max: 1 )
            allowableChildrenDict[ keyword.description ] = entry
        }

        // Set the specific entries (0 or more)
        allowableChildrenDict[ TerminalSymbolEnum.xmlns.description ]?.max = Int.max
        allowableChildrenDict[ TerminalSymbolEnum.parameter.description ]?.max = Int.max
        allowableChildrenDict[ TerminalSymbolEnum.variable.description ]?.max = Int.max
        allowableChildrenDict[ TerminalSymbolEnum.function.description ]?.max = Int.max
        allowableChildrenDict[ TerminalSymbolEnum.match.description ]?.max = Int.max
        allowableChildrenDict[ TerminalSymbolEnum.key.description ]?.max = Int.max
        allowableChildrenDict[ TerminalSymbolEnum.includeSheet.description ]?.max = Int.max
        allowableChildrenDict[ TerminalSymbolEnum.attributeSet.description ]?.max = Int.max

        // Required entry
        allowableChildrenDict[ TerminalSymbolEnum.version.description ]?.min = 1
    }

    func isInStyleSheetTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return TerminalSymbolEnum.stylesheetTokens.contains(token)
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class StylesheetNode: ExprNode {

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
        exprNodeType = .stylesheet
        isInBlock = false
        setSyntax()
        isRootNode = true
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse stylesheet statement.
    ///
    /// - Parameters:
    ///   - compiler: the current instance of the compiler.
    /// - Throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    override func parseSyntaxUsingCompiler( _ compiler: RexselKernel ) throws {

        defer {
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

        // Slide past keyword
        thisCompiler.tokenizedSourceIndex += 1

        // Insurance!
        var totalTokens = thisCompiler.totalNumberOfTokens

        // Special case to make sure correct error is flagged.
        guard !thisCompiler.isEndOfFile else {
            try? markMissingItemError( what: .openCurlyBracket, inLine: thisCompiler.currentToken.line, skip: .ignore )
            return
        }

        while !thisCompiler.isEndOfFile {

            totalTokens -= 1
      
            // Necessary to stop endless parse loop
            guard totalTokens > 0 else {
                return
            }

#if REXSEL_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

            switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Process brackets

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket :
                    isInBlock = true
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel += 1
                    continue

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what != .openCurlyBracket && !isInBlock :
                    try? markMissingItemError( what: .openCurlyBracket, inLine: thisCompiler.currentToken.line, skip: .ignore )
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && isInBlock :
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel -= 1
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Early end of file

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    // Don't bother to check. End of file here is an error anyway which
                    // will be picked up above this node. Almost certainly a brackets problem.
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Process block material

                case ( .terminal, _, _ ) where isInStyleSheetTokens( thisCompiler.currentToken.what ) && isInBlock :
#if REXSEL_LOGGING
                    rLogger.log( self, .debug, "Found \(thisCompiler.currentToken.value)" )
#endif
                    let node: ExprNode = thisCompiler.currentToken.what.ExpreNodeClass
                    if self.nodeChildren == nil {
                        self.nodeChildren = [ExprNode]()
                    }
                    nodeChildren.append( node )
                    node.parentNode = self

                    // Record this node's details for later analysis.
                    let nodeName = node.exprNodeType.description
                    let nodeLine = thisCompiler.currentToken.line

                    // The entry must exist as it was set up in the init using isInOutputTokens
                    if allowableChildrenDict[ nodeName ]!.count == 0 {
                        allowableChildrenDict[ nodeName ]!.defined = nodeLine
                    }
                    allowableChildrenDict[ nodeName ]!.count += 1

                    try node.parseSyntaxUsingCompiler( thisCompiler )
                    continue

                // Invalid constructions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                case ( .terminal, _, _ ) where !isInStyleSheetTokens( thisCompiler.currentToken.what ) :
                    // Illegal keyword (function, match, etc.)
                    // Reset nesting counter since we are already in a stylesheet block.
                    if isInBlock {
                        thisCompiler.nestedLevel -= 1
                    }
                    try markUnexpectedSymbolError( what: thisCompiler.currentToken.what,
                                                   inElement: exprNodeType,
                                                   inLine: sourceLine )
                    // Exit to continue processing at a higher level
                    return


                case ( .expression, _, _ ) where isInBlock :
                    fallthrough

                case ( .qname, _, _ ) where isInBlock :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   insteadOf: TerminalSymbolEnum.stylesheetTokensDescription,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
                    continue

                case ( .qname, .expression, _ ) where !isInBlock :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   insteadOf: TerminalSymbolEnum.stylesheetTokensDescription,
                                                   inLine: thisCompiler.currentToken.line )
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .qname, _, _ ) where !isInBlock :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   insteadOf: TerminalSymbolEnum.stylesheetTokensDescription,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
                    continue

                default :
                    try markUnexpectedSymbolError( what: thisCompiler.currentToken.what,
                                                   inElement: exprNodeType,
                                                   inLine: thisCompiler.currentToken.line )
                    continue

            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Perform semantic checks.

    override func buildSymbolTableAndSemanticChecks( allowedTokens tokenSet: Set<TerminalSymbolEnum> = [] ) {

        variablesDict.title = exprNodeType.description
        variablesDict.blockLine = sourceLine

        super.buildSymbolTableAndSemanticChecks( allowedTokens: TerminalSymbolEnum.stylesheetTokens )

        // Set up the symbol table entries
        if let nodes = nodeChildren {
            for child in nodes {

                switch child.exprNodeType {

                    case .parameter, .variable, .function, .match, .attributeSet, .key :
                        do {
                            try variablesDict.addSymbol( name: child.name,
                                                         type: child.exprNodeType,
                                                         declaredInLine: child.sourceLine,
                                                         scope: variablesDict.title )
                            currentVariableContextList += [variablesDict]
                        } catch let err as SymbolTableError {
                            let currentLine = err.newLine
                            let existingLine = err.declaredLine
                            let symbol = err.name

                            // Test to make sure that is a valid symbol, not just a blcnk which
                            // can happen with some consequential errors.
                            if symbol.isNotEmpty {
                                // Already in list so mark duplicate error
                                thisCompiler.rexselErrorList.add(
                                    RexselErrorData.init( kind: RexselErrorKind
                                        .duplicateSymbol( lineNumber: currentLine+1,
                                                          name: symbol,
                                                          where: existingLine+1 ) ) )
                            }
                        } catch {
                            thisCompiler.rexselErrorList.add(
                                RexselErrorData.init( kind: RexselErrorKind
                                    .unknownError(lineNumber: child.sourceLine+1, message: "Unknown error with adding \"\(child.name)\" to symbol table") ) )
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

    override func checkVariableScope() {

        super.checkVariableScope()

        if let nodes = nodeChildren {
            for child in nodes {
                child.checkVariableScope()
            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Is variable in this context?
    ///
    /// If not in the context then will return false (which
    /// indicates variable not in scope). Since this is at
    /// the root level no further action needs to be taken.
    ///
    /// If the variable has not been found by here then an
    /// error is raised.
    ///
    /// - Parameters:
    ///   - normalisedName: the variable name (without leading $).
    ///   - whereUsed: the lione where this variable is being used (not defined).
    /// - Returns: _true_ if variable found.

    override func doesContextContainVariable( _ normalisedName: String, line whereUsed: Int ) -> Bool {
        if variablesDict.isNameDeclared( normalisedName ) {
            variablesDict.addNameToUsedList( normalisedName, inLine: whereUsed )
#if REXSEL_LOGGING
            rLogger.log( self, .debug, "Adding \(normalisedName) used in line number \(whereUsed+1) in local table for \(variablesDict.title)" )
#endif
            return true
        }
#if REXSEL_LOGGING
        rLogger.log( self, .debug, "Could not find parameter/variable \(normalisedName) used in line number \(whereUsed+1)" )
#endif
        markCouldNotFindXPathVariableError( normalisedName, at: whereUsed )
        return false
    }


    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate a list of symbols for this node.

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
    //
    /// Generate stylesheet tag.
    ///
    /// Output depends whether there is content or not (the former
    /// is unlikely. Without content the output is
    /// ```xml
    ///     <xsl:stylesheet version="1.0" .../>
    /// ```
    /// With contents the output is
    /// ```xml
    ///     <xsl:stylesheet version="1.0" ...>
    ///        contents
    ///     </xsl:stylesheet>
    /// ```
    ///
    /// - Returns: Line number XML comment.

    override func generate() -> String {

        _ = super.generate()
        var contents = ""
        var attributes = thisCompiler.xsltNamespace

        if let nodes = nodeChildren {
            for child in nodes {

                switch child.exprNodeType {
                    case .xmlns, .version, .id, .excludeResultPrefixes :
                        attributes += " \(child.generate())"

                    default :
                        contents += " \(child.generate())\n"
                }
            }
        }

        if contents.isEmpty {
            return "<\(thisCompiler.xmlnsPrefix)\(exprNodeType.xml) \(attributes)/>\n"
        } else {
            return "<\(thisCompiler.xmlnsPrefix)\(exprNodeType.xml) \(attributes)>\n\(contents)\n</\(thisCompiler.xmlnsPrefix)\(exprNodeType.xml)>"
        }
    }


}
