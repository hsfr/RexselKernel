//
//  ExprNode+Stylesheet.swift
//  RexselKernel
//
//  Copyright (c) 2024 Hugh Field-Richards. All rights reserved.

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-* Formal Syntax Definition -*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension StylesheetNode {

    static let blockTokens: StylesheetTokensType = TerminalSymbolEnum.stylesheetTokens

    static let optionTokens: StylesheetTokensType = []

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Set up the syntax based on the BNF.
    ///
    /// Slightly crude way to do it but should suffice.
    ///
    /// ```xml
    ///     <stylesheet> ::= "stylesheet"
    ///                      "{"
    ///                           "version" <version number>
    ///                           ( "id" <name> )?
    ///                           <output>?
    ///                           (
    ///                             <name space def> |
    ///                             <attribute set> |
    ///                             <decimal format> |
    ///                             <exclude result prefixes> |
    ///                             <import> |
    ///                             <include> |
    ///                             <key> |
    ///                             <namespace alias> |
    ///                             <parameter> |
    ///                             <preserve space> |
    ///                             <script> |
    ///                             <strip space> |
    ///                             <variable> |
    ///                             <matcher> |
    ///                             <proc>
    ///                           )*
    ///                      "}"
    /// ```

    func setSyntax() {
        for keyword in StylesheetNode.optionTokens {
            optionsDict[ keyword ] = AllowableSyntaxEntryStruct( min: 0, max: 1 )
        }

        for keyword in StylesheetNode.blockTokens {
            childrenDict[ keyword ] = AllowableSyntaxEntryStruct( min: 0, max: Int.max )
        }
        childrenDict[ .id ] = AllowableSyntaxEntryStruct( min: 0, max: 1 )
        childrenDict[ .output ] = AllowableSyntaxEntryStruct( min: 0, max: 1 )
        childrenDict[ .version ] = AllowableSyntaxEntryStruct( min: 1, max: 1 )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check the syntax that was knput against that defined
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

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class StylesheetNode: ExprNode {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    public var xsltVersion: String = ""

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
        isLogging = false  // Adjust as required
        exprNodeType = .stylesheet
        isInBlock = false
        setSyntax()
        isRootNode = true
        xsltVersion = "1.0"
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
            if isLogging {
                rLogger.log( self, .debug, thisCompiler.currentTokenLog )
                rLogger.log( self, .debug, thisCompiler.nextTokenLog )
                rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
            }
        }

        thisCompiler = compiler
        sourceLine = thisCompiler.currentToken.line

        if isLogging {
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
        }

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

            if isLogging {
                rLogger.log( self, .debug, thisCompiler.currentTokenLog )
                rLogger.log( self, .debug, thisCompiler.nextTokenLog )
                rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
            }

            switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

                    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                    // Valid constructions

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket &&
                    thisCompiler.nextToken.what != .closeCurlyBracket :
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel += 1
                    isInBlock = true
                    continue

                    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                    // Process block material

                case ( .terminal, _, _ ) where isInChildrenTokens( thisCompiler.currentToken.what ) && isInBlock :
                    if isLogging {
                        rLogger.log( self, .debug, "Found \(thisCompiler.currentToken.value)" )
                    }

                    markIfInvalidKeywordForThisVersion( thisCompiler )

                    let node: ExprNode = thisCompiler.currentToken.what.ExpreNodeClass
                    if self.nodeChildren == nil {
                        self.nodeChildren = [ExprNode]()
                    }
                    nodeChildren.append( node )
                    node.parentNode = self

                    // Record this node's details for later analysis.
                    let nodeLine = thisCompiler.currentToken.line

                    if childrenDict[ thisCompiler.currentToken.what ]!.count == 0 {
                        childrenDict[ thisCompiler.currentToken.what ]!.defined = nodeLine
                    }
                    childrenDict[ thisCompiler.currentToken.what ]!.count += 1

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

                    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                    // Invalid constructions

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what != .openCurlyBracket && !isInBlock :
                    try markMissingItemError( what: .openCurlyBracket,
                                               inLine: thisCompiler.currentToken.line,
                                               skip: .ignore )
                    return

                case ( .terminal, .terminal, _ ) where thisCompiler.currentToken.what == .openCurlyBracket &&
                                                       thisCompiler.nextToken.what == .closeCurlyBracket :
                    // Empty block will also flag up version missing.
                    checkSyntax()
                    try makeCannotHaveEmptyBlockError( inLine: thisCompiler.currentToken.line,
                                                       skip: .toNextkeyword )
                    return

                case ( _, _, _ ) where !isInChildrenTokens( thisCompiler.currentToken.what ) :
                    // Reset nesting counter if leaving from within a block.
                    if isInBlock {
                        thisCompiler.nestedLevel += 1
                    }
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   insteadOf: tokensDescription( StylesheetNode.blockTokens ),
                                                   inElement: exprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .absorbBlock )
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                default :
                    try markUnexpectedSymbolError( what: thisCompiler.currentToken.what,
                                                   inElement: exprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
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

                    case .parameter, .variable, .proc, .match, .attributeSet, .key :
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
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check variable scoping.

    override func checkVariableScope( _ compiler: RexselKernel ) {
        if let nodes = nodeChildren {
            for child in nodes {
                child.checkVariableScope( compiler )
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
            if isLogging {
                rLogger.log( self, .debug, "Adding \(normalisedName) used in line number \(whereUsed+1) in local table for \(variablesDict.title)" )
            }
            return true
        }
        if isLogging {
            rLogger.log( self, .debug, "Could not find parameter/variable \(normalisedName) used in line number \(whereUsed+1)" )
        }
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
