//
//  ExprNode+Parameters.swift
//  RexselKernel
//
//  Copyright 2024 Hugh Field-Richards. All rights reserved.

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-* Formal Syntax Definition -*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension VariableNode {

    static let blockTokens: TerminalSymbolEnumSetType = TerminalSymbolEnum.parameterTokens

    static let optionTokens: TerminalSymbolEnumSetType = [ ]

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class VariableNode: ExprNode {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    ///  Value (when not derived from block)
    fileprivate var expressionString: String = ""

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    override init() {
        super.init()
        thisExprNodeType = .variable
        isInBlock = false
        isLogging = false  // Adjust as required
        setSyntax( options: WithNode.optionTokens, elements: WithNode.blockTokens )
   }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Parsing/Generate Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse source (with tokens).
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

        isInBlock = false

        // Slide past keyword
        thisCompiler.tokenizedSourceIndex += 1

        while !thisCompiler.isEndOfFile {

            if isLogging {
                rLogger.log( self, .debug, thisCompiler.currentTokenLog )
                rLogger.log( self, .debug, thisCompiler.nextTokenLog )
                rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
            }

            switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Process valid material

                case ( .qname, .expression, _ ) where name.isEmpty &&
                                                      expressionString.isEmpty :
                    // Simple expression only. There may be an illegal block so
                    // do not exit yet.
                    name = thisCompiler.currentToken.value
                    expressionString = thisCompiler.nextToken.value
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                case ( .qname, .terminal, _ ) where name.isEmpty &&
                                                    thisCompiler.nextToken.what == .openCurlyBracket :
                    // Block start found (no simple expression).
                    name = thisCompiler.currentToken.value
                    isInBlock = true
                    thisCompiler.nestedLevel += 1
                    thisCompiler.tokenizedSourceIndex += 2
                    continue
                    
                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Process block material

                case ( .terminal, _, _ ) where isInChildrenTokens( thisCompiler.currentToken.what ) && isInBlock :
                    if isLogging {
                        rLogger.log( self, .debug, "Found \(thisCompiler.currentToken.value)" )
                    }

                    _ = markIfInvalidKeywordForThisVersion( thisCompiler )

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
                // Exit statement

                case ( _, _, _ ) where name.isNotEmpty &&
                    expressionString.isNotEmpty &&
                    thisCompiler.currentToken.what != .openCurlyBracket:
                    // Do not need to check syntax here (not a block)
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket
                    && isInBlock :
                    // End of block encountered but check for empty block.
                    checkSyntax()
                    thisCompiler.nestedLevel -= 1
                    thisCompiler.tokenizedSourceIndex += 1
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket :
                    // Found end of call with block.
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Early end of file

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    // Don't bother to check. End of file here is an error anyway which
                    // will be picked up above this node. Almost certainly a brackets problem.
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Invalid constructions

                    // No parameter name but following block
                case ( .terminal, _, _ ) where name.isEmpty && thisCompiler.currentToken.what == .openCurlyBracket :
                    isInBlock = true
                    thisCompiler.nestedLevel += 1
                    try markMissingItemError( what: .name,
                                              inLine: thisCompiler.currentToken.line,
                                              after: thisExprNodeType.description )
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                    // Found expression and block
                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket && expressionString.isNotEmpty :
                    expressionString = thisCompiler.currentToken.value
                    isInBlock = true
                    thisCompiler.nestedLevel += 1
                    try markCannotHaveBothDefaultAndBlockError( inLine: sourceLine, 
                                                                element: thisExprNodeType,
                                                                skip: .absorbBlock )
                    thisCompiler.tokenizedSourceIndex += 1
                    return

                case ( _, _, _ ) where !isInChildrenTokens( thisCompiler.currentToken.what ) :
                    if isInBlock {
                        thisCompiler.nestedLevel += 1
                    }
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   mightBe: WithNode.blockTokens,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .absorbBlock )
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .expression, _, _ ) where name.isEmpty :
                    try markExpectedNameError( after: thisExprNodeType.description,
                                               inLine: thisCompiler.currentToken.line,
                                               skip: .toNextKeyword)
                    return

                default :
                    // When all else fails throw back to parent.
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line  )
                    return
            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Syntax Setting/Checking
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Set up the syntax based on the BNF.
    ///
    /// ```xml
    ///   <variable> ::= ( "variable" | "constant" ) <qname>
    ///              (
    ///                 <default expression> |
    ///                 (
    ///                    "{"
    ///                       <block templates>+
    ///                    "}"
    ///                 )
    ///              )
    /// ```

    override func setSyntax( options optionsList: TerminalSymbolEnumSetType, elements elementsList: TerminalSymbolEnumSetType ) {
        super.setSyntax( options: optionsList, elements: elementsList )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check the syntax that was input against that defined
    /// in _setSyntax_. Any special reuirements are done here
    /// such as required combinations of keywords.

    override func checkSyntax()
    {
        super.checkSyntax()

        var blockElementFound = false
        for ( key, entry ) in childrenDict {
            if entry.count > 0 && key.description != TerminalSymbolEnum.parameter.description {
                blockElementFound = true
                break
            }
        }
        if blockElementFound && expressionString.isNotEmpty {
            try? markCannotHaveBothDefaultAndBlockError( inLine: sourceLine,
                                                         element: thisExprNodeType,
                                                         skip: .ignore )
        }
        if !blockElementFound && expressionString.isEmpty {
            try? markDefaultAndBlockMissingError( inLine: sourceLine, skip: .ignore )
        }

        var blockElementsPresent = false
        // Check that there are some block elements (other than parameters) declared.
        for ( key, entry ) in childrenDict {
            if entry.count > 0 && key.description != TerminalSymbolEnum.parameter.description {
                blockElementsPresent = true
                break
            }
        }
        if !blockElementsPresent {
            markSyntaxRequiresOneOrMoreElement( inLine: sourceLine,
                                                name: tokensDescription( TerminalSymbolEnum.blockTokens ),
                                                inElement: self.thisExprNodeType.description )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Perform semantic checks.

    override func buildSymbolTableAndSemanticChecks( allowedTokens tokenSet: Set<TerminalSymbolEnum> ) {

        variablesDict.title = name
        variablesDict.tableType = thisExprNodeType
        variablesDict.blockLine = sourceLine

        super.buildSymbolTableAndSemanticChecks( allowedTokens: TerminalSymbolEnum.parameterTokens )

        // Set up the symbol table entries
        if let nodes = nodeChildren {
            for child in nodes {

                switch child.thisExprNodeType {

                    case .variable, .proc, .match:
                        do {
                            try variablesDict.addSymbol( name: child.name,
                                                         type: child.thisExprNodeType,
                                                         declaredInLine: child.sourceLine,
                                                         scope: variablesDict.title )
                            currentVariableContextList += [variablesDict]
                        } catch let err as SymbolTableError {
                            // Already in list so mark duplicate error
                            try? markDuplicateError( symbol: err.name,
                                                     declaredIn: err.declaredLine,
                                                     preciouslDelaredIn: err.previouslyDeclaredIn,
                                                     skip: .ignore )
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
    ///
    /// At this stage the check for duplicates will have been run
    /// so the tables, _variableDict_ should be populated for this node.
    ///
    /// This table (the root node) will be used throughout the
    /// stylesheet for checking within each local scope.

    override func checkVariableScope( _ compiler: RexselKernel ) {
        scanVariablesInNodeValue( expressionString, inLine: sourceLine )

        if let nodes = nodeChildren {
            scanForVariablesInBlock( compiler, nodes )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate stylesheet tag.
    ///
    /// Output is of the form, but note that having a default value
    /// and a contents is ambiguous but not forbidden.
    /// ```xml
    ///     <xsl:variable name="variableName" select="optional default XPath value">
    ///        contents
    ///     </xsl:param>
    /// ```

    override func generate() -> String {

        let lineComment = super.generate()

        var attributes = " \(TerminalSymbolEnum.name.xml)=\"\(name)\""
        if expressionString.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.select.xml)=\"\(expressionString)\""
        }

        var contents = ""
        if let children = nodeChildren {
            for child in children {
                contents += " \(child.generate())\n"
            }
        }

        let thisElementName = "\(thisCompiler.xmlnsPrefix)\(thisExprNodeType.xml)"
        if contents.isEmpty {
            return "\(lineComment)<\(thisElementName) \(attributes)/>\n"
        } else {
            return "\(lineComment)<\(thisElementName) \(attributes)>\n\(contents)\n</\(thisElementName)>"
        }
    }

}
