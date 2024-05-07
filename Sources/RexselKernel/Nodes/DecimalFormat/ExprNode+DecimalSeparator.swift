//
//  ExprNode+DecimalSeparator.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 09/01/2024.
//

import Foundation

class DecimalSeparatorNode: ExprNode  {
    
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Logging properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    
#if REXSEL_LOGGING
    fileprivate var rLogger: RexselLogger!
#endif
    
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    
    // This needs to be a character but is held as a string
    // for error detection (warning).
    var separatorValue: String = ""

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise Node base.
    
    override init() {
        super.init()
        exprNodeType = .decimalSeparator
        separatorValue = ""

#if REXSEL_LOGGING
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
                separatorValue = thisCompiler.currentToken.value
#if REXSEL_LOGGING
                rLogger.log( self, .debug, "Found \(TerminalSymbolEnum.decimalSeparator.description) \"\(separatorValue)\" in line \(thisCompiler.currentToken.line)" )
#endif
                thisCompiler.tokenizedSourceIndex += 1
                return
                
            case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && separatorValue.isNotEmpty :
                return
                
            case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                return
                
           case ( .expression, _, _ ) where thisCompiler.currentToken.value.count != 1 :
                separatorValue = thisCompiler.currentToken.value
                if separatorValue.count != 1 {
                    try markInvalidString( found: separatorValue,
                                           insteadOf: "valid separator",
                                           inElement: .decimalSeparator,
                                           inLine: thisCompiler.currentToken.line,
                                           skip: .toNextkeyword )
                    separatorValue = ","
                    return
                }
                separatorValue = String( separatorValue.removeFirst() )
#if REXSEL_LOGGING
                rLogger.log( self, .debug, "Found \(TerminalSymbolEnum.decimalSeparator.description) \"\(separatorValue)\" in line \(thisCompiler.currentToken.line)" )
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
    ///   decimal-separator="..."
    /// ```
    
    override func generate() -> String {
        
        _ = super.generate()
        
        return "\(exprNodeType.xml)=\"\(separatorValue)\""
    }
    
}
