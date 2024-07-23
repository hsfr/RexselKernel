//
//  ExprNode+ZeroDigit.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 21/02/2024.
//

import Foundation

class ZeroDigitNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    // This needs to be a character but is held as a string
    // for error detection (warning).
    var zeroDigitValue: String = ""

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise Node base.

    override init() {
        super.init()
        thisExprNodeType = .zeroDigit
        zeroDigitValue = ""    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    override func parseSyntaxUsingCompiler( _ compiler: RexselKernel ) throws {

        defer {
#if REXSEL_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif
        }

        thisCompiler = compiler
        sourceLine = thisCompiler.currentToken.line

#if REXSEL_LOGGING
        rLogger.log( self, .debug, thisCompiler.currentTokenLog )
        rLogger.log( self, .debug, thisCompiler.nextTokenLog )
        rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

        thisCompiler.tokenizedSourceIndex += 1

#if REXSEL_LOGGING
        rLogger.log( self, .debug, thisCompiler.currentTokenLog )
        rLogger.log( self, .debug, thisCompiler.nextTokenLog )
        rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif

        switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

            case ( .expression, _, _ ) where thisCompiler.currentToken.value.count == 1 :
                zeroDigitValue = thisCompiler.currentToken.value
#if REXSEL_LOGGING
                rLogger.log( self, .debug, "Found \(TerminalSymbolEnum.decimalSeparator.description) \"\(zeroDigitValue)\" in line \(thisCompiler.currentToken.line)" )
#endif
                thisCompiler.tokenizedSourceIndex += 1
                return

            case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && zeroDigitValue.isNotEmpty :
                return

            case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                return

            case ( .expression, _, _ ) where thisCompiler.currentToken.value.count != 1 :
                zeroDigitValue = thisCompiler.currentToken.value
                if zeroDigitValue.count != 1 {
                    try markInvalidString( found: zeroDigitValue,
                                           insteadOf: "valid zero",
                                           inElement: .zeroDigit,
                                           inLine: thisCompiler.currentToken.line,
                                           skip: .toNextkeyword )
                    zeroDigitValue = "0"
                    return
                }
                zeroDigitValue = String( zeroDigitValue.removeFirst() )
#if REXSEL_LOGGING
                rLogger.log( self, .debug, "Found \(TerminalSymbolEnum.decimalSeparator.description) \"\(zeroDigitValue)\" in line \(thisCompiler.currentToken.line)" )
#endif
                thisCompiler.tokenizedSourceIndex += 1
                return

           default :
                try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                               inElement: thisExprNodeType,
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
    ///   zero-digit="..."
    /// ```

    override func generate() -> String {

        _ = super.generate()

        return "\(thisExprNodeType.xml)=\"\(zeroDigitValue)\""
    }

}
