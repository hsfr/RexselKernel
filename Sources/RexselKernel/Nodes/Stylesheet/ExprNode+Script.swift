//
//  ExprNode+Text.swift
//  RexselKernel
//
//  Copyright 2024 Hugh Field-Richards. All rights reserved.

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Syntax properties
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension ScriptNode {

    static let blockTokens: TerminalSymbolEnumSetType = []

    static let optionTokens: TerminalSymbolEnumSetType = [
        .archive, .prefix, .language, .src
    ]

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class ScriptNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    fileprivate var languageString: String = ""

    fileprivate var scriptString: String = ""

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
        thisExprNodeType = .script
        isLogging = true  // Adjust as required
        setSyntax( options: ScriptNode.optionTokens, elements: ScriptNode.blockTokens )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse script statement.
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

                case ( .terminal, .expression, _ )  where isInOptionTokens( thisCompiler.currentToken.what ) :
                    optionsDict[ thisCompiler.currentToken.what ]?.value = thisCompiler.nextToken.value
                    if optionsDict[ thisCompiler.currentToken.what ]?.count == 0 {
                        optionsDict[ thisCompiler.currentToken.what ]?.defined = thisCompiler.currentToken.line
                    }
                    // Update for name of this node
                    if thisCompiler.currentToken.what == .language {
                        languageString = thisCompiler.nextToken.value
                    }
                    optionsDict[ thisCompiler.currentToken.what ]?.count += 1
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                    // Actual script enclosed in quote
                case ( .expression, _, _ ) :
                    scriptString = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // End of statement

                case ( .terminal, _, _ ) where TerminalSymbolEnum.stylesheetTokens.contains( thisCompiler.currentToken.what ) ||
                                               thisCompiler.currentToken.what == .closeCurlyBracket :
                    // Found next statement or block end
                    checkSyntax()
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Early end of file

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    checkSyntax()
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Invalid constructions

                default :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   mightBe: ScriptNode.optionTokens,
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
    /// ```xml
    ///  <script> ::= “script”
    ///                  “prefix” <quote> <namespace prefix> <quote>
    ///                  "language" <quote> <script language definition> <quote>
    ///                  ( "archive" <quote> <uri list> >quote> )?
    ///                  (
    ///                    ( "src" <quote> <script uri> >quote> ) |
    ///                    ( <quote> <script text> >quote> )
    ///                  )
    /// ```

    override func setSyntax( options optionsList: TerminalSymbolEnumSetType, elements elementsList: TerminalSymbolEnumSetType ) {
        super.setSyntax( options: optionsList, elements: elementsList )
        optionsDict[ .prefix ] = AllowableSyntaxEntryStruct( min: 1, max: 1 )
        optionsDict[ .language ] = AllowableSyntaxEntryStruct( min: 1, max: 1 )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check the syntax that was input against that defined
    /// in _setSyntax_. Any special requirements are done here
    /// such as required combinations of keywords.

    override func checkSyntax() {
        super.checkSyntax()
        // Need to check for either src or enclosed script, but not both or neither
        if optionsDict[ .src ]!.count == 0 && scriptString.isEmpty {
            markMissingSrcOrScript( inLine: sourceLine )
        }
        if optionsDict[ .src ]!.count > 0 && scriptString.isNotEmpty {
            markBothSrcAndScript( inLine: sourceLine )
        }
    }

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check scope of variables.
    ///
    /// Check the namespace prefix has been declared for
    /// this stylesheet.

    override func checkVariableScope( _ compiler: RexselKernel ) {
        if let prefix = optionsDict[ .prefix ] {
            guard compiler.namespaceList.keys.contains( prefix.value ) else {
                missingPrefixDeclaration( inLine: sourceLine, prefix: prefix.value )
                return
            }
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
                attributes += " \(key.xml)=\"\(entry.value)\""
            }
        }

        let thisElementName = "\(thisCompiler.xmlnsPrefix)\(thisExprNodeType.xml)"
        if scriptString.isEmpty {
            return "\(lineComment)<\(thisElementName)\(attributes)/>\n"
        } else {
            return "\(lineComment)<\(thisElementName)\(attributes)>\(scriptString)</\(thisElementName)>"
        }
    }


}
