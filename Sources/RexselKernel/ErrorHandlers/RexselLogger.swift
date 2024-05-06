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
    fileprivate var loggerList = [String:Logger]()
#else
    fileprivate var loggerList = [String:NSObject]()
#endif

    static var loggingRequired: RexselLoggerLevelEnum = .off

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - SourceViewController Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    override init() {
        super.init()

        loggerList = [:]
    }

    public  func log( _ inClass: NSObject, _ level: RexselLoggerLevelEnum, _ msg: String = "",
                      file: StaticString = #file, line: Int = #line, function: StaticString = #function ) {

        guard RexselLogger.loggingRequired != .off && level == .debug else {
            return
        }

        let className = inClass.className

        if loggerList[ className ] == nil {
            loggerList[ className ] = inClass
        }

        if let _ = loggerList[className] {
            print( "[\(file):\(line)] [\(level)] : \(msg)" )
        }
    }

}
