//
//  RexselLogger.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 12/02/2024.
//

import Foundation

class RexselLogger: NSObject {

    public enum RexselLoggerLevelEnum {
        case trace, debug, info, warn, error, fatal, off
    }

#if HESTIA_LOGGING
    fileprivate var loggerList = [String:NSObject]()
#endif

    var loggingRequired: RexselLoggerLevelEnum = .off

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - RexselError Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    override init() {
        super.init()

        loggerList = [:]
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    public func log( _ name: String,
                     _ level: RexselLoggerLevelEnum,
                     _ msg: String = "",
                     file: StaticString = #file,
                     line: Int = #line,
                     function: StaticString = #function ) {
        guard loggingRequired != .off && level == .debug else {
            return
        }
        print( "[\(level)] [\(name):\(function):\(line)] : \(msg)" )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    public func log( _ inClass: NSObject,
                     _ level: RexselLoggerLevelEnum,
                     _ msg: String = "",
                     file: StaticString = #file,
                     line: Int = #line,
                     function: StaticString = #function ) {
        guard loggingRequired != .off && level == .debug else {
            return
        }
        print( "[\(level)] [\(inClass.className):\(function):\(line)] : \(msg)" )
    }

}
