//
//  ExprNode+Errors.swift
//  RexselKernel
//
//  Copyright (c) 2024 Hugh Field-Richards. All rights reserved.

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//
/// Determines which part of the source needs skipping.

enum SkipEnum {
    case absorbBlock
    case outOfBlock
    case toNextkeyword
    case toNextline
    case ignore
}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension ExprNode {

    func processSkip( _ skip: SkipEnum ) throws {
        switch skip {
            case .absorbBlock :
                try absordNextBlock()
            case .outOfBlock :
                try skipOutOfBlock()
            case .toNextkeyword :
                try skipToNextKeyword()
            case .toNextline :
                try skipToNextLine()
            case .ignore :
                ()
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Skip ouut of block to next keyword.
    ///
    /// Moves past any expressions etc.
    ///
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func skipOutOfBlock() throws {
        while true {
            thisCompiler.tokenizedSourceIndex += 1
            let theToken = thisCompiler.tokenizedSource[ thisCompiler.tokenizedSourceIndex ]
            if theToken.what == .endOfFile {
                throw RexselErrorData.init( kind: RexselErrorKind.endOfFile )
            }
            if theToken.what == .closeCurlyBracket {
                return
            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Absorbs the next block.
    ///
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func absordNextBlock() throws {
        var level = 0
        while level == 0 {
            thisCompiler.tokenizedSourceIndex += 1
            switch thisCompiler.currentToken.what {
                case .openCurlyBracket :
                    level += 1
                case .endOfFile :
                    throw RexselErrorData.init( kind: RexselErrorKind.endOfFile )
                default :
                    ()
            }
        }
        while true {
            thisCompiler.tokenizedSourceIndex += 1
            switch thisCompiler.currentToken.what {
                case .openCurlyBracket :
                    level += 1
                case .closeCurlyBracket :
                    level -= 1
                case .endOfFile :
                    throw RexselErrorData.init( kind: RexselErrorKind.endOfFile )
                default :
                    ()
            }
            if level == 0 {
                return
            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Skip to Next Keyword.
    ///
    /// Moves past any expressions etc.
    ///
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func skipToNextKeyword() throws {
        while true {
            thisCompiler.tokenizedSourceIndex += 1
            let theToken = thisCompiler.tokenizedSource[ thisCompiler.tokenizedSourceIndex ]
            if theToken.what == .endOfFile {
                throw RexselErrorData.init( kind: RexselErrorKind.endOfFile )
            }
            if theToken.type == .terminal {
                return
            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Skip to Next Line.
    ///
    /// Moves past remainder of current line.
    ///
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file}.

    func skipToNextLine() throws {
        let currentLine = thisCompiler.currentToken.line
        while currentLine == thisCompiler.tokenizedSource[ thisCompiler.tokenizedSourceIndex ].line {
            thisCompiler.tokenizedSourceIndex += 1
            if thisCompiler.isEndOfFile {
                throw RexselErrorData.init( kind: RexselErrorKind.endOfFile )
            }
        }
    }
}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension ExprNode {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark missing item.
    ///
    /// Moves past any expressions etc.
    ///
    /// - Parameters:
    ///   - what: what type of token is missing (_.openCurlyBracket_, _.name_ etc..
    ///   - inLine: the line in which the element was declared first.
    ///   - andPosition: the position in the line in which the element was declared first, defaults to 0)
    ///   - after: the element after which the error occured.
    ///   - insteadOf: what element should have been instead of the error.
    ///   - found: what element was found (as a string).
    ///   - skip: Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markMissingItemError( what: TerminalSymbolEnum,
                               inLine: Int,
                               andPosition: Int = 0,
                               after afterName: String = "",
                               insteadOf: String = "",
                               found: String = "",
                               skip: SkipEnum = .ignore ) throws {

        var theError: RexselErrorKind!

        switch what {

            case .openCurlyBracket :
                theError = .missingOpenCurlyBracket( lineNumber: inLine+1 )

            case .useAttributeSets :
                theError = .missingList( lineNumber: inLine+1, symbol: what.description )

            case .name :
                theError = .expectedName(lineNumber: inLine+1, name: afterName )

            case .test :
                theError = .missingTest(lineNumber: inLine+1 )

            case .expression :
                theError = .missingExpression(lineNumber: inLine+1, name: afterName )

            case .namespace :
                theError = .missingNamespace( lineNumber: inLine+1 )

            case .uri :
                theError = .missingURI( lineNumber: inLine+1, symbol: found )

            default :
                theError = .unknownError( lineNumber: inLine+1, message: "Can't help!" )

        }
        thisCompiler.rexselErrorList.add( RexselErrorData.init( kind: theError ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark error for unexpected expresssion found in line.
    ///
    /// - Parameters:
    ///   - inLine: the line in which the expression occurs.
    ///   - what: the expression.
    ///   - skip: Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markUnexpectedExpressionError( inLine: Int,
                                        what inWhat: String,
                                        skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .foundUnexpectedExpression( lineNumber: inLine,
                                                found: inWhat ) ) )
        try processSkip( skip )
    }


    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark error for no variable/constant value.
    ///
    /// - Parameters:
    ///   - where: the line in which the element was declared first.
    ///   - symbol: what element was found (as a string).
    ///   - skip: Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markExpectedVariableValueError( where inLine: Int,
                                         symbol inWhat: String,
                                         skip: SkipEnum = .ignore) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .missingVariableValue( lineNumber: inLine+1, name: inWhat ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parameters and variables must not have default value and block.
    ///
    /// - Parameters:
    ///   - where: the line in which the element was declared first.
    ///   - skip: Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markCannotHaveBothDefaultAndBlockError( inLine: Int,
                                                 skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData.init( kind: RexselErrorKind
                .cannotHaveBothDefaultAndBlock( lineNumber: inLine+1 ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parameters, variables, etc must have either default
    /// value or block.
    ///
    /// - Parameters:
    ///   - where: the line in which the element was declared first.
    ///   - skip: Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markDefaultAndBlockMissingError( inLine: Int,
                                          skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData.init( kind: RexselErrorKind
                .defaultAndBlockMissing( lineNumber: inLine+1 ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Has this child already been defined?
    ///
    /// To support zero or one condition.
    ///
    /// - Parameters:
    ///   - what: Element defined more than once.
    ///   - this: Where duplicate element is declared.
    ///   - where: the line in which the element was declared first.
    ///   - skip: Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markAlreadyDefined( what inWhat: TerminalSymbolEnum,
                             this inWhere: Int,
                             where inOriginal: Int,
                             skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .alreadyDeclaredIn(lineNumber: inOriginal+1, name: inWhat.description, atLine: inWhere+1 ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// There is a missing item?
    ///
    /// - Parameters:
    ///   - which: Which item is missing.
    ///   - where: the line in which the element was declared first.
    ///   - skip: Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markMissingItemError( which inWhich: String,
                               where inLine: Int,
                               skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .missingItem( lineNumber: inLine+1, what: inWhich ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Has this symbol already been defined?
    ///
    /// Subtlely different to the above. This monitors symbols
    /// but _markAlreadyDefined_ marks keywords already defined
    /// when only one should be declared.
    ///
    /// - Parameters:
    ///   - symbol: Element defined more than once.
    ///   - this: Where duplicate element is declared.
    ///   - where: the line in which the element was declared first.
    ///   - skip: Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markDuplicateError( symbol inName: String,
                             declaredIn inWhere: Int,
                             preciouslDelaredIn inOriginal: Int,
                             skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .duplicateSymbol(lineNumber: inWhere+1, name: inName, originalLine: inOriginal+1 ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark Expected Keyword Error.
    ///
    /// - Parameters:
    ///   - expected:  The expected terminal symbol.
    ///   - inElement: The element where the unknown value occurs.
    ///   - inLine:    The line in which the element is used (defaults to -1 if current line to be used).
    ///   - skip:      Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markUnknownValue( inElement: TerminalSymbolEnum,
                           found: String, insteadOf: String,
                           inLine: Int = -1,
                           skip: SkipEnum = .ignore ) throws {
        let lineNumber = ( inLine >= 0 ) ? inLine : sourceLine
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .unknownValue( lineNumber: lineNumber+1,
                                   inElement: inElement.description,
                                   found: found, insteadOf: insteadOf ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark Expected Keyword Error.
    ///
    /// - Parameters:
    ///   - expected: The expected terminal symbol.
    ///   - inElement: Which should occur in this element.
    ///   - inLine: the line in which the element is used (defaults to -1 if current line to be used).
    ///   - skip:      Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markExpectedKeywordError( expected: TerminalSymbolEnum,
                                   inElement: TerminalSymbolEnum,
                                   inLine: Int = -1,
                                   skip: SkipEnum = .ignore ) throws {
        let lineNumber = ( inLine >= 0 ) ? inLine : sourceLine
        thisCompiler.rexselErrorList.add(
            RexselErrorData.init( kind: RexselErrorKind
                .requiredElement( lineNumber: lineNumber+1,
                                  name: expected.description,
                                  inElement: inElement.description ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark error for unknown symbol.
    ///
    /// - Parameters:
    ///   - found:     The symbol/expression found.
    ///   - insteadOf: String defining what is expected.
    ///   - inElement: Which should occur in this element.
    ///   - inLine:    the line in which the element is used (defaults to -1 if current line to be used).
    ///   - skip:      Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markUnexpectedSymbolError( found: String,
                                    insteadOf: String,
                                    inLine: Int = -1,
                                    skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .foundUnexpectedSymbolInsteadOf( lineNumber: inLine+1,
                                                     found: found,
                                                     insteadOf: insteadOf,
                                                     inElement: "" ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark error for unknown symbol.
    ///
    /// - Parameters:
    ///   - what: The wayward symbol.
    ///   - insteadOf: String defining what is expected.
    ///   - inElement: Which should occur in this element.
    ///   - inLine: the line in which the element is used (defaults to -1 if current line to be used).
    ///   - skip:      Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markUnexpectedSymbolError( what: TerminalSymbolEnum,
                                    insteadOf: String,
                                    inElement: TerminalSymbolEnum,
                                    inLine: Int = -1,
                                    skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .foundUnexpectedSymbolInsteadOf( lineNumber: inLine+1,
                                                     found: what.description,
                                                     insteadOf: insteadOf,
                                                     inElement: inElement.description ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark error for unknown symbol.
    ///
    /// - Parameters:
    ///   - found:     The wayward symbol as string.
    ///   - insteadOf: String defining what is expected.
    ///   - inElement: Which should occur in this element.
    ///   - inLine:    The line in which the element is used (defaults to -1 if current line to be used).
    ///   - skip:      Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markUnexpectedSymbolError( found foundSymbol: String,
                                    insteadOf: String,
                                    inElement: TerminalSymbolEnum,
                                    inLine: Int = -1,
                                    skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .foundUnexpectedSymbolInsteadOf( lineNumber: inLine+1,
                                                     found: foundSymbol,
                                                     insteadOf: insteadOf,
                                                     inElement: inElement.description ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark error for unknown symbol.
    ///
    /// - Parameters:
    ///   - found:     The wayward symbol as string.
    ///   - inElement: Which should occur in this element.
    ///   - inLine:    The line in which the element is used (defaults to -1 if current line to be used).
    ///   - skip:      Skip to next keyword/line (defaults to _.ignore_)
    /// - throws:      _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markUnexpectedSymbolError( found foundSymbol: String,
                                    inElement: TerminalSymbolEnum,
                                    inLine: Int = -1,
                                    skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .foundUnexpectedSymbol( lineNumber: inLine+1,
                                            found: foundSymbol,
                                            inElement: inElement.description ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark error for unknown symbol.
    ///
    /// - Parameters:
    ///   - what:      The wayward symbol.
    ///   - inElement: Which should occur in this element.
    ///   - inLine:    The line in which the element is used (defaults to -1 if current line to be used).
    ///   - skip:      Skip to next keyword/line (defaults to _.ignore_)
    /// - throws:      _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markUnexpectedSymbolError( what: TerminalSymbolEnum,
                                    inElement: TerminalSymbolEnum,
                                    inLine: Int = -1,
                                    skip: SkipEnum = .ignore ) throws {
        let isReservedWord = TerminalSymbolEnum.isTerminalSymbol( what.description )
        if isReservedWord {
            thisCompiler.rexselErrorList
                .add( RexselErrorData
                    .init( kind: RexselErrorKind
                        .foundReservedWord( lineNumber: inLine+1,
                                            name: what.description,
                                            inElement: inElement.description ) ) )
        } else {
            thisCompiler.rexselErrorList
                .add( RexselErrorData
                    .init( kind: RexselErrorKind
                        .foundUnexpectedSymbol( lineNumber: inLine+1,
                                                found: what.description,
                                                inElement: inElement.description ) ) )
        }
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Expecting name (after variable, parameter, etc.).
    ///
    /// - Parameters:
    ///   - after: The keyword that needs name.
    ///   - inLine: the line in which the element is used (defaults to -1 if current line to be used).
    ///   - skip:      Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markExpectedNameError( after afterName: String,
                                inLine: Int = -1,
                                skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .expectedName( lineNumber: thisCompiler.currentToken.line+1,
                                   name: afterName ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Empty blocks not permitted.
    ///
    /// - Parameters:
    ///   - inLine: the line in which the element is used (defaults to -1 if current line to be used).
    ///   - skip:      Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func makeCannotHaveEmptyBlockError( inLine: Int = -1,
                                        skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData.init( kind: RexselErrorKind
                .emptyBlock( lineNumber: thisCompiler.currentToken.line+1 ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Empty blocks not permitted.
    ///
    /// - Parameters:
    ///   - found:     The wayward symbol as string.
    ///   - insteadOf: String defining what is expected.
    ///   - inElement: Which should occur in this element.
    ///   - inLine:    The line in which the element is used (defaults to -1 if current line to be used).
    ///   - skip:      Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markInvalidString( found foundSymbol: String,
                            insteadOf: String,
                            inElement: TerminalSymbolEnum,
                            inLine: Int = -1,
                            skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData.init( kind: RexselErrorKind
                .invalidExpression( lineNumber: thisCompiler.currentToken.line+1,
                                    found: foundSymbol,
                                    insteadOf: insteadOf,
                                    inElement: inElement.description ) ) )
        try processSkip( skip )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //

    func markSortMustBeAtStartOfBlock( within: String, at inLine: Int ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.sortMustBeFirst( lineNumber: inLine+1, within: within ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //

    func markParameterMustBeAtStartOfBlock( name: String, within: String, at inLine: Int ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.parameterMustBeFirst( lineNumber: inLine+1, name: name, within: within ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //

    func markCouldNotFindXPathVariableError( _ name: String, at inLine: Int ) {
        RexselErrorList.undefinedErrorsFlag = true
        if showUndefinedErrors {
            thisCompiler.rexselErrorList
                .add( RexselErrorData.init( kind: RexselErrorKind
                    .couldNotFindVariable( lineNumber: inLine+1, name: name ) ) )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark unknown/illegal XSLT version.
    ///

    func markInvalidXSLTVersion( _ illegalVersion: String, at inLine: Int ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.invalidXSLTVersion( lineNumber: inLine+1, version: illegalVersion ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark unknown/illegal keyword for this XSLT version.
    ///

    func markInvalidKeywordForVersion( _ illegalKeyword: String, version: String, at inLine: Int ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.invalidKeywordForVersion( lineNumber: inLine+1,
                                                                       keyword: illegalKeyword,
                                                                       version: version ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark missing expresssion in script statement.
    ///
    /// - Parameters:
    ///   - inLine:    The line in which the element is used.

    func markMissingSrcOrScript( inLine: Int ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.missingSrcOrScript( lineNumber: inLine+1 ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark duplicate expresssion in script statement.
    ///
    /// - Parameters:
    ///   - inLine:    The line in which the element is used.

    func markBothSrcAndScript( inLine: Int ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.cannotHaveBothSrcAndScript( lineNumber: inLine+1 ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark missing option (prefix or language).
    ///
    /// - Parameters:
    ///   - inLine:    The line in which the element is used.
    ///   - what:      The missing symbol.

    func markMissingScriptOption( inLine: Int, what: TerminalSymbolEnum ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.missingScriptOption( lineNumber: inLine+1,
                                                                  symbol: what.description ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark namespace declaration.
    ///
    /// Generally this is for script statements.
    ///
    /// - Parameters:
    ///   - inLine:    The line in which the element is used.
    ///   - prefix:    The missing namespace prefix.

    func missingPrefixDeclaration( inLine: Int, prefix missingPrefix: String ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.prefixNotDeclared( lineNumber: inLine+1,
                                                                prefix: missingPrefix ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark element is required.
    ///
    /// - Parameters:
    ///   - inLine:    The line in which the element is used.
    ///   - name:      The name of the missing element.
    ///   - inElement: The element it should be in.

    func markSyntaxRequiresElement( inLine: Int, name: String, inElement: String ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.syntaxRequiresElement( lineNumber: inLine+1,
                                                                    name: name,
                                                                    inElement: inElement ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark element is required.
    ///
    /// - Parameters:
    ///   - inLine:    The line in which the element is used.
    ///   - name:      The name of the missing element.
    ///   - inElement: The element it should be in.

    func markSyntaxRequiresZeroOrOneElement( inLine: Int, name: String, inElement: String ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.syntaxRequiresZeroOrOneElement( lineNumber: inLine+1,
                                                                             name: name,
                                                                             inElement: inElement ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark element is required.
    ///
    /// - Parameters:
    ///   - inLine:    The line in which the element is used.
    ///   - name:      The name of the missing element.
    ///   - inElement: The element it should be in.

    func markSyntaxRequiresZeroOrMoreElement( inLine: Int, name: String, inElement: String ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.syntaxRequiresZeroOrMoreElement( lineNumber: inLine+1,
                                                                              name: name,
                                                                              inElement: inElement ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Mark element is required.
    ///
    /// - Parameters:
    ///   - inLine:    The line in which the element is used.
    ///   - name:      The name of the missing element.
    ///   - inElement: The element it should be in.

    func markSyntaxRequiresOneOrMoreElement( inLine: Int, name: String, inElement: String ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.syntaxRequiresOneOrMoreElement( lineNumber: inLine+1,
                                                                             name: name,
                                                                             inElement: inElement ) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Cannot have elements within element.
    ///
    /// - Parameters:
    ///   - inLine:    The line in which the element is used.
    ///   - names:     Array of names.
    ///   - inElement: The element they are in.

    func markCannotHaveBothElements( inLine: Int, names: [String], inElement: String ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.syntaxCannotHaveBothElements( lineNumber: inLine, names: names, inElement: inElement) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Must have at least one of the named elements present.
    ///
    /// - Parameters:
    ///   - inLine:    The line in which the element is used.
    ///   - names:     Array of names.
    ///   - inElement: The element they are in.

    func markMustHaveAtLeastOneOfElements( inLine: Int, names: [String], inElement: String ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.syntaxMustHaveAtLeastOneOfElements( lineNumber: inLine, names: names, inElement: inElement) ) )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Must have at least one of the named elements present.
    ///
    /// - Parameters:
    ///   - inLine:    The line in which the element is used.
    ///   - option1:   First option.
    ///   - option2:   second option.
    ///   - inElement: The element they are in.

    func markCannotHaveBothOptions( inLine: Int, option1: String, option2: String, inElement: String ) {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind.cannotHaveBothOptions(lineNumber: inLine, inElement: inElement, option1: option1, option2: option2) ) )
    }

}

