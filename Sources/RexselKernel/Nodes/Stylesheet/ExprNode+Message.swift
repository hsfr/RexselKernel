//
//  ExprNode+Message.swift
//  RexselKernel
//
//  Copyright (c) 2024 Hugh Field-Richards. All rights reserved.

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Syntax properties
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
///
/// ```xml
///   <message> ::= "message" ( "terminate" "yes" | "no" ) ( "{" <contents> "}" )?
/// ```
///

extension TerminalSymbolEnum {

    static let messageTokens: Set<TerminalSymbolEnum> = blockTokens

    static let messageAttributeTokens: Set<TerminalSymbolEnum> = [
        .terminate
    ]


}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension MessageNode {

    func setSyntax() {
        // Set up the allowed syntax. Everything can occur zero or more.
        for keyword in TerminalSymbolEnum.messageTokens {
            let entry = AllowableSyntaxEntryStruct( child: keyword, min: 0, max: Int.max )
            allowableChildrenDict[ keyword.description ] = entry
        }
    }

    func isInMessageTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return TerminalSymbolEnum.messageTokens.contains(token)
    }

    func isInMessageAttributeTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return TerminalSymbolEnum.messageAttributeTokens.contains(token)
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class MessageNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    /// Terminate value
    var yesNoValue: YesNoEnum!

    /// Simple message value (no block).
    fileprivate var messageString: String = ""

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise Node base.

    override init() {
        super.init()
        thisExprNodeType = .message

        isInBlock = false
        yesNoValue = .no
        messageString = ""
        setSyntax()
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse message statement.
    ///
    /// - Parameters:
    ///   - compiler: the current instance of the compiler.
    /// - Throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    override func parseSyntaxUsingCompiler( _ compiler: RexselKernel ) throws {

        defer {
            name = "message"
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
                //
                // message "simple text"
                // message terminate yes|no "simple text"
                //
                // message { block }
                // message terminate yes|no { block }

                case ( .terminal, .terminal, _ ) where isInMessageAttributeTokens( thisCompiler.currentToken.what )
                                                    && thisCompiler.nextToken.what != .openCurlyBracket :
                    yesNoValue = YesNoEnum.translate( thisCompiler.nextToken.value )
                    if !( yesNoValue == .yes || yesNoValue == .no ) {
                        try? markUnknownValue( inElement: thisExprNodeType,
                                               found: thisCompiler.currentToken.value,
                                               insteadOf: "'yes' or 'no'",
                                               inLine: sourceLine )
                    }
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                case ( .expression, _, _ ) where messageString.isEmpty  :
                    messageString = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .terminal, _, _ ) where messageString.isEmpty && thisCompiler.currentToken.what == .openCurlyBracket  :
                    isInBlock = true
                    thisCompiler.nestedLevel += 1
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                // Process Block -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                case ( .terminal, _, _ ) where isInMessageTokens( thisCompiler.currentToken.what ) && isInBlock :
#if REXSEL_LOGGING
                    rLogger.log( self, .debug, "Found \(thisCompiler.currentToken.valueString)" )
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

                // End Conditions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                // End of simple pair with following statement.
                case ( .terminal, _, _ ) where isInBlockTemplateTokens( thisCompiler.currentToken.what )
                                            && messageString.isNotEmpty
                                            && nodeChildren == nil :
                    return

                // End of simple pair with following "}".
                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket
                                            && messageString.isNotEmpty
                                            && nodeChildren == nil :
                    return

                // End of block (whether or not it is valid since we parse block anyway)
                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket
                                            && isInBlock
                                            && nodeChildren != nil :
                    thisCompiler.nestedLevel -= 1
                    thisCompiler.tokenizedSourceIndex += 1
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Early end of file

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    // Don't bother to check. End of file here is an error anyway which
                    // will be picked up above this node. Almost certainly a brackets problem.
                    return

                // Invalid constructions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket
                                            && isInBlock
                                            && nodeChildren == nil :
                    thisCompiler.nestedLevel -= 1
                    try markDefaultAndBlockMissingError( inLine: thisCompiler.currentToken.line,
                                                         skip: .toNextkeyword )
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket
                                            && messageString.isNotEmpty :
                    try markCannotHaveBothDefaultAndBlockError( inLine: sourceLine )
                    thisCompiler.nestedLevel += 1
                    thisCompiler.tokenizedSourceIndex += 1
                    isInBlock = true
                    // Continue to parse block anyway
                    continue

                case ( .terminal, .terminal, _ ) where thisCompiler.currentToken.what == .terminate
                                                    && thisCompiler.nextToken.what != .openCurlyBracket :
                    name = thisCompiler.currentToken.value
                    try markUnexpectedSymbolError( found: thisCompiler.nextToken.value,
                                                   insteadOf: "yes|no value",
                                                   inElement: .attrib,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
                    return

                case ( .terminal, .expression, _ ) where thisCompiler.currentToken.what == .terminate :
                    try markUnexpectedSymbolError( found: thisCompiler.nextToken.value,
                                                   insteadOf: "yes|no value",
                                                   inElement: .attrib,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
                    continue

                case ( .terminal, .terminal, _ ) where thisCompiler.currentToken.what == .openCurlyBracket
                                                    && thisCompiler.nextToken.what == .closeCurlyBracket :
                    // Empty block!
                    try makeCannotHaveEmptyBlockError()
                    thisCompiler.tokenizedSourceIndex += 2
                    return

                default :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
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

        variablesDict.title = name
        variablesDict.blockLine = sourceLine

        super.buildSymbolTableAndSemanticChecks( allowedTokens: TerminalSymbolEnum.whenTokens )

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
    /// Check variable scoping.
    ///
    /// At this stage the check for duplicates will have been run
    /// so the tables, _variableDict_ should be populated for this node.
    ///
    /// This table (the root node) will be used throughout the
    /// stylesheet for checking within each local scope.

    override func checkVariableScope( _ compiler: RexselKernel ) {
        scanVariablesInNodeValue( yesNoValue.description, inLine: sourceLine )
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
    ///     <xsl:message temrinate="...">
    ///        contents
    ///     </xsl:message>
    /// ```

    override func generate() -> String {

        let lineComment = super.generate()

        var attributes = ""

        attributes = {
            if self.yesNoValue == .yes {
                return "\(TerminalSymbolEnum.terminate.xml)=\"\(self.yesNoValue.description)\""
            } else {
                return ""
            }
        }()

        var contents = ""

        if messageString.isNotEmpty {
            // We have to encase it in a text element
            let textElementName = "\(thisCompiler.xmlnsPrefix)\(TerminalSymbolEnum.text.xml)"
            contents = "<\(textElementName)>\(messageString)</\(textElementName)>"
        }

        // Overwrite if there is a block
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

