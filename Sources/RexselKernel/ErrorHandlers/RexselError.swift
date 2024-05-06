//
//  RexselError.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 20/08/2014.
//  Copyright (c) 2014 Hugh Field-Richards. All rights reserved.
//

import Foundation
import Cocoa

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - RexselError Class
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
///
/// RexselError is the means to record an error in the
/// compiler source.

class RexselError: NSObject
{

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Logging properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

#if HESTIA_LOGGING
    static var masterLoggerFactory: LoggerFactory!
#endif

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    /// Where the error occurred
    var lineNumber: Int = 0
    
    /// Where in the line the error occurred
    var positionInLine: Int = 0
    
    /// Main error message
    var message: String = ""
    
    /// Possible remedy
    var suggestion: String = ""
    
    /// The type of the error
    var type: ErrorTypeEnum = .ignore

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Public Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    ///
    /// Create new error instance.
    
    init( _ inError: RexselErrorData ) {
        lineNumber = inError.line
        positionInLine = inError.position
        message = inError.kind.description
        suggestion = inError.kind.suggestion
        type = inError.type
    }
    
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    ///
    /// Produces a string message of the error. If the position in line (mPositionInLine) is zero
    /// it inhibits this out.
    ///
    /// - returns: String representation of this error.
    
   open override var description: String {
        return "\n**** \(self.message)\n     \(self.suggestion)"
    }
    
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Utilities
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

#if HESTIA_LOGGING
    static func setLoggingSystem( for className: String ) -> Logger? {
        do {
            if RexselError.masterLoggerFactory == nil {
                let embeddedConfigPath = Bundle.main.resourcePath!
                RexselError.masterLoggerFactory = LoggerFactory.sharedInstance
                try RexselError.masterLoggerFactory.configure( from: "hestia.xml", inFolder: embeddedConfigPath )
            }
            let logger = try RexselError.masterLoggerFactory.getLogger( name: className )
            return logger
        } catch let e as LoggerError {
            RexselError.displayFatalErrorAlert( e.description )
            return nil
        } catch {
            RexselError.displayFatalErrorAlert( "Unknown error when setting logging system" )
            return nil
        }
    }
#endif

#if MACOS_APP
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Display an error alert and continue.
    ///
    /// - parameter description: Error message to display
    /// - parameter suggestion: Suggestion message to display

    static func displayErrorAlert( _ inMessage: String, suggestion: String )
    {
        let alert = NSAlert()
        alert.messageText = inMessage
        alert.informativeText = suggestion
        alert.runModal()
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Display an error alert for information and then quit
    /// program.
    ///
    /// - parameter inMessage: Error message to display
    /// - parameter suggestion: Suggestion message to display

    static func displayFatalErrorAlert( _ inMessage: String, suggestion: String = "" )
    {
        let alert = NSAlert()
        alert.messageText = inMessage
        alert.informativeText = suggestion
        alert.alertStyle = NSAlert.Style.critical
        alert.addButton( withTitle: "Quit" )
        let res = alert.runModal()
        if res == NSApplication.ModalResponse.alertFirstButtonReturn {
            NSApplication.shared.terminate( nil )
        }
    }
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    static func displayErrorAlert( _ messageText: String )
    {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.runModal()
    }
#endif
    
}
