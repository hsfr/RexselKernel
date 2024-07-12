//
//  ExprNode+DecimalFormat.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 20/02/2024.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Syntax properties
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension TerminalSymbolEnum {

    static let decimalFormatTokens: Set <TerminalSymbolEnum> = [
        .decimalSeparator, .groupingSeparator,
        .infinity,.indent,.minusSign,.notNumber,
        .percent,.perMille,.zeroDigit,.digit,
        .patternSeparator
    ]
}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension DecimalFormatNode {

    func isInDecimalFormatTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return TerminalSymbolEnum.decimalFormatTokens.contains(token)
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class DecimalFormatNode: ExprNode  {

   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise.

    override init() {
        super.init()
        exprNodeType = .decimalFormat
        name = ""
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse output statement

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

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Valid statements

                case ( .qname, .terminal, _ ) where thisCompiler.nextToken.what == .openCurlyBracket :
                     name = thisCompiler.currentToken.value
                     thisCompiler.tokenizedSourceIndex += 1
                     continue

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket  && name.isNotEmpty :
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel += 1
                    continue

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Process block material

                case ( .terminal, _, _ ) where isInDecimalFormatTokens( thisCompiler.currentToken.what ) :
#if REXSEL_LOGGING
                    rLogger.log( self, .debug, "Found \(thisCompiler.currentToken.valueString)" )
#endif
                    let node: ExprNode = thisCompiler.currentToken.what.ExpreNodeClass
                    if self.nodeChildren == nil {
                        self.nodeChildren = [ExprNode]()
                    }
                    nodeChildren.append( node )
                    node.parentNode = self
                    try node.parseSyntaxUsingCompiler( thisCompiler )
                    continue

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket :
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel -= 1
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Error conditions

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket && name.isEmpty :
                    try markMissingItemError( what: .name,
                                              inLine: thisCompiler.currentToken.line,
                                              after: exprNodeType.description,
                                              skip: .toNextkeyword )
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel += 1
                    continue

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
    /// Generate Output tag.
    ///
    /// Output is of the form
    /// ```xml
    ///    <xsl:decimal-format
    ///        name=NAME
    ///        decimal-separator=CHARACTER
    ///        grouping-separator=CHARACTER
    ///        infinity=STRING
    ///        minus-sign=CHARACTER
    ///        NaN=STRING
    ///        percent=CHARACTER
    ///        per-mille=CHARATER
    ///        zero-digit=CHARACTER
    ///        digit=CHARACTER
    ///        pattern-separator=CHARACTER />
    /// ```
    /// where each attribute is optional, although if there are no
    /// attributes the output is ignored.

    override func generate() -> String {

        let lineComment = super.generate()

        var attributes = ""
        if name.isNotEmpty {
            attributes += "\(TerminalSymbolEnum.name.xml)=\"\(name)\""
        }

        if let children = nodeChildren {
            for child in children {
                attributes += " \(child.generate())"
            }
        }

        if attributes.isNotEmpty {
            return "\(lineComment)<\(thisCompiler.xmlnsPrefix)\(exprNodeType.xml) \(attributes)/>"
        }
        return "\(lineComment)<\(thisCompiler.xmlnsPrefix)\(exprNodeType.xml) \(attributes)/>"
    }


}
