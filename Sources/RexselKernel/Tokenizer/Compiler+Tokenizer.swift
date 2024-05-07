//
//  Compiler+Tokenizer.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 01/01/2024.
//

import Foundation

extension RexselKernel {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    ///
    /// Tokenize the source (from source panel).
    ///
    /// After running the source should be split into a series
    /// of tokens. For example if the source is
    ///
    /// ```
    /// xslt {
    ///     match using "/" {
    ///         element html {
    /// etc.
    /// ```
    /// then `tokenedFile` will contain
    /// ```
    /// [0:0][terminal][xslt][xslt]
    /// [0:5][terminal][openCurlyBracket][{]
    /// [1:4][terminal][match][match]
    /// [1:10][terminal][using][using]
    /// [1:16][expression][expression][/]
    /// [1:20][terminal][openCurlyBracket][{]
    /// [2:8][terminal][element][element]
    /// [2:16][qname][unknownToken][html]
    /// [2:21][terminal][openCurlyBracket][{]
    /// etc.
    /// ```
    /// where the output format is
    /// ```
    /// [line:position][type][what][value]
    /// ```

    func tokenizeSource( ) {

        enum TokenizerState {
            case newToken
            case withinToken
            case withinQuote
            case withinComment
            case literalCharacter
        }

        // Convenience variables

        var stringLength = 0

        let singleQuoteCharacter = "\'"
        let doubleQuoteCharacter = "\""
        let literalCharacterPrefix = "\\"
        var currentQuoteCharacter = " "

        let spaceCharacter = " "
        let tabCharacter = "\t"
        let newlineCharacter = "\n"

        let openCurlyBracket = "{"
        let closeCurlyBracket = "}"

        var tokeniseState: TokenizerState = .newToken
        var argumentPosition = 0
        var characterCount = 0

        let whiteSpace: Set <String> = [ spaceCharacter, tabCharacter ]
        let quoteCharacters: Set <String> = [ singleQuoteCharacter, doubleQuoteCharacter ]

        // var theTokens = Array<TokenType>()
        var thisToken = ""

        var lineNumber = 0

        // Now scan the line to break into tokens
        var tokenType = TokenEnum.unknown
        tokenizedSource = TokenizedFileType()

        // Clear down the source string that holds the entire source
        sourceString = ""

        while true {
            let ( nextLine, eof ) = source.getLine()
            sourceString += nextLine.line
            // Insert newline
            sourceString += newlineCharacter
            if eof {
#if HESTIA_LOGGING
                rLogger.log( structName, .debug, "Finished reading source")
#endif
                break
            }
        }

        stringLength = sourceString.count

        guard sourceString.isNotEmpty else {
            return
        }

#if HESTIA_LOGGING
        self.rLogger.log( structName, .debug, sourceString )
#endif

        var idx = 0
        var finished = false

        while !finished {

            var currentCharacter = sourceString[idx]
            let nextCharacter = ( idx + 1 < stringLength  ) ? sourceString[idx+1] : ""

            if showFullMessages {
                print( lineNumber, terminator: "\r" )
            }

            // Sort out any "smart" quotes and make them dumb.
            switch currentCharacter {
                case "“", "”":
                    currentCharacter = doubleQuoteCharacter
                case "‘", "’":
                    currentCharacter = singleQuoteCharacter
                default:
                    ()
            }

#if HESTIA_LOGGING
            self.rLogger.log( structName,
                              .debug,
                              "[\(tokeniseState)] [\(currentCharacter == newlineCharacter ? "newline"  : currentCharacter )] [\(nextCharacter == newlineCharacter ? "newline"  : nextCharacter )]" )
#endif

            switch ( tokeniseState, currentCharacter, nextCharacter ) {

                    // Newlines and spaces

                case ( .newToken, _, _ ) where whiteSpace.contains( currentCharacter ) :
                    // Ignore leading spaces
                    thisToken = ""

                case ( .withinToken, _, _ ) where whiteSpace.contains( currentCharacter ) :
                    // Found end of token.
                    if thisToken.isNotEmpty {
                        if TerminalSymbolEnum.isTerminalSymbol( thisToken ) {
                            tokenType = TokenEnum.terminal
                        } else {
                            tokenType = TokenEnum.qname
                        }
                        let symbol = TerminalSymbolEnum.translate( thisToken )
                        tokenizedSource.append( ( type: tokenType, what: symbol,
                                                  value: thisToken,
                                                  line: lineNumber, position: argumentPosition ) )
                    }
                    tokenType = TokenEnum.unknown
                    thisToken = ""
                    tokeniseState = .newToken

                case ( .withinToken, _, _ ) where quoteCharacters.contains( currentCharacter ) :
                    // Found quote at end of token. Remove quote from value
                    if thisToken.isNotEmpty {
                        if TerminalSymbolEnum.isTerminalSymbol( thisToken ) {
                            tokenType = TokenEnum.terminal
                        } else {
                            tokenType = TokenEnum.qname
                        }
                        let symbol = TerminalSymbolEnum.translate( thisToken )
                        tokenizedSource.append( ( type: tokenType,
                                                  what: symbol,
                                                  value: thisToken,
                                                  line: lineNumber, position: argumentPosition ) )
                    }
                    // Now go and get next character (which should be quote).
                    tokenType = TokenEnum.unknown
                    thisToken = ""
                    tokeniseState = .newToken
                    continue

                case ( _, newlineCharacter, _ ) where tokeniseState != .withinQuote :
                    // End of a line, if we were processing a terminal/qname symbol
                    // end it and store.
                    if thisToken.isNotEmpty {
                        // If in middle of quote
                        if TerminalSymbolEnum.isTerminalSymbol( thisToken ) {
                            tokenType = TokenEnum.terminal
                        } else {
                            tokenType = TokenEnum.qname
                        }
                        let symbol = TerminalSymbolEnum.translate( thisToken )
                        tokenizedSource.append( ( type: tokenType, what: symbol,
                                                  value: thisToken,
                                                  line: lineNumber, position: argumentPosition ) )
                    }
                    tokenType = TokenEnum.unknown
                    thisToken = ""
                    tokeniseState = .newToken
                    lineNumber += 1

                case ( _, newlineCharacter, _ ) where tokeniseState == .withinQuote :
                    // When within quote we add the newline to the token being assembled
                    thisToken.append( currentCharacter )
                    lineNumber += 1

                    // Comments

                case ( .withinComment, _, _ ) :
                    ()

                case ( .newToken, "/", "/" ) where thisToken.isNotEmpty,
                    ( .withinToken, "/", "/" ) where thisToken.isNotEmpty :
                    // A comment so ignore rest of line unless we are processing symbol/quotes
                    // in which case we close the symbol and store.
                    if thisToken.isNotEmpty {
                        if TerminalSymbolEnum.isTerminalSymbol( thisToken ) {
                            tokenType = TokenEnum.terminal
                        }
                        let symbol = TerminalSymbolEnum.translate( thisToken )
                        tokenizedSource.append( ( type: tokenType, what: symbol,
                                                  value: thisToken,
                                                  line: lineNumber, position: argumentPosition ) )
                        tokenType = TokenEnum.unknown
                    }
                    tokeniseState = .withinComment

                case ( .newToken, "/", "/" ) where thisToken.isEmpty,
                    ( .withinToken, "/", "/" ) where thisToken.isEmpty :
                    // Just mark off as comment
                    tokeniseState = .withinComment

                    // Tokens

                case ( .withinToken, _, _ ) :
                    // When within a token just append character
                    thisToken.append( currentCharacter )
                    tokeniseState = .withinToken

                    // Quotation strings/expressions

                case ( .literalCharacter, _, _ ) :
                    thisToken.append( currentCharacter )
                    tokeniseState = .withinQuote

                case ( .withinQuote, doubleQuoteCharacter, _ ) where currentCharacter == currentQuoteCharacter,
                    ( .withinQuote, singleQuoteCharacter, _ ) where currentCharacter == currentQuoteCharacter :
                    // End of quoteation (expression etc) so store it away
                    //if thisToken.isNotEmpty {
                        // Existing token
                        tokenType = TokenEnum.expression
                        tokenizedSource.append( ( type: tokenType, what: .expression,
                                                  value: thisToken,
                                                  line: lineNumber, position: argumentPosition ) )
                    //}
                    // Rest everything for new token
                    tokenType = TokenEnum.unknown
                    thisToken = ""
                    tokeniseState = .newToken

                case ( .withinQuote, literalCharacterPrefix, _ ):
                    tokeniseState = .literalCharacter

                case ( .withinQuote, _, _ ):
                    thisToken.append( currentCharacter )
                    tokeniseState = .withinQuote

                    // Tokens

                case ( .newToken, tabCharacter, _ ), ( .newToken, spaceCharacter, _ ) :
                    // Ignore leading spaces
                    thisToken = ""

                case ( .newToken, doubleQuoteCharacter, _ ), ( .newToken, singleQuoteCharacter, _ ) :
                    // Found beginning of new string definition
                    argumentPosition = characterCount
                    currentQuoteCharacter = currentCharacter
                    tokenType = TokenEnum.expression
                    thisToken = ""
                    tokeniseState = .withinQuote

                case ( .newToken, _, _ ) :
                    // Otherwise found beginning of new token, bracket etc.
                    argumentPosition = characterCount
                    thisToken.append( currentCharacter )
                    // Assume that it is a terminal symbol rather than a qname at this point
                    tokenType = TokenEnum.terminal
                    tokeniseState = .withinToken

                case ( .withinToken, openCurlyBracket, _ ), ( .withinToken, closeCurlyBracket, _ ) :
                    // Found end of token.
                    if thisToken.isNotEmpty {
                        if TerminalSymbolEnum.isTerminalSymbol( thisToken ) {
                            tokenType = TokenEnum.terminal
                        } else {
                            tokenType = TokenEnum.qname
                        }
                        let symbol = TerminalSymbolEnum.translate( thisToken )
                        tokenizedSource.append( ( type: tokenType, what: symbol,
                                                  value: thisToken,
                                                  line: lineNumber, position: argumentPosition ) )
                    }
                    tokenType = TokenEnum.unknown
                    thisToken = ""
                    tokeniseState = .newToken
                    if currentCharacter == closeCurlyBracket {
                        continue
                    }

            }

            characterCount += 1
            idx += 1

            if idx >= stringLength {
                finished = true
            }
        }

        if thisToken.isNotEmpty {
            if TerminalSymbolEnum.isTerminalSymbol( thisToken ) {
                tokenType = TokenEnum.terminal
            } else {
                tokenType = TokenEnum.qname
            }
            let symbol = TerminalSymbolEnum.translate( thisToken )
            tokenizedSource.append( ( type: tokenType, what: symbol,
                                      value: thisToken,
                                      line: lineNumber, position: argumentPosition ) )
            tokenType = TokenEnum.unknown
        }

        // Mark of the end of the file as a token
        tokenizedSource.append( ( type: .terminal, what: .endOfFile,
                                  value: "",
                                  line: lineNumber, position: 0 ) )

            if showFullMessages {
                print( "\(lineNumber) lines read" )
            }

    }
}

