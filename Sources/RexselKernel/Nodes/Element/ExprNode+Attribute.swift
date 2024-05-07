//
//  ExprNode+Attrib.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 24/01/2024.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Syntax properties
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension TerminalSymbolEnum {

    static let attributeTokens: Set<TerminalSymbolEnum> = attributeBlockTokens

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension AttributeNode {

    func setSyntax() {
        // Set up the allowed syntax. Everything can occur zero or more.
        for keyword in TerminalSymbolEnum.attributeTokens {
            let entry = AllowableSyntaxEntryStruct( child: keyword, min: 0, max: Int.max )
            allowableChildrenDict[ keyword.description ] = entry
        }
    }

    func isInAttributeTokens( _ token: TerminalSymbolEnum ) -> Bool {
        return TerminalSymbolEnum.attributeTokens.contains(token)
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: -
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
///
/// ```xml
///   <attribute> ::= "attribute" <quote> <name> <quote>
///                      ( "namespace" <uri> )?
///                      (
///                         <quote> <xpath> <quote> | "{" ( <attribute block template> )+ "}"
///                      )
/// ```

class AttributeNode: ExprNode  {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    ///  An associate namespace for this attribute.
    fileprivate var namespaceValue: String = ""

    /// Simple value (no block).
    fileprivate var value: String = ""

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
        exprNodeType = .attrib

        name = ""
        namespaceValue = ""
        value = ""
        isInBlock = false
        setSyntax()
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
#if REXSEL_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif
        }

        thisCompiler = compiler
        sourceLine = thisCompiler.currentToken.line

        // Slide past keyword
        thisCompiler.tokenizedSourceIndex += 1

        while !thisCompiler.isEndOfFile {

            var node: ExprNode!

#if REXSEL_LOGGING
            rLogger.log( self, .debug, thisCompiler.currentTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextTokenLog )
            rLogger.log( self, .debug, thisCompiler.nextNextTokenLog )
#endif
            switch ( thisCompiler.currentToken.type, thisCompiler.nextToken.type, thisCompiler.nextNextToken.type ) {

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Valid constructions
                //
                // Note that the first construction here is translated to a
                // block in the output XSLT. This is not  direct reflection
                // of XSLT which only allows a block or a text content.
                //
                // attribute "name" "simple value"
                // attribute "name" namespace "URI" "simple value"
                //
                // attribute "name" { block }
                // attribute "name" namespace "URI" { block }

                case ( .expression, _, _ ) where name.isEmpty 
                                              && value.isEmpty :
                    name = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .expression, _, _ ) where name.isNotEmpty 
                                              && value.isEmpty :
                    value = thisCompiler.currentToken.value
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket
                                            && name.isNotEmpty
                                            && value.isEmpty  :
                    isInBlock = true
                    thisCompiler.nestedLevel += 1
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                // This just deals with a "namespace" "URI" pair
                case ( .terminal, .expression, _ ) where thisCompiler.currentToken.what == .namespace  :
                    namespaceValue = thisCompiler.nextToken.value
                    if namespaceValue.count == 0 {
                        try markInvalidString( found: "",
                                               insteadOf: "valid namespace",
                                               inElement: .attrib,
                                               inLine: thisCompiler.currentToken.line )
                    }
                    thisCompiler.tokenizedSourceIndex += 2
                    continue

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // Process Block

                case ( .terminal, _, _ ) where isInAttributeTokens( thisCompiler.currentToken.what ) && isInBlock:
#if REXSEL_LOGGING
                    rLogger.log( self, .debug, "Found \(thisCompiler.currentToken.value)" )
#endif
                    node = thisCompiler.currentToken.what.ExpreNodeClass
                    if nodeChildren == nil {
                        nodeChildren = [ExprNode]()
                    }
                    nodeChildren.append( node )
                    node.parentNode = self

                    // Record this node's details for later analysis.
                    let nodeName = node.exprNodeType.description
                    let nodeLine = thisCompiler.currentToken.line

                    // The entry must exist as it was set up in the init using isInOutputTokens
                    if allowableChildrenDict[ nodeName ]!.count == 0 {
                        allowableChildrenDict[ nodeName ]!.defined = nodeLine
                    }
                    allowableChildrenDict[ nodeName ]!.count += 1

                    try node.parseSyntaxUsingCompiler( thisCompiler )
                    continue

                // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                // End Conditions

                // End of simple pair with following statement.
                case ( .terminal, _, _ ) where isInBlockTemplateTokens( thisCompiler.currentToken.what )
                                            && name.isNotEmpty 
                                            && value.isNotEmpty
                                            && nodeChildren == nil :
                    return

                // End of simple pair with following "}".
                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket
                                            && name.isNotEmpty 
                                            && value.isNotEmpty
                                            && nodeChildren == nil :
                    return

                // End of block (whether or not it is valid since we parse block anyway)
                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket
                                            && isInBlock
                                            && nodeChildren != nil :
                    thisCompiler.nestedLevel -= 1
                    thisCompiler.tokenizedSourceIndex += 1
                    return

                // Invalid constructions -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

                // No contents in block
                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .closeCurlyBracket && isInBlock && nodeChildren == nil :
                    thisCompiler.nestedLevel -= 1
                    try markDefaultAndBlockMissingError( where: thisCompiler.currentToken.line,
                                                         skip: .toNextkeyword )
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .openCurlyBracket
                                            && name.isNotEmpty && value.isNotEmpty :
                    try markCannotHaveBothDefaultAndBlockError( where: sourceLine )
                    thisCompiler.nestedLevel += 1
                    thisCompiler.tokenizedSourceIndex += 1
                    isInBlock = true
                    // Continue to parse block anyway
                    continue

                case ( .expression, .terminal, _ ) where thisCompiler.nextToken.what != .openCurlyBracket :
                    name = thisCompiler.currentToken.value
                    try markUnexpectedSymbolError( found: thisCompiler.nextToken.value,
                                                   insteadOf: "attribute value",
                                                   inElement: .attrib,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
                    return

                case ( .expression, .qname, _ ) :
                    name = thisCompiler.currentToken.value
                    try markUnexpectedSymbolError( found: thisCompiler.nextToken.value,
                                                   insteadOf: "attribute value",
                                                   inElement: .attrib,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
                    return


                case ( .terminal, _, _ ) where name.isEmpty && namespaceValue.isEmpty &&
                                               thisCompiler.currentToken.what == .namespace &&
                                               thisCompiler.nextNextToken.what == .openCurlyBracket :
                    try markMissingItemError( what: .name,
                                              inLine: thisCompiler.currentToken.line,
                                              after: exprNodeType.description )
                    thisCompiler.tokenizedSourceIndex += 1
                    continue


                case ( .terminal, _, _ ) where name.isEmpty && namespaceValue.isEmpty && thisCompiler.currentToken.what == .openCurlyBracket :
                    try markMissingItemError( what: .name, 
                                              inLine: thisCompiler.currentToken.line, 
                                              after: exprNodeType.description )
                    thisCompiler.tokenizedSourceIndex += 1
                    continue


                case ( .terminal, .terminal, _ ) where thisCompiler.currentToken.what == .namespace && thisCompiler.nextToken.what == .openCurlyBracket :
                    try markMissingItemError( what: .namespace, 
                                              inLine: thisCompiler.currentToken.line,
                                              after: TerminalSymbolEnum.attrib.description  )
                    thisCompiler.tokenizedSourceIndex += 1
                    continue

                case ( .terminal, .terminal, _ ) where thisCompiler.currentToken.what == .openCurlyBracket && thisCompiler.nextToken.what == .closeCurlyBracket :
                    // { }
                    // Empty block!
                    name = thisCompiler.currentToken.value
                    try makeCannotHaveEmptyBlockError()
                    thisCompiler.tokenizedSourceIndex += 2
                    return

                case ( .terminal, _, _ ) where thisCompiler.currentToken.what == .endOfFile :
                    return

                default :
                    try markUnexpectedSymbolError( found: thisCompiler.currentToken.value,
                                                   inElement: exprNodeType,
                                                   inLine: thisCompiler.currentToken.line,
                                                   skip: .toNextkeyword )
                    return
            }
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Check duplicates etc.

    override func buildSymbolTableAndSemanticChecks( allowedTokens tokenSet: Set<TerminalSymbolEnum> ) {

        variablesDict.title = "attribute:\(name)"
        variablesDict.blockLine = sourceLine

        super.buildSymbolTableAndSemanticChecks( allowedTokens: TerminalSymbolEnum.whenTokens )

        // Set up the symbol table entries
        if let nodes = nodeChildren {
            for child in nodes {

                switch child.exprNodeType {

                    case .parameter, .variable :
                        do {
                            try variablesDict.addSymbol( name: child.name,
                                                         type: child.exprNodeType,
                                                         declaredInLine: child.sourceLine,
                                                         scope: variablesDict.title )
                            currentVariableContextList += [variablesDict]
                        } catch let err as RexselErrorData {
                            // Already in list so mark duplicate error
                            thisCompiler.rexselErrorList.add( err )
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

    override func checkVariableScope() {

        super.checkVariableScope()

        if let nodes = nodeChildren {
            scanForVariablesInBlock( nodes )
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

        // This should always have a value, but it will be picked up by the parser.
        if name.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.name.xml)=\"\(name)\""
        }
        if namespaceValue.isNotEmpty {
            attributes += " \(TerminalSymbolEnum.namespace.xml)=\"\(namespaceValue)\""
        }

        var contents = ""

        if value.isNotEmpty {
            // We have to encase it in a text element
            let textElementName = "\(thisCompiler.xmlnsPrefix)\(TerminalSymbolEnum.text.xml)"
            contents = "<\(textElementName)>\(value)</\(textElementName)>"
        }
        // Overwrite if there is a block
        if let children = nodeChildren {
            for child in children {
                contents += " \(child.generate())\n"
            }
        }


        let thisElementName = "\(thisCompiler.xmlnsPrefix)\(exprNodeType.xml)"
        if contents.isEmpty {
            return "\(lineComment)<\(thisElementName) \(attributes)/>\n"
        } else {
            return "\(lineComment)<\(thisElementName) \(attributes)>\n\(contents)\n</\(thisElementName)>"
        }
    }

}
