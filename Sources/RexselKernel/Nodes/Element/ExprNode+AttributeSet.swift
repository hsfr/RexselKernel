//
//  ExprNode+AttributeSet.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 12/03/2024.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Syntax properties
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension TerminalSymbolEnum {

    static let attributeSetTokens: Set<TerminalSymbolEnum> = [.attrib]

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension AttributeSetNode {

    func setSyntax() {
        // Set up the allowed syntax. Everything can occur zero or more.
        for keyword in TerminalSymbolEnum.attributeSetTokens {
            let entry = AllowableSyntaxEntryStruct( child: keyword, min: 0, max: Int.max )
            allowableChildrenDict[ keyword.description ] = entry
        }
    }

    func isInAttributeSetTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return TerminalSymbolEnum.attributeSetTokens.contains(token)
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class AttributeSetNode: ExprNode  {

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

    ///  An associate namespace for this attribute.
    fileprivate var useAttributeSets: String = ""

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
        exprNodeType = .attributeSet

        name = ""
        useAttributeSets = ""
        isInBlock = false
        setSyntax()

#if REXSEL_LOGGING
        rLogger = RexselLogger()
#endif
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse variable statement.

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

        // Slide past keyword
        thisCompiler.tokenizedSourceIndex += 1

        while !thisCompiler.isEndOfFile {

            var node: ExprNode!

#if REXSEL_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

            switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

                // Valid constructions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                case ( .expression, _, _ ) where name.isEmpty && useAttributeSets.isEmpty :
                    name = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .terminal, .expression, _ ) where useAttributeSets.isEmpty && thisCompiler.currentToken.what == .useAttributeSets  :
                    useAttributeSets = thisCompiler.nextToken.value
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket && !isInBlock && name.isNotEmpty :
                    isInBlock = true
                    thisCompiler.nestedLevel += 1
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                // Process Block -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                case ( .terminal, _, _ ) where isInAttributeSetTokens( thisCompiler.currentToken.what ) && isInBlock:
#if REXSEL_LOGGING
                    rLogger.log( self, .debug, "Found \(thisCompiler.currentToken.value)" )
#endif
                    node = thisCompiler.currentToken.what.ExpreNodeClass
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

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && isInBlock :
                    thisCompiler.nestedLevel -= 1
                    thisCompiler.tokenizedSourceIndex += 1
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && !isInBlock :
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    return

                // Invalid constructions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                case ( .terminal, _, _ ) where !isInBlock && name.isNotEmpty:
                    // Mark error but assume there is a bracket.
                    try markMissingItemError( what: .openCurlyBracket,
                                              inLine: thisCompiler.currentToken.line,
                                              after: exprNodeType.description,
                                              skip: .toNextkeyword )
                    thisCompiler.nestedLevel += 1
                    isInBlock = true
                    continue

                case ( .terminal, _, _ ) where name.isEmpty && thisCompiler.currentToken.what == .openCurlyBracket :
                    try markMissingItemError( what: .name,
                                              inLine: thisCompiler.currentToken.line,
                                              after: exprNodeType.description,
                                              skip: .toNextkeyword )
                    thisCompiler.nestedLevel += 1
                    isInBlock = true
                    continue

                case ( .terminal, .terminal, _ ) where thisCompiler.currentToken.what == .useAttributeSets && thisCompiler.nextToken.what == .openCurlyBracket :
                    try markMissingItemError( what: .useAttributeSets,
                                              inLine: thisCompiler.currentToken.line,
                                              after: thisCompiler.currentToken.what.description,
                                              skip: .toNextkeyword )
                    thisCompiler.nestedLevel += 1
                    isInBlock = true
                    continue

                case ( .terminal, .terminal, _ ) where thisCompiler.currentToken.what == .openCurlyBracket && thisCompiler.nextToken.what == .closeCurlyBracket :
                    name = thisCompiler.currentToken.value
                    try makeCannotHaveEmptyBlockError( inLine: thisCompiler.currentToken.line )
                    thisCompiler.tokenizedSourceIndex += 2
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
    //
    /// Check duplicates etc.

    override func buildSymbolTableAndSemanticChecks( allowedTokens tokenSet: Set<TerminalSymbolEnum> ) {

        variablesDict.title = "attributeSet:\(name)"
        variablesDict.blockLine = sourceLine

      super.buildSymbolTableAndSemanticChecks( allowedTokens: TerminalSymbolEnum.attributeSetTokens )

        if let nodes = nodeChildren {
            for child in nodes {
                child.buildSymbolTableAndSemanticChecks()
            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check variable scoping in value.
    ///
    /// At this stage the check for duplicates will have been run
    /// so the tables, _variableDict_ should be populated for this node.

    override func checkVariableScope() {

        super.checkVariableScope()

        if let nodes = nodeChildren {
            scanForVariablesInBlock( nodes )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate stylesheet tag.
    ///
    /// Output is of the form
    /// ```xml
    ///     <xsl:attribute name="elementName" namespace="...">
    ///        contents
    ///     </xsl:attribute>
    /// ```

    override func generate() -> String {

        let lineComment = super.generate()

        var attributes = ""

        // This should always have a value, but it will be picked up by the parser.
        if name.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.name.xml)=\"\(name)\""
        }
        if useAttributeSets.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.useAttributeSets.xml)=\"\(useAttributeSets)\""
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
