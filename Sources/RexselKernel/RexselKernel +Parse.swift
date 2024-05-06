//
//  RexselKernel+Parse.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 10/01/2024.
//

import Foundation

extension RexselKernel {

    mutating func parse() throws {

        // Get the first line
        tokenizedSourceIndex = 0
        guard tokenizedSource.count > 0 && !isEndOfFile else {
            return
        }

        nestedLevel = 0

#if HESTIA_LOGGING
        rLogger.log( self, .debug, "tokenizedSourceIndex: \(tokenizedSourceIndex) [\(tokenizedSource.count)]" )
#endif
        let currentToken = tokenizedSource[ tokenizedSourceIndex ]
#if HESTIA_LOGGING
        rLogger.log( self, .debug, currentTokenLog )
#endif
        // Check that the first token is the root (stylesheet). We mark this as a fatal error
        // as something is clearly wrong. Comment lines are removed by this point in
        // the tokenizer pass.
        let sourceLine = currentToken.line
        let sourcePosition = currentToken.position

        if currentToken.what != .stylesheet {
            rexselErrorList
                .add( RexselErrorData
                    .init( kind: RexselErrorKind
                        .foundUnexpectedSymbolInsteadOf( lineNumber: sourceLine+1,
                                                         found: currentToken.value,
                                                         insteadOf: "'stylesheet {...}'",
                                                         inElement: "" ) ) )
        }

#if HESTIA_LOGGING
        rLogger.log( self, .debug, currentTokenLog )
#endif
        // All well so set this as the root of the parse tree.
        rootNode = StylesheetNode()
        // Important to set the current compiler into the parse tree.
        try? rootNode.parseSyntaxUsingCompiler( self )

        // DO a final check for correctly nested brackets at global level.
        // Check within functions etc will be done locally.
        if nestedLevel != 0 {
#if HESTIA_LOGGING
            rLogger.log( self, .debug, "**** Unmatched brackets in line \(sourceLine)" )
#endif
            rexselErrorList.add( RexselErrorData.init( kind: RexselErrorKind.unmatchedBrackets( lineNumber: sourceLine + 1, level: nestedLevel ),
                                                       line: sourceLine + 1,
                                                       position: sourcePosition ) )
        }

#if HESTIA_LOGGING
        rLogger.log( self, .debug, "nestedLevel: \(nestedLevel)" )
#endif

    }


}
