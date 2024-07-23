//
//  ExprNode+ProcessingInstruction.swift
//  RexselKernel
//
//  Copyright 2024 Hugh Field-Richards. All rights reserved.

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Syntax properties
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
///
/// ```xml
///   <processingInstruction> ::= "processingInstruction" ( "{" <contents> "}" )?
/// ```

extension TerminalSymbolEnum {

    static let processingInstructionTokens: Set<TerminalSymbolEnum> = blockTokens

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension ProcessingInstructionNode {

    func setSyntax() {
        // Set up the allowed syntax. Everything can occur zero or more.
        for keyword in TerminalSymbolEnum.processingInstructionTokens {
            let entry = AllowableSyntaxEntryStruct( child: keyword, min: 0, max: Int.max )
            allowableChildrenDict[ keyword.description ] = entry
        }
    }

    func isInProcessingInstructionTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return TerminalSymbolEnum.processingInstructionTokens.contains(token)
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class ProcessingInstructionNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise Node base.

    override init() {
        super.init()
        thisExprNodeType = .processingInstruction

        isInBlock = false
        setSyntax()
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse processing instruction statement.
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

        while !thisCompiler.isEndOfFile {
#if REXSEL_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

            switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

               // Valid constructions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket && name.isNotEmpty :
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel += 1
                    isInBlock = true
                    continue

               case ( .expression, .terminal, _ ) where thisCompiler.nextToken.what == .openCurlyBracket  :
                    name = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .terminal, _, _ ) where isInBlockTemplateTokens( thisCompiler.currentToken.what ) && isInBlock :
#if REXSEL_LOGGING
                    rLogger.log( self, .debug, "Found \(thisCompiler.currentToken.expressionString)" )
#endif
                    let node: ExprNode = thisCompiler.currentToken.what.ExpreNodeClass
                    if self.nodeChildren == nil {
                        self.nodeChildren = [ExprNode]()
                    }
                    nodeChildren.append( node )
                    node.parentNode = self

                    // Record this node's details for later analysis.
                    let nodeName = node.thisExprNodeType.description
                    let nodeLine = thisCompiler.currentToken.line

                    // The entry must exist as it was set up in the init using isInOutputTokens
                    if allowableChildrenDict[ nodeName ]!.count == 0 {
                        allowableChildrenDict[ nodeName ]!.defined = nodeLine
                    }
                    allowableChildrenDict[ nodeName ]!.count += 1

                    try node.parseSyntaxUsingCompiler( thisCompiler )
                    continue

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket :
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel -= 1
                    return

                    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                    // Early end of file

                    case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                        // Don't bother to check. End of file here is an error anyway which
                        // will be picked up above this node. Almost certainly a brackets problem.
                        return


                // Invalid constructions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                case ( .expression, .terminal, _ ) where isInBlockTemplateTokens( thisCompiler.nextToken.what )  :
                     name = thisCompiler.currentToken.value
                    // Assume an open bracket
                     thisCompiler.tokenizedSourceIndex += 1
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   insteadOf: TerminalSymbolEnum.openCurlyBracket.description,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line )
                     continue

              case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket && name.isEmpty :
                    try markMissingItemError( what: .name,
                                              inLine: thisCompiler.currentToken.line,
                                              after: thisExprNodeType.description )
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel += 1
                    // Assume that we have found name so set up to parse block
                    isInBlock = true
                    continue

                case ( .terminal, _, _ ) where !isInBlockTemplateTokens( thisCompiler.currentToken.what ) :
                    // Illegal keyword (proc, match, etc.)
                    // Reset nesting counter if leaving from within a block.
                    if isInBlock {
                        thisCompiler.nestedLevel += 1
                    }
                    try markUnexpectedSymbolError( what: thisCompiler.currentToken.what,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line )
                    // Exit to continue processing at a higher level
                    return

                default :
                    try markUnexpectedSymbolError( what: thisCompiler.currentToken.what,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
                    return

            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check duplicates.
    ///
    /// Only variable names are checked here. The variables
    /// list (_VariablesDict_) has already been formed, but no
    /// where used yet.

    override func buildSymbolTableAndSemanticChecks( allowedTokens tokenSet: Set<TerminalSymbolEnum> ) {

        variablesDict.title = ""
        variablesDict.tableType = thisExprNodeType
        variablesDict.blockLine = sourceLine

        super.buildSymbolTableAndSemanticChecks( allowedTokens: TerminalSymbolEnum.blockTokens )

        // Set up the symbol table entries
        if let nodes = nodeChildren {
            for child in nodes {

                switch child.thisExprNodeType {

                    case .parameter, .variable :
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
                                    .unknownError(lineNumber: child.sourceLine+1,
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
    /// Check variable scoping in value.
    ///
    /// At this stage the check for duplicates will have been run
    /// so the tables, _variableDict_ should be populated for this node.

    override func checkVariableScope( _ compiler: RexselKernel ) {
        if let nodes = nodeChildren {
            scanForVariablesInBlock( compiler, nodes )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate tag.
    ///
    /// ```xml
    ///     <xsl:processingInstruction>
    ///        contents
    ///     </xsl:processingInstruction>
    /// ```

    override func generate() -> String {

        let lineComment = super.generate()

        let attributes = "\(TerminalSymbolEnum.name.xml)=\"\(name)\""
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
