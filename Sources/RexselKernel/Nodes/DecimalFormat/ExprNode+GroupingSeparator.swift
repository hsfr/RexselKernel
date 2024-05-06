//
//  ExprNode+GroupingSeparator.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 21/02/2024.
//

import Foundation

class GroupingSeparatorNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Logging properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

#if HESTIA_LOGGING
    fileprivate var rLogger: RexselLogger!
#endif

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    // This needs to be a character but is held as a string
    // for error detection (warning).
    var groupingSeparatorValue: String = ""

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise Node base.

    override init() {
        super.init()
        exprNodeType = .groupingSeparator
        groupingSeparatorValue = ""

#if HESTIA_LOGGING
        rLogger = RexselLogger()
#endif
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    override func parseSyntaxUsingCompiler( _ compiler: RexselKernel ) throws {

        defer {
#if HESTIA_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif
        }

        thisCompiler = compiler
        sourceLine = thisCompiler.currentToken.line

#if HESTIA_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

        thisCompiler.tokenizedSourceIndex += 1

#if HESTIA_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

        switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

            case ( .expression, _, _ ) where thisCompiler.currentToken.value.count == 1 :
                groupingSeparatorValue = thisCompiler.currentToken.value
#if HESTIA_LOGGING
                rLogger.log( self, .debug, "Found \(TerminalSymbolEnum.decimalSeparator.description) \"\(groupingSeparatorValue)\" in line \(thisCompiler.currentToken.line)" )
#endif
                thisCompiler.tokenizedSourceIndex += 1
                return

            case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && groupingSeparatorValue.isNotEmpty :
                return

            case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                return

            case ( .expression, _, _ ) where thisCompiler.currentToken.value.count != 1 :
                groupingSeparatorValue = thisCompiler.currentToken.value
                if groupingSeparatorValue.count != 1 {
                    try markInvalidString( found: groupingSeparatorValue,
                                           insteadOf: "valid separator",
                                           inElement: .groupingSeparator,
                                           inLine: thisCompiler.currentToken.line,
                                           skip: .toNextkeyword )
                    groupingSeparatorValue = ","
                    return
                }
                groupingSeparatorValue = String( groupingSeparatorValue.removeFirst() )
#if HESTIA_LOGGING
                rLogger.log( self, .debug, "Found \(TerminalSymbolEnum.decimalSeparator.description) \"\(groupingSeparatorValue)\" in line \(thisCompiler.currentToken.line)" )
#endif
                thisCompiler.tokenizedSourceIndex += 1
                return

           default :
                try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                               inElement: exprNodeType,
                                               inLine: thisCompiler.currentToken.line )
                return

        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate attribute.
    ///
    /// Output is of the form
    /// ```xml
    ///   grouping-separator="..."
    /// ```

    override func generate() -> String {

        _ = super.generate()

       return "\(exprNodeType.xml)=\"\(groupingSeparatorValue)\""
    }

}
