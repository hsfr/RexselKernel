//
//  RexselLogger.swift
//  RexselKernel
//
//  Copyright 2024 Hugh Field-Richards. All rights reserved.
//
//  A _very_ simplistic logger that would need expanding.

import Foundation

    var rLogger = RexselLogger()

class RexselLogger: NSObject {

    public enum RexselLoggerLevelEnum {
        case trace, debug, info, warn, error, fatal, off
    }

    fileprivate var loggerList = [String:NSObject]()

    var loggingRequired: RexselLoggerLevelEnum = .debug

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

    public func log( _ inClass: NSObject = NSObject(),
                     _ level: RexselLoggerLevelEnum,
                     _ msg: String = "",
                     file: StaticString = #file,
                     line: Int = #line,
                     function: StaticString = #function ) {
        guard loggingRequired != .off && level == .debug else {
            return
        }
#if os(macOS)
        print( "[\(level)] [\(inClass.theClassName):\(function):\(line)] : \(msg)" )
#elseif os(Linux)
        let fileName = NSURL( fileURLWithPath: String( file ) ).lastPathComponent
        print( "[\(level)] [\(fileName):\(proc):\(line)] : \(msg)" )
#endif
   }

}
