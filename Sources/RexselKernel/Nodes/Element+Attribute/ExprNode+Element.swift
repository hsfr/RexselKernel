//
//  ExprNode+Element.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 22/01/2024.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-* Formal Syntax Definition -*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension ElementNode {

    static let blockTokens: TerminalSymbolEnumSetType = TerminalSymbolEnum.blockTokens

    static let optionTokens: TerminalSymbolEnumSetType = [
        .namespace, .useAttributeSets
    ]

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class ElementNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    /// Name of this element that will appear in the XSLT.
    fileprivate var elementName: String = ""

    /// The associated namespace for this element if not given explitly in the name.
    fileprivate var namespaceString: String = ""

    /// The attributes sets to use (space separated list of attributeSet names).
    fileprivate var useAttributeSetsString: String = ""

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise Node base.

    override init()
    {
        super.init()
        thisExprNodeType = .element
        isLogging = true  // Adjust as required
        isInBlock = false
        setSyntax( options: ElementNode.optionTokens, elements: ElementNode.blockTokens )
  }

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

    override func parseSyntaxUsingCompiler( _ compiler: RexselKernel ) throws {

        defer {
            name = elementName
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

                case ( .terminal, .expression, _ )  where isInOptionTokens( thisCompiler.currentToken.what ) :
                    optionsDict[ thisCompiler.currentToken.what ]?.value = thisCompiler.nextToken.value
                    if optionsDict[ thisCompiler.currentToken.what ]?.count == 0 {
                        optionsDict[ thisCompiler.currentToken.what ]?.defined = thisCompiler.currentToken.line
                    }
                    // Update for name of this node
                    if thisCompiler.currentToken.what == .namespace {
                        namespaceString = thisCompiler.nextToken.value
                    }
                    if thisCompiler.currentToken.what == .useAttributeSets {
                        useAttributeSetsString = thisCompiler.nextToken.value
                    }
                    optionsDict[ thisCompiler.currentToken.what ]?.count += 1
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                case ( .expression, _, _ ) where elementName.isEmpty :
                    elementName = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket &&
                                                       thisCompiler.nextToken.what != .closeCurlyBracket :
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel += 1
                    isInBlock = true
                    continue

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Process block

                case ( .terminal, _, _ ) where isInChildrenTokens( thisCompiler.currentToken.what ) && isInBlock :
                    if isLogging {
                        rLogger.log( self, .debug, "Found \(thisCompiler.currentToken.value)" )
                    }

                    _ = markIfInvalidKeywordForThisVersion( thisCompiler )

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
                    thisCompiler.tokenizedSourceIndex += 1
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Early end of file

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Invalid constructions

                case ( _, _, _ ) where !isInChildrenTokens( thisCompiler.currentToken.what ) && isInBlock :
                    // Illegal keyword
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   mightBe: ElementNode.blockTokens,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextKeyword )
                    continue

                case ( .terminal, _, _ ) where isInOptionTokens( thisCompiler.currentToken.what ) &&
                                               thisCompiler.nextToken.what != .expression :
                    // Missing expression after option
                    try markMissingItemError( what: .expression,
                                              inLine: thisCompiler.currentToken.line,
                                              after: thisCompiler.currentToken.value )
                    thisCompiler.tokenizedSourceIndex += 1
                    // thisCompiler.nestedLevel += 1
                    continue

                case ( .terminal, .terminal, _ ) where isInOptionTokens( thisCompiler.currentToken.what ) &&
                                                       isInOptionTokens( thisCompiler.nextToken.what ):
                    try markMissingItemError( what: .expression,
                                              inLine: thisCompiler.currentToken.line,
                                              after: thisCompiler.currentToken.value,
                                              skip: .toNextKeyword )
                    continue

                case ( _, _, _ ) where !isInBlock :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   insteadOf: "start of block bracket",
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line )
                    // Assume block start to process potential block
                    isInBlock = true
                    continue

                case ( _, _, _ ) where !isInOptionTokens( thisCompiler.currentToken.what ) && !isInBlock :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   mightBe: ElementNode.optionTokens,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextKeyword )
                    continue

                case ( _, _, _ ) where !isInChildrenTokens( thisCompiler.currentToken.what ) && isInBlock :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   mightBe: ElementNode.blockTokens,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextKeyword )
                    continue

                default :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   mightBe: ElementNode.blockTokens,
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
    ///   <element> ::= "element" <quote> <element name> <quote>
    ///                      ( "namespace" <name space> )?
    ///                      ( "use-attribute-sets" <expression> )?
    ///                      ( "{" <block templates> "}" )?
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
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Semantic Checking and Symbol Table Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check duplicates.

    override func buildSymbolTableAndSemanticChecks( allowedTokens tokenSet: Set<TerminalSymbolEnum> ) {

        variablesDict.title = name
        variablesDict.tableType = thisExprNodeType
        variablesDict.blockLine = sourceLine

        super.buildSymbolTableAndSemanticChecks( allowedTokens: ElementNode.blockTokens )

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
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check variable scoping in enclosed withNodes.

    override func checkVariableScope( _ compiler: RexselKernel ) {
        // We must scan for variables in use-attribute-sets
        super.scanVariablesInNodeValue( useAttributeSetsString,
                                        usingPrefix: false,
                                        inLine: sourceLine )

        if let nodes = nodeChildren {
            scanForVariablesInBlock( compiler, nodes )
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate a list of symbols for this node.

    override func symbolListing() -> String {
        var childrenSymbols = ""
        if let nodes = nodeChildren {
            for child in nodes {
                childrenSymbols += child.symbolListing()
            }
        }
        return childrenSymbols
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate stylesheet tag.
    ///
    /// Output is of the form, but note that having a default value
    /// and a contents is ambiguous but not forbidden.
    /// ```xml
    ///     <xsl:element name="elementName" use-attribute-sets="..." namespace="...">
    ///        contents
    ///     </xsl:element>
    /// ```

    override func generate() -> String {

        let lineComment = super.generate()

        var attributes = ""
        var contents = ""

        if elementName.isNotEmpty {
            attributes += " name=\"\(elementName)\""
        }

        for ( key, entry ) in optionsDict {
            if entry.value.isNotEmpty {
                attributes += " \(key.xml)=\"\(entry.value)\""
            }
        }

        if let children = nodeChildren {
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
