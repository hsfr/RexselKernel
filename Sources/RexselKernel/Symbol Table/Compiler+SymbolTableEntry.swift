//
//  Compiler+SymbolTableEntry.swift
//  RexselKernel
//
//  Copyright (c) 2024 Hugh Field-Richards. All rights reserved.

import Foundation

struct SymbolTableEntry {

    /// Tha symbol name (variable, parameter etc)
    var name: String = ""

    /// The scope where declared (variable/parameter name)
    var scope: String = ""

    /// Where this symbol was declared (line number)
    var whereDeclared: Int = 0

    var whereUsedList: WhereUsedListType = []

    var entryType: TerminalSymbolEnum = .unknownToken

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    ///
    /// Returns a string representing symbol table entry
    ///
    /// - Parameters:
    ///   - maxLength: Maximum line length
    /// - returns: Symbol table string

    func description( maxLength inMaximumLength: Int ) -> String
    {
        var message: String = "[\(entryType.symbolType)] \(name)"

        var padding = ""

        // Small bodge to even columns!
        if entryType == .function {
            padding = " "
        }

        if entryType == .match {
            padding = "    "
        }

        func padSpaces( _ totalSpaces: Int ) {
            for _ in message.count...totalSpaces {
                padding += " "
            }
        }

        // Pad spaces must be set to maximum length of symbols in table (plus some padding)
        padSpaces( inMaximumLength + entryType.description.count + 3 + 2 )

        var lineValue: Int
        var numberOfEntries = 1
        let totalEntries = whereUsedList.count

        if totalEntries == 0 {
            message += "\(padding)in line \(whereDeclared+1)"
            // Do need to classify match as not used
            if entryType != .match {
                message += " not used"
            }
        } else {
            message += "\(padding)in line \(whereDeclared+1)  used in line(s) "
        }
        for i in 0..<totalEntries {
            lineValue = self.whereUsedList[i]
            if lineValue == self.whereDeclared {
                message += "\(lineValue + 1)*"
            } else {
                message += "\(lineValue + 1)"
            }
            if numberOfEntries < whereUsedList.count {
                message += ", "
            }
            numberOfEntries += 1
        }
        return message
    }
}
