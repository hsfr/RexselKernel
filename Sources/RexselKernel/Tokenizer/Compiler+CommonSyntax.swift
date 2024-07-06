//
//  Compiler+commonSyntax .swift
//  RexselKernel
//
//  Copyright (c) 2024 Hugh Field-Richards. All rights reserved.

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

struct AllowableSyntaxEntryStruct {

    /// The basic string value for this entry
    var value: String = ""

    /// The child for this structure
    var child: TerminalSymbolEnum = .unknownToken

    /// The minimuum required
    var min: Int = 0

    /// The maximum allowed
    var max: Int = 0

    /// Where the child is originally defined.
    ///
    /// Used when duplicates are checked for.
    var defined: Int = -1

    /// Number defined so far.
    ///
    /// Used to check on min/max
    var count: Int = 0

    /// Are duplicates allowed?
    var duplicatesAllowed: Bool {
        get {
            return max > 1
        }
    }

    /// Is this child required?
    var required: Bool {
        get {
            return min > 0
        }
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//
// Used in several places so declared globally.

func isInBlockTemplateTokens( _ token: TerminalSymbolEnum ) -> Bool {
    return TerminalSymbolEnum.blockTokens.contains(token)
}

func isInBoolTokens( _ token: TerminalSymbolEnum ) -> Bool {
    return TerminalSymbolEnum.YesNoTokens.contains(token)
}

typealias StylesheetTokensType = Set<TerminalSymbolEnum>

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension TerminalSymbolEnum {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    /// At the top level a restricted set of keywords are allowed.
    /// The list includes all versions. Detection and restrictions
    /// between versions is done in appropriate node.
    static let stylesheetTokens: StylesheetTokensType = [
        .importSheet, .includeSheet, .stripSpace,
        .preserveSpace, .output, .key, .decimalFormat,
        .parameter, .variable, .proc, .match,
        .version, .id, .xmlns, .namespaceAlias,
        .attributeSet, .number, .script
    ]

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    /// These are the set of keywords that can occur in
    /// template blocks (element, variable etc.)
    /// The list includes all versions. Detection and restrictions
    /// between versions is done in appropriate node.
    static let blockTokens: StylesheetTokensType = [
        .variable, .applyImports,
        .applyTemplates, .attrib, .call,
        .choose,.copy, .copyOf, .element,
        .foreach, .ifCondition, .message,
        .processingInstruction, .number,
        .valueOf, .text, .comment,
        .attributeSet, .fallback
    ]

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    /// These are the set of keywords that can occur in
    /// attribute blocks.
    /// The list includes all versions. Detection and restrictions
    /// between versions is done in appropriate node.
    static let attributeBlockTokens: StylesheetTokensType = [
        .variable,
        .applyTemplates, .call,
        .choose,.copy, .copyOf,
        .foreach, .ifCondition, .number,
        .valueOf, .text
    ]

    static let fallbackToken: StylesheetTokensType = [ .fallback ]

    static let sortToken: StylesheetTokensType = [ .sort ]

    static let parameterToken: StylesheetTokensType = [ .parameter ]

    static let YesNoTokens: StylesheetTokensType = [
        .yes, .no
    ]

}
