//
//  RexselKernel+Tokenizer.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 01/01/2024.
//

import Foundation

extension RexselKernel {

    typealias SourceLineFragmentType = [ Int: SourceLineType ]

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    ///
    /// Tokenize the source (from source panel).
    ///
    /// After running the source should be split into a series
    /// of tokens. For example if the source is
    ///
    /// ```
    /// stylesheet {
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

        // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

        enum TokenizerState {
            case newToken
            case withinToken
            case withinQuote
            case withinComment
            case literalCharacter
        }

        // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

        var stringLength = 0
        var currentQuoteCharacter = " "
        var tokeniseState: TokenizerState = .newToken
        var argumentPosition = 0
        var characterCount = 0
        var thisToken = ""
        var lineNumber = 0

        // Now scan the line to break into tokens
        var tokenType = TokenEnum.unknown
        tokenizedSource = TokenizedFileType()

        // Clear down the source string that holds the entire source
        // var sourceString = ""

        let maxNumberOfLinesInBundle = 5

        // The list of bundles, indexed by the first line number in the bundle.
        var bundleDict: [ Int: SourceLineFragmentType ] = [:]

        // The index of the bundle (starts at line 1)
        var bundleIndex = 1

        // A set of lines in a bundle
        var bundleOfLines: SourceLineFragmentType = [:]

        // Counts the number of lines in this bundle
        var bundleCount = 0

        while true {
            let ( nextLine, eof ) = source.getLineFromSourcePanel()
            var sourceLine = nextLine.line
            let sourceStringLineNumber = nextLine.index + 1
            if bundleCount == 0 {
                // At start of a bundle so set up bundle index in list of bundles.
                bundleIndex = sourceStringLineNumber
            }
            print( "[\(bundleIndex)][\(sourceStringLineNumber)]:  \(sourceLine)" )

            // Add newline (not strictly necessary but makes life easier later)
            sourceLine += Preset.newlineCharacter
            bundleOfLines[ bundleCount ] = ( sourceStringLineNumber, sourceLine )

            if bundleCount >= maxNumberOfLinesInBundle - 1 {
                // Reached the max number in a bundle so store bundle
                bundleDict[ bundleIndex ] = bundleOfLines
                bundleCount = 0
                bundleOfLines = [:]
                continue
            } 
            bundleCount += 1
            if eof {
                if isLogging {
                    rLogger.log( structName, .debug, "Finished reading bundles")
                }
                break
            }
        }

        stringLength = sourceString.count

        guard sourceString.isNotEmpty else {
            return
        }

        if isLogging {
            rLogger.log( structName, .debug, sourceString )
        }
        var idx = 0
        var finished = false

        while !finished {

            var currentCharacter = sourceString[idx]
            let nextCharacter = ( idx + 1 < stringLength  ) ? sourceString[idx+1] : ""
            // print( "while start [\(currentCharacter)][\(nextCharacter)]: \(timeInterval)" )

            // Sort out any "smart" quotes and make them dumb.
            switch currentCharacter {
                case "“", "”":
                    currentCharacter = Preset.doubleQuoteCharacter
                case "‘", "’":
                    currentCharacter = Preset.singleQuoteCharacter
                default:
                    ()
            }

            if isLogging {
                rLogger.log( structName,
                             .debug,
                             "[\(tokeniseState)] [\(currentCharacter == Preset.newlineCharacter ? "newline"  : currentCharacter )] [\(nextCharacter == Preset.newlineCharacter ? "newline"  : nextCharacter )]" )
            }

            switch ( tokeniseState, currentCharacter, nextCharacter ) {

                    // Newlines and spaces

                case ( .newToken, _, _ ) where Preset.whiteSpace.contains( currentCharacter ) :
                    // Ignore leading spaces
                    thisToken = ""

                case ( .withinToken, _, _ ) where Preset.whiteSpace.contains( currentCharacter ) :
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

                case ( .withinToken, _, _ ) where Preset.quoteCharacters.contains( currentCharacter ) :
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

                case ( _, Preset.newlineCharacter, _ ) where tokeniseState != .withinQuote :
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

                case ( _, Preset.newlineCharacter, _ ) where tokeniseState == .withinQuote :
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

                case ( .withinQuote, Preset.doubleQuoteCharacter, _ ) where currentCharacter == currentQuoteCharacter,
                    ( .withinQuote, Preset.singleQuoteCharacter, _ ) where currentCharacter == currentQuoteCharacter :
                    // End of quotation (expression etc) so store it away
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

                case ( .withinQuote, Preset.literalCharacterPrefix, _ ):
                    tokeniseState = .literalCharacter

                case ( .withinQuote, _, _ ):
                    thisToken.append( currentCharacter )
                    tokeniseState = .withinQuote

                    // Tokens

                case ( .newToken, Preset.tabCharacter, _ ), ( .newToken, Preset.spaceCharacter, _ ) :
                    // Ignore leading spaces
                    thisToken = ""

                case ( .newToken, Preset.doubleQuoteCharacter, _ ), ( .newToken, Preset.singleQuoteCharacter, _ ) :
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

                case ( .withinToken, Preset.openCurlyBracket, _ ), ( .withinToken, Preset.closeCurlyBracket, _ ) :
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
                    if currentCharacter == Preset.closeCurlyBracket {
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

    func tokenizeSource1( ) {

      var timeInterval: Double {
            let now = Date().microsecondsSince1970
            let interval = now - timeSnapshot
            timeSnapshot = now
            return interval
        }

        enum TokenizerState {
            case newToken
            case withinToken
            case withinQuote
            case withinComment
            case literalCharacter
        }

        var timeSnapshot = Date().timeIntervalSince1970
        let startTime = Date().microsecondsSince1970

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
        //print( "Start: \(timeInterval)" )

        while true {
            let ( nextLine, eof ) = source.getLineFromSourcePanel()
            sourceString += nextLine.line
            // print( "sourceString: \(timeInterval)" )
            // Insert newline
            sourceString += newlineCharacter
            if eof {
                if isLogging {
                    rLogger.log( structName, .debug, "Finished reading source")
                }
                break
            }
        }

        stringLength = sourceString.count

        guard sourceString.isNotEmpty else {
            return
        }

        if isLogging {
            rLogger.log( structName, .debug, sourceString )
        }
        var idx = 0
        var finished = false

        while !finished {

            var currentCharacter = sourceString[idx]
            let nextCharacter = ( idx + 1 < stringLength  ) ? sourceString[idx+1] : ""
            // print( "while start [\(currentCharacter)][\(nextCharacter)]: \(timeInterval)" )

            // Sort out any "smart" quotes and make them dumb.
            switch currentCharacter {
                case "“", "”":
                    currentCharacter = doubleQuoteCharacter
                case "‘", "’":
                    currentCharacter = singleQuoteCharacter
                default:
                    ()
            }

            if isLogging {
                rLogger.log( structName,
                             .debug,
                             "[\(tokeniseState)] [\(currentCharacter == newlineCharacter ? "newline"  : currentCharacter )] [\(nextCharacter == newlineCharacter ? "newline"  : nextCharacter )]" )
            }

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
                    // End of quotation (expression etc) so store it away
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

        //let finishTime = Date().microsecondsSince1970

        //print( "startTime: \(startTime)" )
        //print( "finishTime: \(finishTime)" )
        //print( "total: \(finishTime - startTime)" )

    }
}

