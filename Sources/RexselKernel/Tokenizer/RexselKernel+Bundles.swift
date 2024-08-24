//
//  RexselKernel+Bundles.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 20/08/2024.
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
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// A bundle of tokenized lines keyed by the lowest
    /// line in the bundle.
    ///
    /// ```
    /// TokenizedFragmentsBundleStruct.data -> [Int: TokenizedSourceListType]
    /// ```

    struct TokenizedSourceBundleStruct {

        var id = 0
        
        var data = TokenizedSourceListType()

        var description: String {
            var msg = "[\(id)]"
            for ( type, what, numberValue, line, position ) in data {
                msg += "    [\(line):\(position)][\(type)][\(what)][\(numberValue)]"
            }
            return msg
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-** Tokenized Bundles List Actor *-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// A set of token bundles where bundle is indexed by the
    /// line number of the first line in the bundle.

    actor TokenizedBundlesListActor {

        var data: [Int: TokenizedSourceBundleStruct] = [:]

        var isEmpty: Bool {
            return data.isEmpty
        }

        var sortedData: [Int: TokenizedSourceBundleStruct] {
            let sortedBundleKeys = Array( data.keys ).sorted()
            var newData = [Int: TokenizedSourceBundleStruct]()
            for lineNumber in sortedBundleKeys {
                if let entry = data[ lineNumber ] {
                    newData[lineNumber] = entry
                }
            }
            return newData
        }

        func setBundleAt( _ key: Int, bundle bundleData: TokenizedSourceBundleStruct ) {
            data[key] = bundleData
        }

        var description: String {
            var msg = ""
            for ( key, entry ) in data {
                msg += "[\(key):\(entry.description)]"
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

    typealias TaskCompletedDictType = [ Int: TaskStatusEnum ]

    enum TaskStatusEnum: Int {
        case invalid
        case waiting
        case running
        case finished
    }

    actor TaskCompletedActor {

        /// The dictionary of which task is completed
        /// keyed by first line number in buundle.
        var taskCompletedDict = TaskCompletedDictType()

        /// Returns line number key of next free slot or
        /// zero if no free ones.
        var nextInvalidSlot: Int {
            for ( key, entry ) in taskCompletedDict {
                if entry == .invalid {
                    setTaskStatusTo( .waiting, for: key )
                    return key
                }
            }
            return 0
        }

        /// Returns number of running or waiting (not finished) tasks.
        var numberRunning: Int {
            var total = 0
            for ( _, entry ) in taskCompletedDict {
                if entry == .running || entry == .waiting {
                    total += 1
                }
            }
            return total
        }

        /// Returns number of finished tasks.
        var numberFinished: Int {
            var total = 0
            for ( _, entry ) in taskCompletedDict {
                if entry == .finished {
                    total += 1
                }
            }
            return total
        }
        
        /// Have all the tasks finished.
        var allFinished: Bool {
            // print( "Number finished: \(numberFinished):\(taskCompletedDict.count)" )
            return numberFinished == taskCompletedDict.count
        }

        /// Description for debugging.
        var description: String {
            var msg = ""
            for ( key, status ) in taskCompletedDict {
                msg += "[\(key):\(status)]"
            }
            return msg
        }
        
        // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

        func setTaskStatusTo( _ status: TaskStatusEnum, for key: Int ) {
            print( "Set task \(key) status to \(status) " )
            taskCompletedDict[key] = status
        }

        // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

        func getTaskStatusFor( _ key: Int ) -> TaskStatusEnum {
            if let status = taskCompletedDict[key] {
                return status
            } else {
                return .invalid
            }
        }
    }

}

