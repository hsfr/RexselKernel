//
//  ExprNode+Attrib.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 24/01/2024.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-* Formal Syntax Definition -*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension AttributeNode {

    static let blockTokens: TerminalSymbolEnumSetType = TerminalSymbolEnum.attributeBlockTokens

    static let optionTokens: TerminalSymbolEnumSetType = [
        .namespace
    ]

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class AttributeNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    ///  An associate namespace for this attribute.
    fileprivate var namespaceString: String = ""

    /// Simple value (no block).
    fileprivate var valueString: String = ""

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Parsing/Generate Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse source (with tokens).
    ///
    /// - Parameters:
    ///   - compiler: the current instance of the compiler.
    /// - Throws: _RexselErrorKind.endOfFile_ if early end of file (mismatched brackets etc).

    override init()
    {
        super.init()
        thisExprNodeType = .attrib
        isLogging = true  // Adjust as required
        isInBlock = false
        setSyntax( options: ElementNode.optionTokens, elements: ElementNode.blockTokens )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Parse variable statement.
    ///
    /// ```xml
    ///   <attribute> ::= "attribute"
    ///                      <attribute name>
    ///                      ( "namespace" <name space> )?
    ///                      ( "{" <contents> "}" | <quoted text> )
    /// ```

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

        // Slide past keyword
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
                //
                // Note that the first construction here is translated to a
                // block in the output XSLT. This is not a direct reflection
                // of XSLT which only allows a block or a text content.
                //
                // attribute "name" "simple value"
                // attribute "name" namespace "URI" "simple value"
                //
                // attribute "name" { block }
                // attribute "name" namespace "URI" { block }

                case ( .terminal, .expression, _ )  where isInOptionTokens( thisCompiler.currentToken.what ) :
                    optionsDict[ thisCompiler.currentToken.what ]?.value = thisCompiler.nextToken.value
                    if optionsDict[ thisCompiler.currentToken.what ]?.count == 0 {
                        optionsDict[ thisCompiler.currentToken.what ]?.defined = thisCompiler.currentToken.line
                    }
                    // Update for name of this node
                    if thisCompiler.currentToken.what == .namespace {
                        namespaceString = thisCompiler.nextToken.value
                    }
                    optionsDict[ thisCompiler.currentToken.what ]?.count += 1
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                case ( .expression, _, _ ) where name.isEmpty
                                              && valueString.isEmpty :
                    name = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .expression, _, _ ) where name.isNotEmpty 
                                              && valueString.isEmpty :
                    valueString = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                // Block start found (no simple expression).
                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket
                                            && name.isNotEmpty
                                            && valueString.isEmpty :
                    isInBlock = true
                    thisCompiler.nestedLevel += 1
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Process Block

                case ( .terminal, _, _ ) where isInChildrenTokens( thisCompiler.currentToken.what ) && isInBlock :
                    if isLogging {
                        rLogger.log( self, .debug, "Found \(thisCompiler.currentToken.value)" )
                    }

                    markIfInvalidKeywordForThisVersion( thisCompiler )

                    let node: ExprNode = thisCompiler.currentToken.what.ExpreNodeClass
                    if self.nodeChildren == nil {
                        self.nodeChildren = [ExprNode]()
                    }
                    nodeChildren.append( node )
                    node.parentNode = self

                    // Record this node's details for later analysis.
                    let nodeLine = thisCompiler.currentToken.line

                    if childrenDict[ thisCompiler.currentToken.what ]!.count == 0 {
                        childrenDict[ thisCompiler.currentToken.what ]!.defined = nodeLine
                    }
                    childrenDict[ thisCompiler.currentToken.what ]!.count += 1

                    try node.parseSyntaxUsingCompiler( thisCompiler )
                    continue

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Exit block

                case ( .terminal, .terminal, _ ) where thisCompiler.currentToken.what == .openCurlyBracket &&
                                                       thisCompiler.nextToken.what == .closeCurlyBracket :
                    checkSyntax()
                    thisCompiler.tokenizedSourceIndex += 2
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && isInBlock :
                    checkSyntax()
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel -= 1
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && !isInBlock :
                    checkSyntax()
                    // thisCompiler.tokenizedSourceIndex += 1
                    return

                case ( .terminal, _, _ ) where isInBlockTemplateTokens( thisCompiler.currentToken.what ) && !isInBlock :
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
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel += 1
                    continue

                case ( .terminal, .terminal, _ ) where isInOptionTokens( thisCompiler.currentToken.what ) &&
                                                       isInOptionTokens( thisCompiler.nextToken.what ):
                    try markMissingItemError( what: .expression,
                                              inLine: thisCompiler.currentToken.line,
                                              after: thisCompiler.currentToken.value,
                                              skip: .toNextkeyword )
                    continue

                case ( _, _, _ ) where !isInOptionTokens( thisCompiler.currentToken.what ) && !isInBlock :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   mightBe: AttributeNode.optionTokens,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
                    continue

                case ( _, _, _ ) where !isInChildrenTokens( thisCompiler.currentToken.what ) && isInBlock :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   mightBe: AttributeNode.blockTokens,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
                    continue

                default :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   mightBe: AttributeNode.blockTokens,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
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
    ///   <attribute> ::= "attribute" <quote> <qname> <quote>
    ///                   ( "namespace" <quote> <uri-reference> <quote> )?
    ///                   (
    ///                      <quote> <alphanumeric string> <quote> |
    ///                      "{" ( <attribute block template> )+ "}"
    ///                   )
    /// ```

    override func setSyntax( options optionsList: TerminalSymbolEnumSetType, elements elementsList: TerminalSymbolEnumSetType ) {
        super.setSyntax( options: optionsList, elements: elementsList )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check the syntax that was input against that defined
    /// in _setSyntax_. Any special requirements are done here
    /// such as required combinations of keywords.

    override func checkSyntax() {
        super.checkSyntax()

        var blockElementFound = false
        for ( _, entry ) in childrenDict {
            if entry.count > 0 {
                blockElementFound = true
                break
            }
        }
        if blockElementFound && valueString.isNotEmpty {
            try? markCannotHaveBothDefaultAndBlockError( inLine: sourceLine, skip: .ignore )
        }
        if !blockElementFound && valueString.isEmpty {
            try? markDefaultAndBlockMissingError( inLine: sourceLine, skip: .ignore )
        }

        if valueString.isEmpty {
            var blockElementsPresent = false
            // Check that there are some block elements declared.
            for ( _, entry ) in childrenDict {
                if entry.count > 0 {
                    blockElementsPresent = true
                    break
                }
            }
            if !blockElementsPresent {
                markSyntaxRequiresOneOrMoreElement( inLine: sourceLine,
                                                    name: tokensDescription( TerminalSymbolEnum.blockTokens ),
                                                    inElement: self.thisExprNodeType.description )
            }
        }
   }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Semantic Checking and Symbol Table Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check duplicates etc.

    override func buildSymbolTableAndSemanticChecks( allowedTokens tokenSet: Set<TerminalSymbolEnum> ) {

        variablesDict.title = "attribute::\(name)"
        variablesDict.blockLine = sourceLine

        super.buildSymbolTableAndSemanticChecks( allowedTokens: TerminalSymbolEnum.blockTokens )

        // Set up the symbol table entries
        if let nodes = nodeChildren {
            for child in nodes {

                switch child.thisExprNodeType {

                    case .parameter, .variable :
                        do {
                            try variablesDict.addSymbol( name: child.name,
                                                         type: child.thisExprNodeType,
                                                         declaredInLine: child.sourceLine,
                                                         scope: variablesDict.title )
                            currentVariableContextList += [variablesDict]
                        } catch let err as SymbolTableError {
                            // Already in list so mark duplicate error
                            try? markDuplicateError( symbol: err.name,
                                                     declaredIn: err.declaredLine,
                                                     preciouslDelaredIn: err.previouslyDeclaredIn,
                                                     skip: .ignore )
                        } catch {
                            thisCompiler.rexselErrorList.add(
                                RexselErrorData.init( kind: RexselErrorKind
                                    .unknownError(lineNumber: child.sourceLine+1,
                                                  message: "Unknown error with adding \"\(child.name)\" to symbol table") ) )
                        }

                    default :
                        ()
                }
                child.buildSymbolTableAndSemanticChecks()
            }
        }

        // Special checks go here
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check variable scoping in value.
    ///
    /// At this stage the check for duplicates will have been run
    /// so the tables, _variableDict_ should be populated for this node.

    override func checkVariableScope( _ compiler: RexselKernel ) {
        if let nodes = nodeChildren {
            scanForVariablesInBlock( compiler, nodes )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate stylesheet tag.
    ///
    /// Output is of the form
    /// ```xml
    ///     <xsl:attribute name="elementName" namespace="...">
    ///        contents
    ///     </xsl:attribute>
    /// ```

    override func generate() -> String {
     
        let lineComment = super.generate()

        var attributes = ""
        var contents = ""

        // This should always have a value, but it will be picked up by the parser.
        if name.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.name.xml)=\"\(name)\""
        }

        for ( key, entry ) in optionsDict {
            if entry.value.isNotEmpty {
                attributes += " \(key.xml)=\"\(entry.value)\""
            }
        }


        if valueString.isNotEmpty {
            // Special case for simple value, we have to encase it in a text element.
            let textElementName = "\(thisCompiler.xmlnsPrefix)\(TerminalSymbolEnum.text.xml)"
            contents = "<\(textElementName)>\(valueString)</\(textElementName)>"
        }
        // Overwrite if there is a block
        if let children = nodeChildren {
            contents = ""
            for child in children {
                contents += " \(child.generate())\n"
            }
        }


        let thisElementName = "\(thisCompiler.xmlnsPrefix)\(thisExprNodeType.xml)"
        if contents.isEmpty {
            return "\(lineComment)<\(thisElementName) \(attributes)/>\n"
        } else {
            return "\(lineComment)<\(thisElementName) \(attributes)>\n\(contents)\n</\(thisElementName)>"
        }
    }

}
