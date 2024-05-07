//
//  ExprNode+StripSpace.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 24/04/2024.
//

import Foundation

class StripSpaceNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    var stripSpaceList: String = ""

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise Node base.

    override init() {
        super.init()
        exprNodeType = .stripSpace
        stripSpaceList = ""
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

        // Slide past keyword It should just be a simple expression here
        // which contains the list string.
        thisCompiler.tokenizedSourceIndex += 1

        switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

            // Valid constructions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

            case ( .expression, _, _ ) where stripSpaceList.isEmpty :
                stripSpaceList = thisCompiler.currentToken.value
                thisCompiler.tokenizedSourceIndex += 1

            // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
            // Early end of file

            case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                // Don't bother to check. End of file here is an error anyway which
                // will be picked up above this node. Almost certainly a brackets problem.
                return

            // Invalid constructions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

            case ( .terminal, _, _ ) where stripSpaceList.isEmpty :
                try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                               insteadOf: "namespace list",
                                               inElement: .stripSpace,
                                               inLine: thisCompiler.currentToken.line )
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
    /// Generate preserve space element.

    override func generate() -> String {

        let lineComment = super.generate()

        let attributes = " elements=\"\(stripSpaceList)\""
        let thisElementName = "\(thisCompiler.xmlnsPrefix)\(exprNodeType.xml)"
        guard stripSpaceList.isNotEmpty else {
            return ""
        }
        return "\(lineComment)<\(thisElementName)\(attributes)/>"
    }

}
