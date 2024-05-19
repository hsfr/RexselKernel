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
    case outOfBlock
    case toNextkeyword
    case toNextline
    case ignore
}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension ExprNode {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Skip to Next Keyword.
    ///
    /// Moves past any expressions etc.
    ///
    /// - Parameters:
    ///   - what: what type os token is missing (_.openCurlyBracket_, _.name_ etc..
    ///   - inLine: the line in which the element was declared first.
    ///   - andPosition: the position in the line in which the element was declared first, defaults to 0)
    ///   - after: the element after which the error occured.
    ///   - insteadOf: what element should have been instead of the error.
    ///   - found: what element was found (as a string).
    ///   - skip: Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markMissingItemError( what: TerminalSymbolEnum,
                               inLine: Int, andPosition: Int = 0,
                               after afterName: String = "", insteadOf: String = "",
                               found: String = "",
                               skip: SkipEnum = .ignore ) throws {

        var theError: RexselErrorKind!

        switch what {

            case .openCurlyBracket :
                theError = .missingOpenCurlyBracket( lineNumber: inLine+1 )

            case .useAttributeSets :
                theError = .missingList( lineNumber: inLine+1, symbol: afterName )

            case .name :
                theError = .expectedName(lineNumber: inLine+1, name: afterName )

            case .test :
                theError = .missingTest(lineNumber: inLine+1 )

            case .expression :
                theError = .missingExpression(lineNumber: inLine+1 )

            case .namespace :
                theError = .missingNamespace( lineNumber: inLine+1 )

            case .uri :
                theError = .missingURI( lineNumber: inLine+1, symbol: found )

            default :
                theError = .unknownError( lineNumber: inLine+1, message: "Can't help!" )

        }
        thisCompiler.rexselErrorList.add( RexselErrorData.init( kind: theError ) )
        switch skip {
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
    /// Skip to Next Keyword.
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
        // Error in this line so move onto the token in the next line.
        switch skip {
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
    /// Parameters and variables must not have default value and block.
    ///
    /// - Parameters:
    ///   - where: the line in which the element was declared first.
    ///   - skip: Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markCannotHaveBothDefaultAndBlockError( where inLine: Int,
                                                 skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData.init( kind: RexselErrorKind
                .cannotHaveBothDefaultAndBlock( lineNumber: inLine+1 ) ) )
        switch skip {
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
    /// Parameters, variables and attributes must have either default
    /// value or block.
    ///
    /// - Parameters:
    ///   - where: the line in which the element was declared first.
    ///   - skip: Skip to next keyword/line (defaults to _.ignore_)
    /// - throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    func markDefaultAndBlockMissingError( where inLine: Int,
                                          skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData.init( kind: RexselErrorKind
                .defaultAndBlockMissing( lineNumber: inLine+1 ) ) )
        switch skip {
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
        switch skip {
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
    /// Has this symbol already been defined?
    ///
    /// Subtlely different to the above. This monitors symbols
    /// but _markAlreadyDefined_ marks keywords already defined
    /// when only one should be declared.
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
        switch skip {
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

    func markDuplicateError( symbol inWhat: String,
                             this inWhere: Int,
                             where inOriginal: Int,
                             skip: SkipEnum = .ignore ) throws {
        thisCompiler.rexselErrorList
            .add( RexselErrorData
                .init( kind: RexselErrorKind
                    .duplicateSymbol(lineNumber: inOriginal+1, name: inWhat, where: inWhere ) ) )
        switch skip {
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
        switch skip {
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
        switch skip {
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
        switch skip {
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
        switch skip {
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
        switch skip {
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
        switch skip {
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

        switch skip {
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
        switch skip {
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
        switch skip {
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
        switch skip {
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


}

