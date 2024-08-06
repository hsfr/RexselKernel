//
//  RexselKernel+Parse.swift
//  RexselKernel
//
//  Copyright 2024 Hugh Field-Richards. All rights reserved.

import Foundation

extension RexselKernel {

    func parse() throws {

        // Get the first line
        tokenizedSourceIndex = 0
        guard tokenizedSource.count > 0 && !isEndOfFile else {
            return
        }

        nestedLevel = 0

        if isLogging {
            rLogger.log( structName,
                         .debug,
                         "tokenizedSourceIndex: \(tokenizedSourceIndex) [\(tokenizedSource.count)]" )
        }

        let currentToken = tokenizedSource[ tokenizedSourceIndex ]
        if isLogging {
            rLogger.log( structName, .debug, currentTokenLog )
        }

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

        if isLogging {
            rLogger.log( structName, .debug, currentTokenLog )
        }

        // All well so set this as the root of the parse tree.
        rootNode = StylesheetNode()
        // Important to set the current compiler into the parse tree.
        try? rootNode.parseSyntaxUsingCompiler( self )

        // Do a final check for correctly nested brackets at global level.
        // Check within contexts will be done locally (to be added later).
        if nestedLevel != 0 {
            if isLogging {
                rLogger.log( structName, .debug, "**** Unmatched brackets in line \(sourceLine)" )
            }

            rexselErrorList.add( RexselErrorData
                .init( kind: RexselErrorKind
                    .unmatchedBrackets( lineNumber: sourceLine + 1, level: nestedLevel ),
                       line: sourceLine + 1,
                       position: sourcePosition ) )
        }

        if isLogging {
            rLogger.log( structName, .debug, "nestedLevel: \(nestedLevel)" )
        }
        
    }


}
