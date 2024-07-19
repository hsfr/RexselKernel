//
//  String+Tokenizer.swift
//  rexsel
//
//  Created by Hugh Field-Richards on 23/12/2023.
//  Copyright © 2022 Hugh Field-Richards. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation


// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Token Class Enumerator
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

/// This defines the type of the token
///
/// - *terminal*: a keyword such as "stylesheet", "element", "function", etc.
/// - *qname* : a qualified name used within elements etc.
/// - *expression* : for all quoted tokens.
/// - *unknown* : none of the above!

enum TokenEnum {
    case terminal
    case qname
    case expression
    case unknown
}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Version Ranges
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//
/// Defines the token ran for a particular version.
///
/// The _min_ value is not really needed as it should
/// always be "1".

// Global properties start with "rexsel_".
typealias rexsel_minMaxVersionType = ( min: Int, max: Int )

let rexsel_xsltversion10 = "1.0"
let rexsel_xsltversion11 = "1.1"
let rexsel_xsltversion20 = "2.0"
let rexsel_xsltversion30 = "3.0"
let rexsel_xsltversion40 = "4.0"

// These are somewhat arbitrary values for the
// enumeration TerminalSymbolEnum
let rexsel_versionRange: [String: rexsel_minMaxVersionType ] = [
    rexsel_xsltversion10: ( 1, 199 ),
    rexsel_xsltversion11: ( 1, 399 ),
    rexsel_xsltversion20: ( 1, 599 ),
    rexsel_xsltversion30: ( 1, 799 ),
    rexsel_xsltversion40: ( 1, 999 )
]

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Terminal Symbol Enumerator
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//
/// A list of the terminal symbols in the syntax.
///
/// This may be an incomplete list! Not all the terminal symbols
/// have descriptions etc. They also define Rexsel keywords rather
/// than the XSLT elements.

enum TerminalSymbolEnum: Int {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // Version 1.0 keywords/tokens
    case stylesheet = 1
    case version, id, excludeResultPrefixes, extensionElementPrefixes
    case key, keyNodes

    case xmlns

    case select
    case parameter, variable
    case proc, match
    case using, scope, priority

    case call, with

    case applyImports, applyTemplates
    case sort

    case includeSheet,importSheet
    case href

    case text,textcontent

    case valueOf
    case disableOutputEscaping
    case comment

    case output
    case method, xmlMethod, htmlMethod, textMethod
    case encoding
    case cdataList
    case omitXmlDecl, includeXmlDecl
    case standAlone
    case doctypePublic, doctypeSystem
    case stripSpace, preserveSpace
    case indent, yes, no
    case mediaType

    case number
    case decimalFormat

    case decimalSeparator
    case groupingSeparator
    case infinity
    case minusSign
    case notNumber
    case percent
    case perMille
    case zeroDigit
    case digit
    case patternSeparator
    case count
    case level
    case from
    case numberValue
    case format
    case letterValue, alphabetic, traditional
    case groupingSize
    case singleLevel, multipleLevel, anyLevel

    case choose, when, otherwise, test
    case foreach

    case element
    case fallback
    case name, namespace, useAttributeSets
    case attrib, attributeSet

    case ifCondition

    case copy
    case copyOf
    case message, terminate
    case namespaceAlias, mapFrom, mapTo

    case openBracket
    case closeBracket
    case openCurlyBracket
    case closeCurlyBracket

    case processingInstruction

    case lang
    case order
    case ascending, descending
    case caseOrder
    case upperFirst, lowerFirst
    case dataType
    case textSort, numberSort

    case rcomment // Comments in the Rexsel, not the comment keyword

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // Version 1.1 keywords/tokens
    case script = 200
    case src
    case prefix
    case archive
    // Not the same as "lang". The latter refers to a linguistic language.
    // This one refers to a programming language.
    case language

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // Version 2.0 keywords/tokens
    case analyzeString = 400
    case regex
    case flags
    case matchingSubstring
    case nonMatchingSubstring
    case nextMatch
    case performSort

    case characterMap
    case useCharacterMaps
    case outputCharacter
    case character
    case characterString

    case function
    case fAs
    case fOverride
    
    case importSchema
    case location

    case document
    case resultDocument
    case strict
    case lax
    case preserve
    case strip

    case forEachGroup
    case groupBy
    case groupAdjacent
    case groupStartingWith
    case groupEndingWith
    case collation

