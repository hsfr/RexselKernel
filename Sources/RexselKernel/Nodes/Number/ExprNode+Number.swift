//
//  ExprNode+Number.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 24/04/2024.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Syntax properties
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension TerminalSymbolEnum {

    // valueOf is used as value is overloaded.
    static let numberTokens: Set <TerminalSymbolEnum> = [
        .count, .level, .from, .numberValue, .format, .language,
        .letterValue, .groupingSeparator, .groupingSize, .valueOf
    ]

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension NumberNode {

    func setSyntax() {
        // Set up the allowed syntax. We only need to specify the min and max.
        for keyword in TerminalSymbolEnum.numberTokens {
            let entry = AllowableSyntaxEntryStruct( child: keyword, min: 0, max: 1 )
            allowableChildrenDict[ keyword.description ] = entry
        }
    }

    func isInNumberTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return TerminalSymbolEnum.numberTokens.contains(token)
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//
/// ```xml
///   <number> ::= "number" "{”
///      ( <count>? |
///        <level>? |
///        <from>? |
///        <value>? |
///        <format>? |
///        <lang>? |
///        <letter-value>? |
///        <grouping-separator>? |
///        <grouping-size>? )
///   “}”
/// ```

class NumberNode: ExprNode  {

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
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise.
    ///


    override init() {
        super.init()
        exprNodeType = .number

        setSyntax()

#if HESTIA_LOGGING
        rLogger = RexselLogger()
#endif
   }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse output statement
    ///
    /// No checkiung is done here other than correct syntax, not semantic checks.

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

        // When we arrive here the element terminal symbol is current

#if HESTIA_LOGGING
        rLogger.log( self, .debug, thisCompiler.currentTokenLog )
        rLogger.log( self, .debug, thisCompiler.nextTokenLog )
        rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

        // Slide past keyword token
        thisCompiler.tokenizedSourceIndex += 1

        while !thisCompiler.isEndOfFile {

#if HESTIA_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

            switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket :
                    thisCompiler.nestedLevel += 1
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .terminal, _, _ ) where isInNumberTokens( thisCompiler.currentToken.what ) :
#if HESTIA_LOGGING
                    rLogger.log( self, .debug, "Found \(thisCompiler.currentToken.value)" )
#endif
                    let node: ExprNode

                    // We have to do this because value is overloaded.
                    if thisCompiler.currentToken.what == .valueOf {
                        node = ValueNode()
                    } else {
                        node = thisCompiler.currentToken.what.ExpreNodeClass
                    }

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

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket :
                    thisCompiler.nestedLevel -= 1
                    thisCompiler.tokenizedSourceIndex += 1
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    return

                default :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   inElement: exprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
                    // There maybe more to process in this block
                    continue

            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check duplicates.

    override func buildSymbolTableAndSemanticChecks( allowedTokens tokenSet: Set<TerminalSymbolEnum> ) {

        variablesDict.title = TerminalSymbolEnum.output.description
        variablesDict.blockLine = sourceLine

        super.buildSymbolTableAndSemanticChecks( allowedTokens: TerminalSymbolEnum.outputTokens )

        // Perform validation check here for URIs etc.?
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate Output tag.

    override func generate() -> String {

        let lineComment = super.generate()

        var attributes = ""
        if let children = nodeChildren {
            for child in children {
                attributes += " \(child.generate())"
            }
        }

        // Only output if there are attributes (children)
        if attributes.isNotEmpty {
            return "\(lineComment)<\(thisCompiler.xmlnsPrefix)\(exprNodeType.xml) \(attributes)/>\n"
        }
        return ""
    }


}
