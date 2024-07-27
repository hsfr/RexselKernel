//
//  ExprNode+Text.swift
//  RexselKernel
//
//  Copyright 2024 Hugh Field-Richards. All rights reserved.

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-* Formal Syntax Definition -*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension TextNode {

    static let blockTokens: TerminalSymbolEnumSetType = []

    static let optionTokens: TerminalSymbolEnumSetType = [
        .disableOutputEscaping
    ]

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class TextNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    fileprivate var textString: String = ""

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
        thisExprNodeType = .text
        isLogging = false  // Adjust as required
        setSyntax( options: TextNode.optionTokens, elements: TextNode.blockTokens )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse text statement.
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

     // Slide past keyword.
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

                case ( .terminal, _, _ )  where isInOptionTokens( thisCompiler.currentToken.what ) :
                    optionsDict[ thisCompiler.currentToken.what ]?.value = thisCompiler.nextToken.value
                    if optionsDict[ thisCompiler.currentToken.what ]?.count == 0 {
                        optionsDict[ thisCompiler.currentToken.what ]?.defined = thisCompiler.currentToken.line
                    }
                    optionsDict[ thisCompiler.currentToken.what ]?.count += 1
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

               case ( .expression, _, _ ) where textString.isEmpty :
                    textString = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Exit

                case ( .terminal, _, _ ) where isInBlockTemplateTokens( thisCompiler.currentToken.what ) :
                    checkSyntax()
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket :
                    checkSyntax()
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Early end of file

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Invalid constructions

                default:
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   mightBe: TextNode.optionTokens,
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
    ///   <text> ::= “text” “disable-output-escaping”? <quote> <alphanumeric string> <quote
    /// ```

    override func setSyntax( options optionsList: TerminalSymbolEnumSetType, elements elementsList: TerminalSymbolEnumSetType ) {
        super.setSyntax( options: optionsList, elements: elementsList )
        optionsDict[ .disableOutputEscaping ] = AllowableSyntaxEntryStruct( min: 0, max: 1, needsExpression: false )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check the syntax that was input against that defined
    /// in _setSyntax_. Any special requirements are done here
    /// such as required combinations of keywords.

    override func checkSyntax() {
        super.checkSyntax()
        if textString.isEmpty {
            try? markMissingItemError( what: .text,
                                       inLine: thisCompiler.currentToken.line,
                                       after: thisCompiler.currentToken.what.description )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate stylesheet tag.

    override func generate() -> String {

        let lineComment = super.generate()

        var attributes = ""

        for ( key, entry ) in optionsDict {
            if entry.value.isNotEmpty {
                attributes += " \(key.xml)=\"yes\""
            }
        }

        let thisElementName = "\(thisCompiler.xmlnsPrefix)\(thisExprNodeType.xml)"
        if textString.isEmpty {
            return "\(lineComment)<\(thisElementName)\(attributes)/>\n"
        } else {
            return "\(lineComment)<\(thisElementName)\(attributes)>\(textString)</\(thisElementName)>"
        }
    }


}
