//
//  RexselKernel+Tokenizer.swift
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
    ///
    /// The source is split into a set of lines within a set of bundles.
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

    func tokenizeSource( ) async {

        let tokenizeTask = Task { () -> Bool in

            /// The maximum number of source lines in each bundle.
            let maxNumberOfLinesInBundle = 5

            /// The maximum number of simultaneous bundles runnig
            /// in the _tokenizeLinesTask_.
            let maxParallelBundlesRunning = 3

            // The list of bundles, indexed by the first line number in the bundle.
            let bundleDict = BundlesDictActor()

            // The index of the bundle (starts at line 1)
            var bundleIndex = 1

            // A set of lines in a bundle
            var bundleOfLines = LineFragmentsBundleStruct()

            // Counts the number of lines in this bundle
            var bundleCount = 0

            let taskCompletedActor = TaskCompletedActor()

            tokenizedSource = TokenizedSourceListType()

            let testSource = """
stylesheet {
    version "1.0"

    match using "//list" {
       if "test" {
           text "fred"
       }
    }

    match using "//dict" {
       if "test" {
           text "bert"
       }
    }

    proc try {
        analyze-string "." regex "/dfg/" {
            matching-substring {
               text "Hello world!"
            }
            non-matching-substring {
               text "Hello world again!"
            }
            fallback {
               text "Hello world fallback!"
            }

        }
    }

}
"""

            source.readIntoCompilerString( testSource )

            guard !source.sourceLines.isEmpty else {
                return true
            }

            while true {
                let ( nextLine, eof ) = source.getLineFromSource()
                // print( "Loop start \(eof)" )
                // let ( nextLine, eof ) = source.getLineFromSourcePanel()
                var sourceLine = nextLine.line
                let sourceStringLineNumber = nextLine.index + 1
                if bundleCount == 0 {
                    // At start of a bundle so set up bundle index in list of bundles.
                    bundleIndex = sourceStringLineNumber
                }
                print( "[\(bundleIndex)][\(sourceStringLineNumber)]:  \(sourceLine)" )

                // Add newline (not strictly necessary but makes life easier later)
                sourceLine += Preset.newlineCharacter

                let lineFragment = LineFragmentStruct( data: ( lineNumber: sourceStringLineNumber,
                                                               line: sourceLine) )
                bundleOfLines.data[ sourceStringLineNumber ] = lineFragment
                // print( "--- \(bundleOfLines.data[ sourceStringLineNumber ]?.description)" )

                if bundleCount >= maxNumberOfLinesInBundle - 1 {
                    // Reached the max number in a bundle so store bundle
                    await bundleDict.setBundleAt( bundleIndex, bundle: bundleOfLines )
                    bundleCount = 0
                    bundleOfLines = LineFragmentsBundleStruct()
                    continue
                }
                bundleCount += 1
                if eof {
                    print( "Finished reading bundles" )
                    // Make sure remaining bundle is updated
                    await bundleDict.setBundleAt( bundleIndex, bundle: bundleOfLines )
                    break
                }
            }

            // At this point the entire source has been split into a set of
            // bunles of _maxNumberOfLinesInBundle_ lines in each bumdle.
            // Each bundle is indexed by the first line in the numndle.
            //
            // We do not submit all the bundles at once to the task that
            // runs the actual tokenizer (tokenizeLinesTask). Only a restricted
            // number are sent and then this maximum is continually topped
            // up as earlier tasks finish, so that there is never more than
            // _maxParallelBundlesRunning_ running at any one time.

            print( "Starting Tokenizer" )

            // Prime the task completed list
            for ( key, _ ) in await bundleDict.data {
                await taskCompletedActor.setTaskStatus( .invalid, for: key )
            }

            print( "====================" )
            // Go through each bundle and run on the task list
            // for ( _, entry ) in await bundleDict.data {
            while true {
                // Can we add this bundle to the task list?
                // The critea for this is
                //   1. Have we reached the maximum number of running tasks?
                //   2. Is there free slot?
                let numberRunning = await taskCompletedActor.numberRunning
                let numberFinished = await taskCompletedActor.numberFinished
                let allTasksFinished = await taskCompletedActor.allFinished
                print( "Number running: \(numberRunning) < \(maxParallelBundlesRunning)" )
                print( "Number finished: \(numberFinished)" )
                print( "All tasks finished: \(allTasksFinished)" )
                if allTasksFinished { break }

                if numberRunning < maxParallelBundlesRunning {
                    // OK to add so find next invalid slot
                    nextSlot = await taskCompletedActor.nextInvalidSlot
                    if nextSlot > 0 {
                        // There is a free slot
                        let entry = await bundleDict.getBundleAt( nextSlot )
                        print( "Adding next slot: \(nextSlot)" )
                        Task {
                            // Mark this task as waiting (only temporary, could be left out?)
                            await taskCompletedActor.setTaskStatus( .waiting, for: nextSlot )
                            await tokenizeLinesTaskTest( id: nextSlot,
                                                         with: entry!,
                                                         list: taskCompletedActor )
                        }
                    }
                } else {
                    // Wait here until slot free
                    print( "Waiting for slot" )
                    try? await Task.sleep(nanoseconds: 1_000_000)
                }
            }


            print( "Finished Tokenizer" )
            return true
        } // end of tokenizeTask closure

    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    func tokenizeLinesTaskTest( id key: Int,
                                with bundle: LineFragmentsBundleStruct,
                                list taskCompletedList: TaskCompletedActor ) async {
        await taskCompletedList.setTaskStatus( .running, for: key )
        try? await Task.sleep(nanoseconds: 1_00_000_000)
        await taskCompletedList.setTaskStatus( .finished, for: key )

    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// A task to tokenize a set of lines held in a bundle.
    ///
    /// The bundle is a dictionary of lines held as a tuple
    ///
    /// ```
    ///    LineFragmentStruct.data -> ( lineNunber: Int, line: String )
    /// ```
    ///
    /// and the bundle is
    ///
    /// ```
    ///     LineFragmentsBundleStruct.data -> [Int: LineFragmentStruct]
    /// ```
    /// After running the task the source should be split into a series
    /// of tokens in a bundle. For example if the source is
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
    /// - Parameters:
    ///   - id: the bundle id (normally the lowest line number)
    ///   - with: the bundle to be processed.
    ///   - list: reference to the completion list.

    func tokenizeLinesTask( id key: Int,
                            with bundle: LineFragmentsBundleStruct,
                            list taskCompletedList: TaskCompletedActor ) async {

        enum TokenizerState {
            case newToken
            case withinToken
            case withinQuote
            case withinComment
            case literalCharacter
        }

        var currentQuoteCharacter = " "
        var tokeniseState: TokenizerState = .newToken
        var argumentPosition = 0
        var characterCount = 0
        var thisToken = ""
        var lineNumber = 0
        var tokenType = TokenEnum.unknown

        isLogging = true

        await taskCompletedList.setTaskStatus( .running, for: key )

        // Clear down the source string that holds the string to analyse
        var sourceString = ""
        //print( "Start: \(timeInterval)" )

        // Get the lines from the bundle, but first sort into consecutive lines.

        let sortedLines = Array( bundle.data.keys ).sorted()

        print( sortedLines.description )

        for lineNumber in sortedLines {
            if let entry = bundle.data[ lineNumber ] {
                let thisLine = entry.data.line
                sourceString += thisLine
            }
            // print( "thisLine: [\(key)][\(thisLineNumber)]: \(thisLine)" )
            // Insert newline
            // sourceString += Preset.newlineCharacter
        }
        if isLogging {
            rLogger.log( structName, .debug, "Finished reading source from bundle")
        }
        if let firstLine = sortedLines.first {
            print( "sourceString starting at line \(firstLine): \n\(sourceString)" )
        }

        let stringLength = sourceString.count
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

            //            if isLogging {
            //                rLogger.log( structName,
            //                             .debug,
            //                             "[\(tokeniseState)] [\(currentCharacter == Preset.newlineCharacter ? "newline"  : currentCharacter )] [\(nextCharacter == Preset.newlineCharacter ? "newline"  : nextCharacter )]" )
            //            }

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

        // tokenizedSource must be put in a bundle

        // All finished
        await taskCompletedList.setTaskStatus(.finished, for: key)

    }

}

