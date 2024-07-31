//
//  ExprNode+DecimalFormat.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 20/02/2024.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-* Formal Syntax Definition -*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension DecimalFormatNode {

    static let blockTokens: TerminalSymbolEnumSetType = [
        .decimalSeparator, .groupingSeparator,
        .infinity,.indent,.minusSign,.notNumber,
        .percent,.perMille,.zeroDigit,.digit,
        .patternSeparator
    ]

    static let optionTokens: TerminalSymbolEnumSetType = []

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

    override init() {
        super.init()
        thisExprNodeType = .decimalFormat
        isInBlock = false
        isLogging = true  // Adjust as required
        setSyntax( options: DecimalFormatNode.optionTokens, elements: DecimalFormatNode.blockTokens )
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

        if isLogging {
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
        }

        thisCompiler.tokenizedSourceIndex += 1

        while !thisCompiler.isEndOfFile {

            if isLogging {
                rLogger.log( self, .debug, thisCompiler.currentTokenLog )
                rLogger.log( self, .debug, thisCompiler.nextTokenLog )
                rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
            }

            switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Valid constructions

                case ( .qname, _, _ ) where name.isEmpty :
                    name = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket :
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel += 1
                    isInBlock = true
                    continue

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket :
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel += 1
                    isInBlock = true
                    continue

                    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                    // Process block

                    case ( .terminal, _, _ ) where isInChildrenTokens( thisCompiler.currentToken.what ) && isInBlock :
                        if isLogging {
                            rLogger.log( self, .debug, "Found \(thisCompiler.currentToken.value)" )
                        }

                        _ = markIfInvalidKeywordForThisVersion( thisCompiler )

                        // The keyword "value" is overloaded here. It does not mean "valueOf"
                        // but "value". Nasty but effective...
                        var node: ExprNode = thisCompiler.currentToken.what.ExpreNodeClass
                        if thisCompiler.currentToken.what == .valueOf {
                            node = ValueNode()
                        }
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
                        thisCompiler.tokenizedSourceIndex += 1
                        thisCompiler.nestedLevel -= 1
                        return

                    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                    // Early end of file

                    case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                        return

                    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                    // Invalid constructions

                    case ( _, _, _ ) where !isInChildrenTokens( thisCompiler.currentToken.what ) && isInBlock :
                        // Illegal keyword
                        try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                       mightBe: NumberNode.blockTokens,
                                                       inElement: thisExprNodeType,
                                                       inLine: thisCompiler.currentToken.line,
                                                       skip: .toNextKeyword )
                        continue

                    default :
                        try markUnexpectedSymbolError( what: thisCompiler.currentToken.what,
                                                       inElement: thisExprNodeType,
                                                       inLine: thisCompiler.currentToken.line,
                                                       skip: .toNextKeyword )
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
    /// <decimal-format> ::= "decimal-format" <name>
    ///                      "{"
    ///                           (
    ///                              ( "decimalSeparator" <quote> <alpha character> <quote>  )? |
    ///                              ( "groupingSeparator" <quote> <alpha character> <quote>  )? |
    ///                              ( "infinity" <quote> <alphanumeric string> <quote>  )? |
    ///                              ( "minusSign"  <quote> <alphanumeric character> <quote>  )? |
    ///                              ( "notNumber"  <quote> <alphanumeric string> <quote>  )? |
    ///                              ( "percent"  <quote> <alphanumeric character> <quote>  )? |
    ///                              ( "perMille" <quote> <alphanumeric character> <quote>  )?  |
    ///                              ( "zeroDigit"  <quote> <alphanumeric character> <quote>  )? |
    ///                              ( "digit"  <quote> <alphanumeric character> <quote>  )? |
    ///                              ( "patternSeparator" <quote> <alphanumeric character> <quote>  )?
    ///                           )+
    ///                      "}"
    /// ```

    override func setSyntax( options optionsList: TerminalSymbolEnumSetType, elements elementsList: TerminalSymbolEnumSetType ) {
        super.setSyntax( options: optionsList, elements: elementsList )
        for ( key, _ ) in childrenDict {
            childrenDict[ key ] = AllowableSyntaxEntryStruct( min: 0, max: 1 )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check the syntax that was input against that defined
    /// in _setSyntax_. Any special requirements are done here
    /// such as required combinations of keywords.

    override func checkSyntax() {
        super.checkSyntax()

        var blockElementFound = false
        for ( _, entry ) in childrenDict {
            if entry.count > 0 {
                blockElementFound = true
                break
            }
        }
        if !blockElementFound {
            markSyntaxRequiresOneOrMoreElement( inLine: sourceLine,
                                                name: tokensDescription( DecimalFormatNode.blockTokens ),
                                                inElement: self.thisExprNodeType.description )
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
        if let children = nodeChildren {
            for child in children {
                attributes += " \(child.generate())"
            }
        }

        // Only output if there are attributes (children)
        if attributes.isNotEmpty {
            return "\(lineComment)<\(thisCompiler.xmlnsPrefix)\(thisExprNodeType.xml) \(attributes)/>\n"
        }
        return ""
    }


}
