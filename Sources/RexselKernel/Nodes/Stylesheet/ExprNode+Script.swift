//
//  ExprNode+Text.swift
//  RexselKernel
//
//  Copyright (c) 2024 Hugh Field-Richards. All rights reserved.

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Syntax properties
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

extension TerminalSymbolEnum {

    static let scriptAttributeTokens: Set<TerminalSymbolEnum> = [
        .archive, .prefix, .language, .src
    ]

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension ScriptNode {

    func isInScriptTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return TerminalSymbolEnum.scriptAttributeTokens.contains(token)
    }

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

    fileprivate var srcString: String = ""

    fileprivate var archiveString: String = ""

    fileprivate var prefixString: String = ""

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

        srcString = ""
        archiveString = ""
        prefixString = ""
        languageString = ""
        scriptString = ""
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
            name = "\(prefixString)::\(languageString)"
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

                case ( .terminal, .expression, _ ) where thisCompiler.currentToken.what == .prefix :
                    prefixString = thisCompiler.nextToken.value
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                case ( .terminal, .expression, _ ) where thisCompiler.currentToken.what == .language :
                    languageString = thisCompiler.nextToken.value
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                case ( .terminal, .expression, _ ) where thisCompiler.currentToken.what == .src :
                    srcString = thisCompiler.nextToken.value
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                case ( .terminal, .expression, _ ) where thisCompiler.currentToken.what == .archive :
                    archiveString = thisCompiler.nextToken.value
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
                    // Check for required items
                    if prefixString.isEmpty {
                        markMissingScriptOption(inLine: sourceLine, what: .prefix )
                    }
                    if languageString.isEmpty {
                        markMissingScriptOption(inLine: sourceLine, what: .language )
                    }
                    // Need to check for either src or enclosed script, but not both or neither
                    if srcString.isEmpty && scriptString.isEmpty {
                        markMissingSrcOrScript( inLine: sourceLine )
                    }
                    if srcString.isNotEmpty && scriptString.isNotEmpty {
                        markBothSrcAndScript( inLine: sourceLine )
                    }
                    return

                    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                    // Early end of file

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Invalid constructions


                default :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line )
                    return

            }
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
        guard compiler.namespaceList.keys.contains( prefixString ) else {
            missingPrefixDeclaration( inLine: sourceLine, prefix: prefixString )
            return
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate stylesheet tag.

    override func generate() -> String {

        let lineComment = super.generate()

        var attributes = ""
        if prefixString.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.prefix.xml)=\"\(prefixString)\""
        }
        if languageString.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.language.xml)=\"\(languageString)\""
        }
        if srcString.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.src.xml)=\"\(srcString)\""
        }
        if archiveString.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.archive.xml)=\"\(archiveString)\""
        }

        let thisElementName = "\(thisCompiler.xmlnsPrefix)\(thisExprNodeType.xml)"
        if scriptString.isEmpty {
            return "\(lineComment)<\(thisElementName)\(attributes)/>\n"
        } else {
            return "\(lineComment)<\(thisElementName)\(attributes)>\(scriptString)</\(thisElementName)>"
        }
    }


}
