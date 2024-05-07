//
//  ExprNode+ValueOf.swift
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

extension TerminalSymbolEnum {

    static let valueAttributeTokens: Set<TerminalSymbolEnum> = [
        .disableOutputEscaping
    ]

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension ValueOfNode {

    func isInValueAttributeTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return TerminalSymbolEnum.valueAttributeTokens.contains(token)
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class ValueOfNode: ExprNode {

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

    ///  Value (when not derived from block)
    ///
    /// Must be public for duplicate checking
    var expresssionString = ""

    fileprivate var disableOutputEscaping = false

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
        exprNodeType = .valueOf
        expresssionString = ""
        disableOutputEscaping = false

#if REXSEL_LOGGING
        rLogger = RexselLogger()
#endif
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse value statement.

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

        thisCompiler.tokenizedSourceIndex += 1

        while !thisCompiler.isEndOfFile {

#if REXSEL_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

            switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

                // Valid constructions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                case ( .expression, _, _ ) where expresssionString.isEmpty :
                    expresssionString = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .terminal, _, _ ) where isInValueAttributeTokens( thisCompiler.currentToken.what )  :
                    disableOutputEscaping = ( thisCompiler.currentToken.what == .disableOutputEscaping )
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && expresssionString.isNotEmpty :
                    return

                case ( .terminal, _, _ ) where isInBlockTemplateTokens( thisCompiler.currentToken.what ) && expresssionString.isNotEmpty :
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Early end of file

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    // Don't bother to check. End of file here is an error anyway which
                    // will be picked up above this node. Almost certainly a brackets problem.
                    return

                // Invalid constructions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                default:
                    // Anything else is an error.
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
    /// Check variable scoping.
    ///
    /// At this stage the check for duplicates will have been run
    /// so the tables, _variableDict_ should be populated for this node.

    override func checkVariableScope() {

        super.checkVariableScope()

        // There are no blocks associated with this node
        scanVariablesInNodeValue( expresssionString, inLine: sourceLine )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate stylesheet tag.
    ///
    /// Output is of the form, but note that having a default value
    /// and a contents is ambiguous but not forbidden.
    /// ```xml
    ///     <xsl:value-of select="expression" disable-output-escaping="yes" | "no" />
    /// ```

    override func generate() -> String {

        let lineComment = super.generate()

        var attributes = ""
        if expresssionString.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.select.xml)=\"\(expresssionString)\""
        }
        // Only need to mark as yes
        if disableOutputEscaping {
            attributes += " \(TerminalSymbolEnum.disableOutputEscaping.xml)=\"\(TerminalSymbolEnum.yes)\""
        }

        return "\(lineComment)<\(thisCompiler.xmlnsPrefix)\(exprNodeType.xml) \(attributes)/>\n"
    }

}
