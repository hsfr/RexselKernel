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
    //
    /// A single line from the source together with
    /// the line number.
    ///
    /// ```
    /// LineFragmentStruct.data -> ( lineNunber: Int,
    ///                              line: String )
    /// ```

    struct LineFragmentStruct {

        var data: ( lineNumber: Int, line: String ) = ( 0, "" )

        var description: String {
            return "[\(data.lineNumber):\(data.line)]"
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// A bundle of lines from the source keyed by the lowest
    /// line in the bundle.
    ///
    /// ```
    /// LineFragmentsBundleStruct.data -> [Int: LineFragmentStruct]
    /// ```

    struct LineFragmentsBundleStruct {

        var data: [Int: LineFragmentStruct] = [:]

        func existsId( _ key: Int ) -> Bool {
            return data[key] != nil
        }

        mutating func setLineAt( _ key: Int, line lineData: LineFragmentStruct ) {
            data[key] = lineData
        }

        func getLineAt( _ key: Int ) -> LineFragmentStruct? {
            guard existsId( key ) else {
                return nil
            }
            return data[key]
        }

        /// The id is the lowest of the line numbers
        var firstLineId: Int {
            if let first = Array(data.keys).min() {
                return first
            }
            return 0
        }

        var description: String {
            var msg = ""
            for ( key, line ) in data {
                msg += "[\(key):\(line.description)]"
            }
            return msg
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-* Bundle Dictionary Actor *-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// A Dictionary of bundles.
    ///
    /// Each bundle is offered to the tokenizer for processing.
    ///
    /// ```
    /// BundlesStructDictStruct.data -> [Int: LineFragmentsBundleStruct]
    /// ```

    actor BundlesDictActor{

        var data: [Int: LineFragmentsBundleStruct] = [:]

        func existsId( _ key: Int ) -> Bool {
            return data[key] != nil
        }

        func setBundleAt( _ key: Int, bundle bundleData: LineFragmentsBundleStruct ) {
            data[key] = bundleData
        }

        func getBundleAt( _ key: Int ) -> LineFragmentsBundleStruct? {
            guard existsId( key ) else {
                return nil
            }
            return data[key]
        }

        var description: String {
            var msg = ""
            for ( key, line ) in data {
                msg += "[\(key):\(line.description)]"
            }
            return msg
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-* Task Completed Actor -*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    enum TaskStatusEnum: Int {
        case invalid
        case waiting
        case running
        case finished
    }

    typealias TaskCompletedDictType = [ Int: TaskStatusEnum ]

    actor TaskCompletedActor {
        var taskCompletedDict = TaskCompletedDictType()

        func setTaskStatus( _ status: TaskStatusEnum, for key: Int ) {
            print( "Set task \(key) status to \(status) " )
            taskCompletedDict[key] = status
        }

        func getTaskStatus( for key: Int ) -> TaskStatusEnum {
            if let status = taskCompletedDict[key] {
                return status
            } else {
                return .invalid
            }
        }

        var description: String {
            var msg = ""
            for ( key, status ) in taskCompletedDict {
                msg += "[\(key):\(status)]"
            }
            return msg
        }

    }

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
    ///
    /// The source is split into a set of lines within a set of bundles.

    func tokenizeSource( ) async {

        let tokenizeTask = Task { () -> Bool in

            var success = false

            // Clear down the source string that holds the entire source
            // var sourceString = ""

            let maxNumberOfLinesInBundle = 5

            // The list of bundles, indexed by the first line number in the bundle.
            var bundleDict = BundlesDictActor()

            // The index of the bundle (starts at line 1)
            var bundleIndex = 1

            // A set of lines in a bundle
            var bundleOfLines = LineFragmentsBundleStruct()

            // Counts the number of lines in this bundle
            var bundleCount = 0

            let taskCompletedActor = TaskCompletedActor()

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
}
"""

            source.readIntoCompilerString( testSource )

            guard !source.sourceLines.isEmpty else {
                return true
            }

            while true {
                let ( nextLine, eof ) = source.getLineFromSource()
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

                if bundleCount >= maxNumberOfLinesInBundle - 1 {
                    // Reached the max number in a bundle so store bundle
                    await bundleDict.setBundleAt( bundleIndex, bundle: bundleOfLines)
                    bundleCount = 0
                    bundleOfLines = LineFragmentsBundleStruct()
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

            // For each bundle we fire off a compiler as asynchronous task.
            // Upon completion of each task there is a set of XSLT lines
            // stored as tokens.
            print( "Starting Tokenizer" )

            // Set up task completed array
            for ( key, entry ) in await bundleDict.data {
                print( "Reset task status for bundle \(key)" )
                await taskCompletedActor.setTaskStatus( .waiting, for: key )
                await tokenizeLinesTask( id: key,
                                         with: entry,
                                         list: taskCompletedActor )
            }

            print( "Finished Tokenizer" )
            return true
        }

        // Wait here for Task to finish

        var finished = false
        while !finished {
            let result = await tokenizeTask.result
            finished = ((try? result.get()) != nil)
        }

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
    ///
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

        await taskCompletedList.setTaskStatus( .running, for: key )

        tokenizedSource = TokenizedSourceListType()

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
        // All finished
        await taskCompletedList.setTaskStatus(.finished, for: key)

        //        print( "Entries before: \(RexselKernel.taskCompleted.count)" )
        //        if RexselKernel.taskCompleted.count == 1 {
        //            RexselKernel.taskCompleted = [:]
        //            print( "Set up blank list" )
        //        } else {
        //            _ = RexselKernel.taskCompleted.removeValue( forKey: key )
        //            print( "Removed \(key) from list" )
        //        }
        //        print( "Entries after: \(RexselKernel.taskCompleted.count)" )

    }

}

