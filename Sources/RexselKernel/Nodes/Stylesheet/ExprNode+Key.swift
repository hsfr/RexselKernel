//
//  ExprNode+Key.swift
//  RexselKernel
//
//  Copyright 2024 Hugh Field-Richards. All rights reserved.

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Syntax properties
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension KeyNode {

    static let blockTokens: TerminalSymbolEnumSetType = []

    static let optionTokens: TerminalSymbolEnumSetType = [
        .using, .keyNodes
    ]

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class KeyNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    fileprivate var usingString: String = ""

    fileprivate var keyNodesString: String = ""

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise Node base.

    override init() {
        super.init()
        thisExprNodeType = .key
        isLogging = false  // Adjust as required
        setSyntax( options: KeyNode.optionTokens, elements: KeyNode.blockTokens )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse key statement.
    ///
    /// - Parameters:
    ///   - compiler: the current instance of the compiler.
    /// - Throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    override func parseSyntaxUsingCompiler( _ compiler: RexselKernel ) throws {

        defer {
            if isLogging {
                rLogger.log( self, .debug, thisCompiler.currentTokenLog )
                rLogger.log( self, .debug, thisCompiler.nextTokenLog )
                rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
            }
        }

        thisCompiler = compiler
        sourceLine = thisCompiler.currentToken.line

        if isLogging {
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
        }

        thisCompiler.tokenizedSourceIndex += 1

      while !thisCompiler.isEndOfFile {

          if isLogging {
              rLogger.log( self, .debug, thisCompiler.currentTokenLog )
              rLogger.log( self, .debug, thisCompiler.nextTokenLog )
              rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
          }
          
          switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

              // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
              // Valid constructions

              case ( .terminal, .expression, _ )  where isInOptionTokens( thisCompiler.currentToken.what ) :
                  optionsDict[ thisCompiler.currentToken.what ]?.value = thisCompiler.nextToken.value
                  if optionsDict[ thisCompiler.currentToken.what ]?.count == 0 {
                      optionsDict[ thisCompiler.currentToken.what ]?.defined = thisCompiler.currentToken.line
                  }
                  // Update for name of this node
                  if thisCompiler.currentToken.what == .using {
                      usingString = thisCompiler.nextToken.value
                  }
                  if thisCompiler.currentToken.what == .keyNodes {
                      keyNodesString = thisCompiler.nextToken.value
                  }
                  optionsDict[ thisCompiler.currentToken.what ]?.count += 1
                  thisCompiler.tokenizedSourceIndex += 2
                  continue

              case ( .expression, _, _ ) where name.isEmpty :
                  name = thisCompiler.currentToken.value
                  thisCompiler.tokenizedSourceIndex += 1
                  continue

              case ( .expression, _, _ ) where name.isNotEmpty :
                  // Found isolated expression due to error.
                  thisCompiler.tokenizedSourceIndex += 1
                  continue

              // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
              // Exit

              case ( .terminal, _, _ ) where isInStylesheetTemplateTokens( thisCompiler.currentToken.what ) :
                  checkSyntax()
                  return

              case ( _, _, _ ) where name.isNotEmpty && usingString.isNotEmpty && keyNodesString.isNotEmpty :
                  checkSyntax()
                  return

              // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
              // Early end of file

              case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                  return

              // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
              // Invalid constructions

              case ( .terminal, _, _ ) where isInOptionTokens( thisCompiler.currentToken.what ) &&
                                             thisCompiler.nextToken.what != .expression :
                  // Missing expression after option
                  try markMissingItemError( what: .expression,
                                            inLine: thisCompiler.currentToken.line,
                                            after: thisCompiler.currentToken.value )
                  if isInOptionTokens( thisCompiler.nextToken.what ) {
                      // There may be more options to process
                      thisCompiler.tokenizedSourceIndex += 1
                      continue
                  }
                  thisCompiler.tokenizedSourceIndex += 1
                  return

              case ( .terminal, .terminal, _ ) where isInOptionTokens( thisCompiler.currentToken.what ) &&
                                                     isInOptionTokens( thisCompiler.nextToken.what ):
                  try markMissingItemError( what: .expression,
                                            inLine: thisCompiler.currentToken.line,
                                            after: thisCompiler.currentToken.value,
                                            skip: .toNextKeyword )
                  return

              case ( _, _, _ ) where !isInOptionTokens( thisCompiler.currentToken.what ) :
                  try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                 mightBe: KeyNode.optionTokens,
                                                 inElement: thisExprNodeType,
                                                 inLine: thisCompiler.currentToken.line,
                                                 skip: .toNextToken )
                  continue

              default :
                  try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                 mightBe: KeyNode.blockTokens,
                                                 inElement: thisExprNodeType,
                                                 inLine: thisCompiler.currentToken.line,
                                                 skip: .toNextKeyword )
                  return

          }
      }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Syntax Setting/Checking
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// ```xml
    ///  <key> ::= "key" <quote> <name> <quote>
    ///                  "using" <quote> <xpath expression> <quote>
    ///                  "keyNodes" <quote> <xpath expression> <quote>
    /// ```

    override func setSyntax( options optionsList: TerminalSymbolEnumSetType, elements elementsList: TerminalSymbolEnumSetType ) {
        super.setSyntax( options: optionsList, elements: elementsList )
        for ( key, _ ) in optionsDict {
            optionsDict[ key ] = AllowableSyntaxEntryStruct( min: 1, max: 1 )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check the syntax that was input against that defined
    /// in _setSyntax_. Any special requirements are done here
    /// such as required combinations of keywords.

    override func checkSyntax() {
        super.checkSyntax()
        if name.isEmpty {
            try? markMissingItemError( what: .name,
                                       inLine: sourceLine,
                                       after: thisExprNodeType.description )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate tag.

    override func generate() -> String {

        let lineComment = super.generate()

        var attributes = ""

        if name.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.name.xml)=\"\(name)\""
        }
        for ( key, entry ) in optionsDict {
            if entry.value.isNotEmpty {
                attributes += " \(key.xml)=\"\(entry.value)\""
            }
        }

        let thisElementName = "\(thisCompiler.xmlnsPrefix)\(thisExprNodeType.xml)"
        return "\(lineComment)<\(thisElementName) \(attributes)/>\n"
    }
}