    case omit
    case sequence

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // Not source tokens but general types
    case expression = 10000
    case string
    case qname
    case unknownToken

    // At present a convenience for later
    case endOfLine

    // Use this to prevent overrun on the token index
    case endOfFile

    // A convenience for error reporting
    case uri

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Associated ExprNode
    //
    /// The associated Node class linked to the terminal symbols that
    /// represent elements/attributes
    var ExpreNodeClass: ExprNode! {
        switch self {
            case .stylesheet : return StylesheetNode()
            case .version : return VersionNode()
            case .id : return IdNode()
            case .xmlns : return XmlnsNode()
            case .preserveSpace : return PreserveSpaceNode()
            case .stripSpace : return StripSpaceNode()
            case .key : return KeyNode()

            case .parameter : return ParameterNode()
            case .variable : return VariableNode()
            case .valueOf : return ValueOfNode()
            case .text : return TextNode()
            case .comment : return CommentNode()

            case .number : return NumberNode()
            case .output : return OutputNode()

            case .method : return MethodNode()
            case .indent : return IndentNode()
            case .encoding : return EncodingNode()
            case .cdataList : return CDataNode()
            case .omitXmlDecl : return OmitXMLDeclarationNode()
            case .standAlone : return StandAloneNode()
            case .doctypePublic : return DocTypePublicNode()
            case .doctypeSystem : return DocTypeSystemNode()

            case .count : return CountNode()
            case .level : return LevelNode()
            case .from : return FromNode()
            case .numberValue : return ValueNode()
            case .format : return FormatNode()
            case .letterValue : return LetterValueNode()
            case .groupingSize : return GroupingSizeNode()

            case .decimalFormat : return DecimalFormatNode()
            case .decimalSeparator : return DecimalSeparatorNode()
            case .groupingSeparator : return GroupingSeparatorNode()
            case .infinity : return InfinityNode()
            case .minusSign : return MinusSignNode()
            case .notNumber : return NaNNode()
            case .percent : return PercentNode()
            case .perMille : return PerMilleNode()
            case .zeroDigit : return ZeroDigitNode()
            case .digit : return DigitNode()
            case .patternSeparator : return PatternSeparatorNode()
            case .lang : return LangNode()

            case .applyImports : return ApplyImportsNode()
            case .applyTemplates : return ApplyTemplatesNode()
            case .sort : return SortNode()

            case .call : return CallNode()
            case .with : return WithNode()

            case .element : return ElementNode()
            case .fallback : return FallbackNode()
            case .processingInstruction : return ProcessingInstructionNode()
            case .attrib : return AttributeNode()
            case .attributeSet : return AttributeSetNode()

            case .ifCondition : return IfNode()
            case .choose : return ChooseNode()
            case .when : return WhenNode()
            case .otherwise : return OtherwiseNode()
            case .foreach : return ForeachNode()

            case .proc : return ProcNode()
            case .match : return MatchNode()

            case .includeSheet : return IncludeNode()
            case .importSheet : return ImportNode()

            case .copy : return CopyNode()
            case .copyOf : return CopyOfNode()
            case .message : return MessageNode()
            case .namespaceAlias : return NamespaceAliasNode()

            case .script : return ScriptNode()

            case .analyzeString : return AnalyzeStringNode()
            case .matchingSubstring : return MatchingSubstringNode()
            case .nonMatchingSubstring : return NonMatchingSubstringNode()


            default:
                // Anything else returns nil
                return nil
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Enumerator Descriptions
    //
    /// The string associated with each symbol
    ///
    /// Used for debugging and error messages.
    var description: String {
        switch self {
            case .stylesheet : return "stylesheet"
            case .extensionElementPrefixes : return "extension-element-prefixes"
            case .version : return "version"
            case .id : return "id"
            case .key : return "key"
            case .keyNodes : return "keyNodes"
            case .excludeResultPrefixes : return "exclude-result-prefixes"
            case .xmlns : return "xmlns"

            case .parameter : return "parameter"
            case .variable : return "variable"

            case .valueOf : return "value"
            case .comment : return "comment"

            case .text : return "text"
            case .textcontent : return "textcontent"

            case .number : return "number"
            case .output : return "output"

            case .method : return "method"
            case .xmlMethod : return "xml"
            case .htmlMethod : return "html"
            case .textMethod : return "text"
            case .encoding : return "encoding"
            case .cdataList : return "cdata"
            case .omitXmlDecl : return "omit-xml-declaration"
            case .includeXmlDecl : return "include-xml-declaration"
            case .standAlone : return "standalone"

            case .count : return "count"
            case .level : return "level"
            case .from : return "from"
            case .numberValue : return "value"
            case .format : return "format"
            case .letterValue : return "letter-value"
            case .groupingSize : return "grouping-size"
            case .singleLevel : return "single"
            case .multipleLevel : return "multiple"
            case .anyLevel : return "any"
            case .alphabetic : return "alphabetic"
            case .traditional : return "traditional"

            case .decimalFormat : return "decimal-format"
            case .decimalSeparator : return "decimal-separator"
            case .groupingSeparator : return "grouping-separator"
            case .infinity : return "infinity"
            case .minusSign : return "minus-sign"
            case .notNumber : return "NaN"
            case .percent : return "percent"
            case .perMille : return "per-mille"
            case .zeroDigit : return "zero-digit"
            case .digit : return "digit"
            case .patternSeparator : return "pattern-separator"

            case .stripSpace : return "strip-space"
            case .preserveSpace : return "preserve-space"
            case .indent : return "indent"
            case .yes : return "yes"
            case .no : return "no"
            case .mediaType : return "media-type"
            case .doctypePublic : return "doctype-public"
            case .doctypeSystem : return "doctype-system"

            case .call : return "call"
            case .with : return "with"

            case .element : return "element"
            case .fallback : return "fallback"
            case .namespace : return "namespace"
            case .useAttributeSets : return "use-attribute-sets"

            case .attrib : return "attribute"
            case .attributeSet : return "attribute-set"

            case .proc : return "proc"
            case .match : return "match"
            case .using : return "using"
            case .scope : return "scope"
            case .priority : return "priority"

            case .ifCondition : return "if"
            case .choose : return "choose"
            case .when : return "when"
            case .otherwise : return "otherwise"
            case .foreach : return "foreach"

            case .applyImports : return "apply-imports"
            case .applyTemplates : return "apply-templates"
            case .sort : return "sort"

            case .copy : return "copy"
            case .copyOf : return "copy-of"

            case .includeSheet : return "include"
            case .importSheet : return "import"

            case .openBracket : return "("
            case .closeBracket : return ")"
            case .openCurlyBracket : return "{"
            case .closeCurlyBracket : return "}"

            case .rcomment : return "//"
            case .message : return "message"
            case .terminate : return "terminate"

            case .namespaceAlias : return "namespace-alias"
            case .mapFrom : return "map-from"
            case .mapTo : return "to"

            case .processingInstruction : return "processing-instruction"

            case .lang : return "lang"
            case .order : return "order"
            case .ascending : return "ascending"
            case .descending : return "descending"
            case .caseOrder : return "case-order"
            case .upperFirst : return "upper-first"
            case .lowerFirst : return "lower-first"
            case .dataType : return "data-type"
            case .textSort : return "text-sort"
            case .numberSort : return "number-sort"

            // Version 1.1

            case .script : return "script"
            case .src : return "src"
            case .prefix : return "prefix"
            case .language : return "language"
            case .archive : return "archive"

            // Version 2.0

            case .analyzeString : return "analyze-string"
            case .regex : return "regex"
            case .flags : return "flags"
            case .matchingSubstring : return "matching-substring"
            case .nonMatchingSubstring : return "non-matching-substring"

            // Non XSLT version

            case .expression : return "expression"
            case .string : return "string"
            case .qname : return "QName"

            default :
                // If not in the list will indicte a non-terminal symbol
                return ""

        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Output Symbol Type table types
    ///
    /// Parameters and variables are considered the same
    /// when checking duplicates etc. The difference here
    /// is purely cosmetic and helps with the symbol table
    /// output.
    var symbolType: String {
        switch self {
            case .with : return "P"
            case .parameter : return "P"
            case .attributeSet : return "A"
            case .variable : return "V"
            case .proc : return "F"  // This may be changed later
            case .match : return "M"
            default : return "?"
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Output XML for each element/attribute
    //
    /// The actual XML element/attribute to be output.
    ///
    /// These are notionally the same as the description.
    var xml: String {
        switch self {
            case .stylesheet : return "stylesheet"
            case .extensionElementPrefixes : return "extension-element-prefixes"
            case .version : return "version"
            case .id : return "id"
            case .key : return "key"
            case .keyNodes : return "use"
            case .excludeResultPrefixes : return "exclude-result-prefixes"

            case .select : return "select"

            case .parameter : return "param"
            case .variable : return "variable"

            case .text : return "text"
            case .comment : return "comment"
            case .valueOf : return "value-of"
            case .disableOutputEscaping : return "disable-output-escaping"

            case .output : return "output"
            case .method : return "method"
            case .xmlMethod : return "xml"
            case .htmlMethod : return "html"
            case .textMethod : return "text"
            case .encoding : return "encoding"
            case .cdataList : return "cdata"
            case .omitXmlDecl : return "omit-xml-declaration"
            case .includeXmlDecl : return "include-xml-declaration"
            case .standAlone : return "standalone"

            case .decimalFormat : return "decimal-format"
            case .decimalSeparator : return "decimal-separator"
            case .groupingSeparator : return "grouping-separator"
            case .infinity : return "infinity"
            case .minusSign : return "minus-sign"
            case .notNumber : return "NaN"
            case .percent : return "percent"
            case .perMille : return "per-mille"
            case .zeroDigit : return "zero-digit"
            case .digit : return "digit"
            case .patternSeparator : return "pattern-separator"

            case .includeSheet : return "include"
            case .importSheet : return "import"
            case .href : return "href"

            case .stripSpace : return "strip-space"
            case .preserveSpace : return "preserve-space"
            case .indent : return "indent"
            case .yes : return "yes"
            case .no : return "no"
            case .mediaType : return "media-type"
            case .doctypePublic : return "doctype-public"
            case .doctypeSystem : return "doctype-system"

            case .count : return "count"
            case .level : return "level"
            case .from : return "from"
            case .numberValue : return "value"
            case .format : return "format"
            case .letterValue : return "letter-value"
            case .groupingSize : return "grouping-size"
            case .singleLevel : return "single"
            case .multipleLevel : return "multiple"
            case .anyLevel : return "any"
            case .alphabetic : return "alphabetic"
            case .traditional : return "traditional"

            case .proc : return "template"
            case .using : return "match"
            case .match : return "template"
            case .scope : return "mode"
            case .priority : return "priority"

            case .applyImports : return "apply-imports"
            case .applyTemplates : return "apply-templates"

            case .call : return "call-template"
            case .with : return "with-param"
            case .sort : return "sort"

            case .element : return "element"
            case .fallback : return "fallback"
            case .name : return "name"
            case .namespace : return "namespace"
            case .useAttributeSets : return "use-attribute-sets"
            case .attrib : return "attribute"
            case .attributeSet : return "attribute-set"

            case .ifCondition : return "if"
            case .choose : return "choose"
            case .when : return "when"
            case .otherwise : return "otherwise"
            case .test : return "test"
            case .foreach : return "for-each"

            case .copy : return "copy"
            case .copyOf : return "copy-of"

            case .lang : return "lang"
            case .order : return "order"
            case .ascending : return "ascending"
            case .descending : return "descending"
            case .caseOrder : return "case-order"
            case .upperFirst : return "upper-first"
            case .lowerFirst : return "lower-first"
            case .dataType : return "data-type"
            case .textSort : return "text"
            case .numberSort : return "number"

            case .rcomment : return "comment"
            
            case .message : return "message"
            case .terminate : return "terminate"

            case .namespaceAlias : return "namespace-alias"
            case .mapFrom : return "stylesheet-prefix"
            case .mapTo : return "result-prefix"

            case .processingInstruction : return "processing-instruction"
            case .number : return "number"

            // Version 1.1

            case .script : return "script"
            case .src : return "src"
            case .prefix : return "implements-prefix"
            case .language : return "language"
            case .archive : return "archive"

            // Version 2.0

            case .analyzeString : return "analyze-string"
            case .regex : return "regex"
            case .flags : return "flags"
            case .matchingSubstring : return "matching-substring"
            case .nonMatchingSubstring : return "non-matching-substring"

            case .qname : return "name"

            default : return ""
        }
    }

    /// Is current symbol a terminal symbol
    var isTerminalSymbol: Bool {
        return self.description.isNotEmpty
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*- CLASS FUNCTIONS -*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// A function to return the enumeration based on a found string.
    ///
    /// Used to translate from the input stream to form the correct token case.

    static func translate( _ token: String ) -> TerminalSymbolEnum {
        switch token {
            case "stylesheet" : return .stylesheet
            case "extension-element-prefixes" : return .extensionElementPrefixes
            case "version" : return .version
            case "id" : return .id
            case "key" : return .key
            case "keyNodes" : return .keyNodes
            case "exclude-result-prefixes" : return .excludeResultPrefixes
            case "xmlns" : return .xmlns

            case "parameter" : return .parameter
            case "variable" : return .variable
            case "constant" : return .variable

            case "value" : return .valueOf
            case "comment" : return .comment
            case "disable-output-escaping" : return .disableOutputEscaping
            case "textcontent" : return .textcontent

            case "output" : return .output
            case "method" : return .method
            case "xml" : return .xmlMethod
            case "html" : return .htmlMethod
            // This is an overloaded case which is sorted out as either
            // .text or .textMethod in the method parser. Crude but effective.
            case "text" : return .text
            case "encoding" : return .encoding
            case "cdata" : return .cdataList
            case "omit-xml-declaration" : return .omitXmlDecl
            case "include-xml-declaration" : return .includeXmlDecl
            case "standalone" : return .standAlone
            case "doctype-public" : return .doctypePublic
            case "doctype-system" : return .doctypeSystem

            case "decimal-format" : return .decimalFormat
            case "decimal-separator" : return .decimalSeparator
            case "grouping-separator" : return .groupingSeparator
            case "infinity" : return .infinity
            case "minus-sign" : return .minusSign
            case "NaN" : return .notNumber
            case "percent" : return .percent
            case "per-mille" : return .perMille
            case "zero-digit" : return .zeroDigit
            case "digit" : return .digit
            case "pattern-separator" : return .patternSeparator

            case "count" : return .count
            case "level" : return .level
            case "from" : return .from
            case "format" : return .format
            case "letter-value" : return .letterValue
            case "grouping-size" : return .groupingSize
            case "single" : return .singleLevel
            case "multiple" : return .multipleLevel
            case "any" : return .anyLevel
            case "alphabetic" : return .alphabetic
            case "traditional" : return .traditional

            case "include" : return .includeSheet
            case "import" : return .importSheet

            case "strip-space" : return .stripSpace
            case "preserve-space" : return .preserveSpace
            case "indent" : return .indent
            case "yes" : return .yes
            case "no" : return .no
            case "media-type" : return .mediaType

            case "call" : return .call
            case "with" : return .with
            case "sort" : return .sort

            case "proc" : return .proc
            case "match" : return .match
            case "using" : return .using
            case "scope" : return .scope
            case "priority" : return .priority

            case "if" : return .ifCondition
            case "choose" : return .choose
            case "when" : return .when
            case "otherwise" : return .otherwise
            case "attribute" : return .attrib
            case "foreach" : return .foreach

            case "apply-imports" : return .applyImports
            case "apply-templates" : return .applyTemplates

            case "element" : return .element
            case "fallback" : return .fallback
            case "namespace" : return .namespace

            case "use-attribute-sets" : return .useAttributeSets
            case "attribute-set" : return .attributeSet

            case "copy" : return .copy
            case "copy-of" : return .copyOf

            case "lang" : return .lang
            case "order" : return .order
            case "ascending" : return .ascending
            case "descending" : return .descending
            case "case-order" : return .caseOrder
            case "upper-first" : return .upperFirst
            case "lower-first" : return .lowerFirst
            // data-type is not parsed
            case "text-sort" : return .textSort
            case "number-sort" : return .numberSort

            case "(" : return .openBracket
            case ")" : return .closeBracket
            case "{" : return .openCurlyBracket
            case "}" : return .closeCurlyBracket

            case "//" : return .rcomment

            case "message" : return .message
            case "terminate" : return .terminate
            
            case "namespace-alias" : return .namespaceAlias
            case "map-from" : return .mapFrom
            case "to" : return .mapTo

            case "processing-instruction" : return .processingInstruction
            case "number" : return .number

            // Version 1.1

            case "script" : return .script
            case "src" : return .src
            case "prefix" : return .prefix
            case "language" : return .language
            case "archive" : return .archive

            // Version 2.0

            case "analyze-string" : return .analyzeString
            case "regex" : return .regex
            case "flags" : return .flags
            case "matching-substring" : return .matchingSubstring
            case "non-matching-substring" : return .nonMatchingSubstring

            default : return .unknownToken
        }
    }

    /// Is this string a terminal symbol
    static func isTerminalSymbol( _ token: String ) -> Bool {
        return TerminalSymbolEnum.translate( token ) != .unknownToken
    }

}

