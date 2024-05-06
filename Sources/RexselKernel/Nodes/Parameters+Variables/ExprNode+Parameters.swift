//
//  ExprNode+Parameters.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 15/01/2024.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Syntax properties
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension TerminalSymbolEnum {

    static let parameterTokens: Set<TerminalSymbolEnum> = blockTokens

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension ParameterNode {

    func setSyntax() {
        // Set up the allowed syntax. Everything can occur zero or more.
        for keyword in TerminalSymbolEnum.parameterTokens {
            let entry = AllowableSyntaxEntryStruct( child: keyword, min: 0, max: Int.max )
            allowableChildrenDict[ keyword.description ] = entry
        }
    }

    func isInParameterTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return TerminalSymbolEnum.parameterTokens.contains(token)
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class ParameterNode: ExprNode {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Logging properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

#if HESTIA_LOGGING
    fileprivate var rLogger: RexselLogger!
#endif

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    ///  Value (when not derived from block)
    fileprivate var value: String = ""

    // Convenience variable
    fileprivate var isValueDefined: Bool {
        return value.isNotEmpty
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    override init() {
        super.init()
        exprNodeType = .parameter

        value = ""
        setSyntax()

#if HESTIA_LOGGING
        rLogger = RexselLogger()
#endif
   }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse parameter statement.

    override func parseSyntaxUsingCompiler( _ compiler: RexselKernel ) throws {

        defer {
#if HESTIA_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif
        }

        thisCompiler = compiler
        sourceLine = thisCompiler.currentToken.line

        isInBlock = false

        // Slide past keyword
        thisCompiler.tokenizedSourceIndex += 1

        while !thisCompiler.isEndOfFile {

#if HESTIA_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

            switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

                    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                    // Process valid material

                case ( .qname, .expression, _ ) where name.isEmpty :
                    name = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .qname, .terminal, _ ) where name.isEmpty && thisCompiler.nextToken.what != .openCurlyBracket :
                    name = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    return

                case ( .qname, .terminal, _ ) where name.isEmpty && thisCompiler.nextToken.what == .openCurlyBracket :
                    name = thisCompiler.currentToken.value
                    thisCompiler.nestedLevel += 1
                    isInBlock = true
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                case ( .expression, .terminal, _ ) where name.isNotEmpty && thisCompiler.nextToken.what != .openCurlyBracket :
                    value = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && isInBlock :
                    isInBlock = false
                    thisCompiler.nestedLevel -= 1
                    thisCompiler.tokenizedSourceIndex += 1
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Process block material

                case ( .terminal, _, _ ) where isInParameterTokens( thisCompiler.currentToken.what ) && isInBlock :
#if HESTIA_LOGGING
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

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Error conditions

                case ( .terminal, _, _ ) where name.isEmpty && thisCompiler.currentToken.what == .openCurlyBracket :
                    isInBlock = false
                    thisCompiler.nestedLevel += 1
                    try markMissingItemError( what: .name, inLine: thisCompiler.currentToken.line, after: exprNodeType.description )
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .terminal, _, _ ) where name.isEmpty && thisCompiler.currentToken.what != .openCurlyBracket :
                    isInBlock = false
                    try markMissingItemError( what: .name, inLine: thisCompiler.currentToken.line, after: exprNodeType.description )
                    return

                case ( .terminal, .terminal, _ ) where thisCompiler.currentToken.what == .openCurlyBracket &&
                                                       thisCompiler.nextToken.what == .closeCurlyBracket :
                    // Empty block (quasi valid)
                    try makeCannotHaveEmptyBlockError()
                    thisCompiler.tokenizedSourceIndex += 2
                    return

                case ( .expression, .terminal, _ ) where thisCompiler.nextToken.what == .openCurlyBracket :
                    value = thisCompiler.currentToken.value
                    isInBlock = true
                    thisCompiler.nestedLevel += 1
                    try markCannotHaveBothDefaultAndBlockError( where: sourceLine )
                    thisCompiler.tokenizedSourceIndex += 2
                   continue

                case ( .expression, _, _ ) :
                    try markExpectedNameError( after: exprNodeType.description,
                                               inLine: thisCompiler.currentToken.line,
                                               skip: .toNextkeyword)
                    return


                    
                case ( .qname, .terminal, _ ) where thisCompiler.nextToken.what == .openCurlyBracket :
                    // Valid so process block
                    name = thisCompiler.currentToken.value
                    isInBlock = true
                    thisCompiler.nestedLevel += 1
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                case ( .qname, _, _ ) :
                    // parameter name ( no expression or open bracket)
                    name = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    return


                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && isInBlock :
                    thisCompiler.nestedLevel -= 1
                    thisCompiler.tokenizedSourceIndex += 1
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    return

                default :
                    try markUnexpectedSymbolError( what: thisCompiler.currentToken.what, inElement: exprNodeType, inLine: sourceLine )
                    return
            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Perform semantic checks.

    override func buildSymbolTableAndSemanticChecks( allowedTokens tokenSet: Set<TerminalSymbolEnum> ) {

        variablesDict.title = exprNodeType.description
        variablesDict.blockLine = sourceLine

        super.buildSymbolTableAndSemanticChecks( allowedTokens: TerminalSymbolEnum.parameterTokens )

        // Set up the symbol table entries
        if let nodes = nodeChildren {
            for child in nodes {

                switch child.exprNodeType {

                    case .parameter, .variable, .function, .match:
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
    ///
    /// At this stage the check for duplicates will have been run
    /// so the tables, _variableDict_ should be populated for this node.

    override func checkVariableScope() {

        super.checkVariableScope()

        if let nodes = nodeChildren {
            scanForVariablesInBlock( nodes )
        } else {
            // In cases where there is no block only a value
            scanVariablesInNodeValue( value, inLine: sourceLine )
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
    ///     <xsl:param name="parameterName" select="optional default XPath value">
    ///        contents
    ///     </xsl:param>
    /// ```

    override func generate() -> String {
   
        let lineComment = super.generate()

        var attributes = " \(TerminalSymbolEnum.name.xml)=\"\(name)\""
        if value.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.select.xml)=\"\(value)\""
        }

        var contents = ""

        if let children = nodeChildren {
            for child in children {
                contents += " \(child.generate())\n"
            }
        }

        let thisElementName = "\(thisCompiler.xmlnsPrefix)\(exprNodeType.xml)"
        if contents.isEmpty {
            return "\(lineComment)<\(thisElementName) \(attributes)/>\n"
        } else {
            return "\(lineComment)<\(thisElementName) \(attributes)>\n\(contents)\n</\(thisElementName)>"
        }
   }

}
