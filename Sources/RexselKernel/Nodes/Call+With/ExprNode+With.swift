//
//  ExprNode+With.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 18/01/2024.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Syntax properties
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//
/// ```xml
///   <with> ::= "with" <with name> <default value>?
///                      ( "{" <contents> "}" )?
/// ```

extension TerminalSymbolEnum {

    static let withTokens: Set<TerminalSymbolEnum> = blockTokens

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension WithNode {

    func setSyntax() {
        // Set up the allowed syntax. Everything can occur zero or more.
        for keyword in TerminalSymbolEnum.withTokens {
            let entry = AllowableSyntaxEntryStruct( child: keyword, min: 0, max: Int.max )
            allowableChildrenDict[ keyword.description ] = entry
        }
    }

    func isInWithTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return TerminalSymbolEnum.withTokens.contains(token)
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class WithNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Logging properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

#if REXSEL_LOGGING
    fileprivate var rLogger: RexselLogger!
#endif

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    /// Default for this parameter.
    ///
    /// To be used when nothing passed to parameter
    fileprivate var select: String = ""

    // Convenience variable
    fileprivate var isDefaultDefined = false

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise Node base.

    override init() {
        super.init()
        exprNodeType = .with

        name = ""
        select = ""
        isDefaultDefined = false
        isInBlock = false

        setSyntax()

#if REXSEL_LOGGING
        rLogger = RexselLogger()
#endif
   }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse with statement.
    ///

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

        isDefaultDefined = false

        // Slide past keyword
        thisCompiler.tokenizedSourceIndex += 1

        while !thisCompiler.isEndOfFile {

#if REXSEL_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

            switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Valid constructions

                case ( .qname, _, _ ) where name.isEmpty && select.isEmpty :
                    name = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .expression, _, _ ) where name.isNotEmpty && select.isEmpty :
                    select = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .with
                                            && name.isNotEmpty
                                            && select.isNotEmpty :
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket
                                            && name.isNotEmpty
                                            && select.isEmpty  :
                    isInBlock = true
                    thisCompiler.nestedLevel += 1
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Process Block

                case ( .terminal, _, _ ) where isInWithTokens( thisCompiler.currentToken.what ) && isInBlock :
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

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // End Conditions

                // End of simple pair with following statement.
                case ( .terminal, _, _ ) where isInBlockTemplateTokens( thisCompiler.currentToken.what )
                                            && name.isNotEmpty 
                                            && select.isNotEmpty
                                            && nodeChildren == nil :
                    return

                // End of simple pair with following "}".
                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket
                                            && name.isNotEmpty 
                                            && select.isNotEmpty
                                            && nodeChildren == nil :
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket
                                            && isInBlock :
                    thisCompiler.nestedLevel -= 1
                    thisCompiler.tokenizedSourceIndex += 1
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Early end of file

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    // Don't bother to check. End of file here is an error anyway which
                    // will be picked up above this node. Almost certainly a brackets problem.
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Invalid constructions

                // No contents in block
                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket 
                                            && isInBlock
                                            && nodeChildren == nil :
                    thisCompiler.nestedLevel -= 1
                    try markDefaultAndBlockMissingError( where: thisCompiler.currentToken.line,
                                                         skip: .toNextkeyword )
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket
                                            && name.isNotEmpty
                                            && select.isNotEmpty :
                    try markCannotHaveBothDefaultAndBlockError( where: sourceLine )
                    thisCompiler.nestedLevel += 1
                    thisCompiler.tokenizedSourceIndex += 1
                    isInBlock = true
                    // Continue to parse block anyway
                    continue

                case ( .expression, .terminal, _ ) where thisCompiler.nextToken.what != .openCurlyBracket :
                    name = thisCompiler.currentToken.value
                    try markUnexpectedSymbolError( found: thisCompiler.nextToken.value,
                                                   insteadOf: "with value",
                                                   inElement: .attrib,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
                    return

                case ( .expression, .qname, _ ) :
                    name = thisCompiler.currentToken.value
                    try markUnexpectedSymbolError( found: thisCompiler.nextToken.value,
                                                   insteadOf: "with value",
                                                   inElement: .attrib,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
                    return

                case ( .terminal, .terminal, _ ) where thisCompiler.currentToken.what == .openCurlyBracket
                                                    && thisCompiler.nextToken.what == .closeCurlyBracket :
                    name = thisCompiler.currentToken.value
                    try makeCannotHaveEmptyBlockError()
                    thisCompiler.tokenizedSourceIndex += 2
                    return

                default :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   inElement: exprNodeType,
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

        variablesDict.title = exprNodeType.description
        variablesDict.blockLine = sourceLine

        super.buildSymbolTableAndSemanticChecks( allowedTokens: TerminalSymbolEnum.whenTokens )

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

    override func checkVariableScope() {

        super.checkVariableScope()

        scanVariablesInNodeValue( select, inLine: sourceLine )

        if let nodes = nodeChildren {
            scanForVariablesInBlock( nodes )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate stylesheet tag.
    ///
    /// Output is of the form, but note that having a default value
    /// and a contents is ambiguous but not forbidden.
    ///
    /// ```xml
    ///     <xsl:param name="withName" select="optional default XPath value">
    ///        contents
    ///     </xsl:param>
    /// ```

    override func generate() -> String {

        _ = super.generate()

        var attributes = " \(TerminalSymbolEnum.name.xml)=\"\(name)\""
        if select.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.select.xml)=\"\(select)\""
        }
        var contents = ""

        if let children = nodeChildren {
            for child in children {
                contents += " \(child.generate())\n"
            }
        }

        let thisElementName = "\(thisCompiler.xmlnsPrefix)\(exprNodeType.xml)"
        if contents.isEmpty {
            return "<\(thisElementName) \(attributes)/>\n"
        } else {
            return "<\(thisElementName) \(attributes)>\n\(contents)\n</\(thisElementName)>"
        }
    }

}
