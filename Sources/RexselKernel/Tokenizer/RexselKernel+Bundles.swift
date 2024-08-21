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
    /// A set of lines as tokens that are indexed by the first line.
    ///
    /// ```
    /// TokenizedFragmentStruct.data -> [( type: TokenEnum,
    ///                                    what: TerminalSymbolEnum,
    ///                                    value: String,
    ///                                    line: Int,
    ///                                    position: Int )]
    /// ```

    struct TokenizedFragmentStruct {

        var data: TokenizedSourceListType

        var isEmpty: Bool {
            return data.isEmpty
        }

        /// The id is the lowest of the line numbers
        var firstLineId: Int {
            guard !self.isEmpty else {
                return 0
            }
            var firstLine = Int.max
            for ( _, _, _, line, _ ) in data {
                if line < firstLine {
                    firstLine = line
                }
            }
            return firstLine
        }

        var description: String {
            var msg = ""
            for ( type, what, numberValue, line, position ) in data {
                msg += "[\(line):\(position)][\(type)][\(what)][\(numberValue)]"
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
    /// TokenizedFragmentsBundleStruct.data -> [Int: TokenizedFragmentStruct]
    /// ```

    struct TokenizedFragmentsBundleStruct {

        var data: [Int: TokenizedFragmentStruct] = [:]

        func existsId( _ key: Int ) -> Bool {
            return data[key] != nil
        }

        mutating func setFragmentAt( _ key: Int, fragment fragmentData: TokenizedFragmentStruct ) {
            data[key] = fragmentData
        }

        func getFragmentAt( _ key: Int ) -> TokenizedFragmentStruct? {
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
            for ( key, fragment ) in data {
                msg += "[\(key):\(fragment.description)]"
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

        var nextFreeSlot: Int {
            for ( key, entry ) in taskCompletedDict {
                if entry == .invalid {
                    return key
                }
            }
            return 0
        }

        var numberOfFinished: Int {
            var total = 0
            print( "Checking number finished" )
            for ( key, entry ) in taskCompletedDict {
                print( "entry \(key): \(entry)" )
                if entry == .finished {
                    total += 1
                }
            }
            print( "Number finished: \(total)" )
            return total
        }

        var allFinished: Bool {
            for ( _, entry ) in taskCompletedDict {
                if entry != .finished {
                    return false
                }
            }
            return true
        }

        var description: String {
            var msg = ""
            for ( key, status ) in taskCompletedDict {
                msg += "[\(key):\(status)]"
            }
            return msg
        }

    }

}

