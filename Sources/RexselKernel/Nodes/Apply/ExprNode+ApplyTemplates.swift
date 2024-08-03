//
//  ExprNode+ApplyTemplates.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 30/01/2024.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-* Formal Syntax Definition -*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension ApplyTemplatesNode {

    static let blockTokens: TerminalSymbolEnumSetType = [
        .with, .sort
    ]

    static let optionTokens: TerminalSymbolEnumSetType = [
        .using, .scope
    ]

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

class ApplyTemplatesNode: ExprNode  {
    
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    
    /// "using" option. Required for creating symbol table name.
    fileprivate var usingString: String = ""

    /// "scope" option. Required for creating symbol table name.
    fileprivate var scopeString: String = ""

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Initialise Node base.
    
    override init() {
        super.init()
        thisExprNodeType = .applyTemplates
        isLogging = true  // Adjust as required
        isInBlock = false
        setSyntax( options: ApplyTemplatesNode.optionTokens, elements: ApplyTemplatesNode.blockTokens )
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
            if scopeString.isNotEmpty {
                name = "\"\(usingString)\"::\(scopeString)"
            } else {
                name = "\"\(usingString)\""
            }
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

                case ( .terminal, .expression, _ ) where isInOptionTokens( thisCompiler.currentToken.what ) :
                    optionsDict[ thisCompiler.currentToken.what ]?.value = thisCompiler.nextToken.value
                    if optionsDict[ thisCompiler.currentToken.what ]?.count == 0 {
                        optionsDict[ thisCompiler.currentToken.what ]?.defined = thisCompiler.currentToken.line
                    }
                    // Update for name of this node
                    if thisCompiler.currentToken.what == .using {
                        usingString = thisCompiler.nextToken.value
                    }
                    if thisCompiler.currentToken.what == .scope {
                        scopeString = thisCompiler.nextToken.value
                    }
                    optionsDict[ thisCompiler.currentToken.what ]?.count += 1
                    thisCompiler.tokenizedSourceIndex += 2
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
                    // Null block (error picked up in checkSyntax)
                    checkSyntax()
                    thisCompiler.tokenizedSourceIndex += 2
                    return

                case ( _, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && isInBlock :
                    checkSyntax()
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel -= 1
                    return

                case ( _, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket :
                    checkSyntax()
                    // Do not bump the index here (bracket belongs to higher block)
                    return

                case ( _, _, _ ) where !isInBlock && !isInOptionTokens( thisCompiler.currentToken.what ):
                    checkSyntax()
                    // Do not bump the index here (bracket belongs to higher block)
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Early end of file

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    return

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Invalid constructions

                case ( .expression, _, _ ) :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   insteadOf: "using or scope",
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextKeyword )
                    return

                case ( .qname, _, _ ) :
                    // The "mightBe" is a little more extensive here to catch potential possibilities.
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   mightBe: TerminalSymbolEnum.blockTokens
                                                                .union(ApplyTemplatesNode.optionTokens)
                                                                .union(ApplyTemplatesNode.blockTokens),
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
                    thisCompiler.nestedLevel += 1
                    continue

                case ( _, _, _ ) where !isInBlockTemplateTokens( thisCompiler.currentToken.what ) :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   mightBe: ApplyTemplatesNode.blockTokens,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .outOfBlock )
                    thisCompiler.tokenizedSourceIndex += 1
                    thisCompiler.nestedLevel += 1
                    continue

                default :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   mightBe: ApplyTemplatesNode.optionTokens,
                                                   inElement: thisExprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextToken )
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
    /// Set up the syntax based on the BNF.
    ///
    /// ```xml
    ///   <apply-templates> ::= "apply-templates"
    ///                             ( "using" <expression> )?
    ///                             ( "scope" <expression> )?
    ///                         "{"
    ///                             <sort>?
    ///                             <with>*
    ///                         "}"
    /// ```

    override func setSyntax( options optionsList: TerminalSymbolEnumSetType, 
                             elements elementsList: TerminalSymbolEnumSetType ) {
        super.setSyntax( options: optionsList, elements: elementsList )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check the syntax that was input against that defined
    /// in _setSyntax_. Any special reuirements are done here
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
    ///
    /// Only variable names are checked here. The variables
    /// list (_VariablesDict_) has already been formed, but no
    /// where used yet.
    
    override func buildSymbolTableAndSemanticChecks( allowedTokens tokenSet: Set<TerminalSymbolEnum> = [] ) {
        
        variablesDict.title = name
        variablesDict.tableType = thisExprNodeType
        variablesDict.blockLine = sourceLine

        super.buildSymbolTableAndSemanticChecks( allowedTokens: ApplyTemplatesNode.blockTokens )

        // Set up the symbol table entries
        if let nodes = nodeChildren {
            for child in nodes {

                switch child.thisExprNodeType {

                    case .with :
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
        
        let thisSymbolListing = variablesDict.description
        
        let separator = thisSymbolListing.isNotEmpty ? "\n" : ""
        return "\(separator)\(thisSymbolListing)\(childrenSymbols)"
    }
    
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Generate stylesheet tag.
    ///
    /// Output is of the form, but note that having a default value
    /// and a contents is ambiguous but not forbidden.
    /// ```xml
    ///     <xsl:apply-templates select="optional default XPath value" mode="name">
    ///        contents
    ///     </xsl:apply-templates>
    /// ```
    
    override func generate() -> String {
        
        let lineComment = super.generate()
        
        var attributes = ""
        var contents = ""
        
        if usingString.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.select.xml)=\"\(usingString)\""
        }
        if scopeString.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.scope.xml)=\"\(scopeString)\""
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

