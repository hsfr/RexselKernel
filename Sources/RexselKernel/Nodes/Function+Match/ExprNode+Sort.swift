//
//  ExprNode+Sort.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 31/01/2024.
//

import Foundation

class SortNode: ExprNode  {

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

    fileprivate var usingString: String = ""

    fileprivate var languageString: String = ""

    /// Ascending or descending sort order
    ///
    /// The order specifies whether the strings should be sorted in ascending
    /// or descending order; ascending specifies ascending order; descending
    /// specifies descending order; the default is ascending.
    fileprivate var ascending: Bool = true

    /// The sort order for case when the data type is text.
    ///
    /// When _upper_ the string "h H fred Fred" would return "H h Fred fred".
    /// _upper_ and _lower_ are both declared beause the default is dependant
    /// on 8thje language.
    fileprivate var upper: Bool = false

    fileprivate var lower: Bool = false

    /// data-type specifies the data type of the strings.
    ///
    /// This version of Rexsel only has two value _text_ and _number_ with
    /// the default being _text_
    fileprivate var text: Bool = true

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise Node base.

    override init() {
        super.init()
        self.exprNodeType = .sort

#if HESTIA_LOGGING
        rLogger = RexselLogger()
#endif
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse with statement.
    ///
    /// ```xml
    ///   <sort> ::= "sort" ( "using" <expression> )?
    ///                     ( "language" <expression> )?
    ///                     ( ( "ascending" | "descending" ) )?
    ///                     ( ( "upper-first" | "lower-first" ) )?
    ///                     ( ( "text" | "number" ) )?
    /// ```

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

#if HESTIA_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

        // Slide past keyword
        thisCompiler.tokenizedSourceIndex += 1

        while !thisCompiler.isEndOfFile {
#if HESTIA_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

            switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

                case ( .terminal, .expression, _ ) where thisCompiler.currentToken.what == .using :
                    usingString = thisCompiler.nextToken.value
                    thisCompiler.tokenizedSourceIndex += 2

                case ( .terminal, .expression, _ ) where thisCompiler.currentToken.what == .language :
                    languageString = thisCompiler.nextToken.value
                    thisCompiler.tokenizedSourceIndex += 2

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .ascending :
                    ascending = true
                    thisCompiler.tokenizedSourceIndex += 1

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .descending :
                    ascending = false
                    thisCompiler.tokenizedSourceIndex += 1

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .upperFirst :
                    upper = true
                    thisCompiler.tokenizedSourceIndex += 1

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .lowerFirst :
                    upper = false
                    thisCompiler.tokenizedSourceIndex += 1

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .textSort :
                    text = true
                    thisCompiler.tokenizedSourceIndex += 1

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .numberSort :
                    text = false
                    thisCompiler.tokenizedSourceIndex += 1

                case ( .expression, _, _ ) : // Naked expression
                    markUnexpectedExpressionError()
                    return

                case ( .terminal, _, _ ) : // Otherwise pass up the parse chain
                    return

                default :
                    return

            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate tag.
    ///
    /// Output is of the form, but note that having a default value
    /// and a contents is ambiguous but not forbidden.
    /// ```xml
    ///     <xsl:sort
    ///         select=EXPRESSION
    ///         order="ascending" | "descending"
    ///         case-order="upper-first" | "lower-first"
    ///         lang=XML:LANG-CODE
    ///         data-type="text" | "number" />
    /// ```

    override func generate() -> String {

        _ = super.generate()

        var attributes = ""
        if usingString.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.select.xml)=\"\(usingString)\""
        }
        if languageString.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.language.xml)=\"\(languageString)\""
        }
        if !ascending {
            attributes += " \(TerminalSymbolEnum.order.xml)=\"\(TerminalSymbolEnum.descending.xml)\""
        }
        // This will need modifying eventually to support other languages.
        switch ( upper, lower ) {
            case ( true, false ) where text :
                attributes += " \(TerminalSymbolEnum.caseOrder.xml)=\"\(TerminalSymbolEnum.upperFirst.xml)\""

            case ( false, true ) where text :
                attributes += " \(TerminalSymbolEnum.caseOrder.xml)=\"\(TerminalSymbolEnum.upperFirst.xml)\""
                
            default: ()
        }
        // This will need modifying to include a QName construct
        if !text {
            attributes += " \(TerminalSymbolEnum.dataType.xml)=\"\(TerminalSymbolEnum.number.xml)\""
        }

        return "<\(thisCompiler.xmlnsPrefix)\(exprNodeType.xml) \(attributes)/>\n"
    }

}
