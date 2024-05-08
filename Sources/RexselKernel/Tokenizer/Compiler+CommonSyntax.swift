//
//  Compiler+commonSyntax .swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 15/03/2024.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

struct AllowableSyntaxEntryStruct {

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

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension TerminalSymbolEnum {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    /// At the top level a restricted set of keywords are allowed

    static let stylesheetTokens: Set<TerminalSymbolEnum> = [
        .importSheet, .includeSheet, .stripSpace,
        .preserveSpace, .output, .key, .decimalFormat,
        .parameter, .variable, .function, .match,
        .version, .id, .xmlns, .namespaceAlias,
        .attributeSet, .number
    ]

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    /// These are the set of keywords that can occur in
    /// template blocks (element, variable etc.)
    static let blockTokens: Set<TerminalSymbolEnum> = [
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
    static let attributeBlockTokens: Set<TerminalSymbolEnum> = [
        .variable,
        .applyTemplates, .call,
        .choose,.copy, .copyOf,
        .foreach, .ifCondition, .number,
        .valueOf, .text
    ]

    static let sortToken: Set <TerminalSymbolEnum> = [ .sort ]

    static let parameterToken: Set <TerminalSymbolEnum> = [ .parameter ]

    static let YesNoTokens: Set <TerminalSymbolEnum> = [
        .yes, .no
    ]

}
