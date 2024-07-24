//
//  ExprNode+Sort.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 31/01/2024.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-* Formal Syntax Definition -*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension SortNode {

    static let blockTokens: TerminalSymbolEnumSetType = [
    ]

    static let optionTokens: TerminalSymbolEnumSetType = [
        .using, .lang, 
        .ascending, .descending,
        .upperFirst, .lowerFirst,
        .textSort, .numberSort
    ]

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class SortNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    fileprivate var usingString: String = ""

    fileprivate var langString: String = ""

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
        self.thisExprNodeType = .sort
        isLogging = false  // Adjust as required
        setSyntax( options: SortNode.optionTokens, elements: SortNode.blockTokens )
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

        // Slide past keyword
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

                case ( .terminal, .expression, _ ) where isInOptionTokens( thisCompiler.currentToken.what ) :
                    // Any illegal expression after an option are detected when checking syntax.
                    optionsDict[ thisCompiler.currentToken.what ]?.value = thisCompiler.nextToken.value
                    if optionsDict[ thisCompiler.currentToken.what ]?.count == 0 {
                        optionsDict[ thisCompiler.currentToken.what ]?.defined = thisCompiler.currentToken.line
                    }
                    optionsDict[ thisCompiler.currentToken.what ]?.count += 1
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                case ( .terminal, _, _ ) where isInOptionTokens( thisCompiler.currentToken.what ) :
                    optionsDict[ thisCompiler.currentToken.what ]?.value = ""
                    if optionsDict[ thisCompiler.currentToken.what ]?.count == 0 {
                        optionsDict[ thisCompiler.currentToken.what ]?.defined = thisCompiler.currentToken.line
                    }
                    optionsDict[ thisCompiler.currentToken.what ]?.count += 1
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Invalid constructions

                case ( _, .terminal, _ ) where thisCompiler.currentToken.type == .qname :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextKeyword )
                    continue

                case ( .expression, _, _ ) : // Naked expression
                    try markUnexpectedExpressionError( inLine: thisCompiler.currentToken.line,
                                                       what: thisCompiler.currentToken.value )
                    checkSyntax()
                    return

                // Everything gets passed up the chain.

                default :
                    checkSyntax()
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
    ///   <sort> ::= "sort" ( "using" <expression> )?
    ///                     ( "lang" <expression> )?
    ///                     ( "ascending" | "descending" )?
    ///                     ( "upper-first" | "lower-first" )?
    ///                     ( "text" | "number" )?
    /// ```

    override func setSyntax( options optionsList: TerminalSymbolEnumSetType, elements elementsList: TerminalSymbolEnumSetType ) {
        super.setSyntax( options: optionsList, elements: elementsList )
        optionsDict[ .ascending ] = AllowableSyntaxEntryStruct( max: 1, needsExpression: false )
        optionsDict[ .descending ] = AllowableSyntaxEntryStruct( max: 1, needsExpression: false )
        optionsDict[ .upperFirst ] = AllowableSyntaxEntryStruct( max: 1, needsExpression: false )
        optionsDict[ .lowerFirst ] = AllowableSyntaxEntryStruct( max: 1, needsExpression: false )
        optionsDict[ .textSort ] = AllowableSyntaxEntryStruct( max: 1, needsExpression: false )
        optionsDict[ .numberSort ] = AllowableSyntaxEntryStruct( max: 1, needsExpression: false )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check the syntax that was input against that defined
    /// in _setSyntax_. Any special reuirements are done here
    /// such as required combinations of keywords.

    override func checkSyntax()
    {
        super.checkSyntax()
        // Check for illegal expressions
        for ( _, entry ) in optionsDict {
            if !entry.needsExpression && entry.value.isNotEmpty {
                try? markUnexpectedExpressionError( inLine: thisCompiler.currentToken.line,
                                                   what: thisCompiler.currentToken.value )
            }
        }
        // Check for duplicates
        if optionsDict[ TerminalSymbolEnum.ascending ]!.count > 0 && optionsDict[ TerminalSymbolEnum.descending ]!.count > 0 {
            markCannotHaveBothOptions( inLine: thisCompiler.currentToken.line,
                                       option1: TerminalSymbolEnum.ascending.description,
                                       option2: TerminalSymbolEnum.descending.description,
                                       inElement: thisExprNodeType.description )
        }
        if optionsDict[ TerminalSymbolEnum.upperFirst ]!.count > 0 && optionsDict[ TerminalSymbolEnum.lowerFirst ]!.count > 0 {
            markCannotHaveBothOptions( inLine: thisCompiler.currentToken.line,
                                       option1: TerminalSymbolEnum.upperFirst.description,
                                       option2: TerminalSymbolEnum.lowerFirst.description,
                                       inElement: thisExprNodeType.description )
        }
        if optionsDict[ TerminalSymbolEnum.textSort ]!.count > 0 && optionsDict[ TerminalSymbolEnum.numberSort ]!.count > 0 {
            markCannotHaveBothOptions( inLine: thisCompiler.currentToken.line,
                                       option1: TerminalSymbolEnum.textSort.description,
                                       option2: TerminalSymbolEnum.numberSort.description,
                                       inElement: thisExprNodeType.description )
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

        if optionsDict[ TerminalSymbolEnum.using ]!.value.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.select.xml)=\"\(optionsDict[ TerminalSymbolEnum.using ]!.value)\""
        }

        if optionsDict[ TerminalSymbolEnum.lang ]!.value.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.lang.xml)=\"\(optionsDict[ TerminalSymbolEnum.lang ]!.value)\""
        }

        if optionsDict[ TerminalSymbolEnum.ascending ]!.count > 0 {
            attributes += " \(TerminalSymbolEnum.order.xml)=\"\(TerminalSymbolEnum.ascending.xml)\""
        }

        if optionsDict[ TerminalSymbolEnum.descending ]!.count > 0 {
            attributes += " \(TerminalSymbolEnum.order.xml)=\"\(TerminalSymbolEnum.descending.xml)\""
        }

        if optionsDict[ TerminalSymbolEnum.upperFirst ]!.count > 0 {
            attributes += " \(TerminalSymbolEnum.caseOrder.xml)=\"\(TerminalSymbolEnum.upperFirst.xml)\""
        }

        if optionsDict[ TerminalSymbolEnum.lowerFirst ]!.count > 0 {
            attributes += " \(TerminalSymbolEnum.caseOrder.xml)=\"\(TerminalSymbolEnum.lowerFirst.xml)\""
        }

        if optionsDict[ TerminalSymbolEnum.textSort ]!.count > 0 {
            attributes += " \(TerminalSymbolEnum.dataType.xml)=\"\(TerminalSymbolEnum.textSort.xml)\""
        }

        if optionsDict[ TerminalSymbolEnum.numberSort ]!.count > 0 {
            attributes += " \(TerminalSymbolEnum.dataType.xml)=\"\(TerminalSymbolEnum.numberSort.xml)\""
        }

        return "<\(thisCompiler.xmlnsPrefix)\(thisExprNodeType.xml) \(attributes)/>\n"
    }

}
