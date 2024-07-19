//
//  RexselKernel+SymbolTable.swift
//  RexselKernel
//
//  Copyright 2024 Hugh Field-Richards. All rights reserved.

import Foundation

typealias WhereUsedListType = [Int]

typealias SymbolTableDictType = [ String: SymbolTableEntry ]

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

struct SymbolTable {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Common instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    /// A list of symbols in the associated block
    fileprivate var symbolTableDict: SymbolTableDictType

    /// The title of this symbol table.
    ///
    /// The title is formed from the name + the type of the symbol
    var title: String = ""

    /// The line number where this block is declared.
    var blockLine: Int = -1

    /// The compiler that uses this symbol table.
    var thisCompiler = RexselKernel()

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    init( _ compiler: RexselKernel ) {
        symbolTableDict = [:]
        title = ""
        blockLine = 0
        thisCompiler = compiler
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Add a symbol to the symbol table.
    ///
    /// - Parameters:
    ///   - name: the name of the symbol
    ///   - type: the type of the symbol (variable, parameter or proc)
    ///   - declaredInLine: the line number where declared
    ///   - scope: the name of block where declared (variable, parameter or proc)
    /// - Throws: _duplicateSymbol_ if existing symbol

    mutating func addSymbol( name symbolName: String, type inType: TerminalSymbolEnum, declaredInLine: Int, scope scopeName: String ) throws {
        let newEntry = SymbolTableEntry( name: symbolName, scope: scopeName, whereDeclared: declaredInLine, entryType: inType )
       //  let symbolExists = symbolTableDict.keys.contains( name )
        guard !isNameDeclared( symbolName ) else {
            throw SymbolTableError( kind: .duplicateSymbol,
                                    name: symbolName,
                                    declaredLine: declaredInLine,
                                    previouslyDeclaredIn: symbolTableDict[ symbolName ]!.whereDeclared )
        }
        symbolTableDict[symbolName] = newEntry
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    func isNameDeclared( _ name: String ) -> Bool {
        return symbolTableDict.keys.contains( name )
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    mutating func addNameToUsedList( _ name: String, inLine: Int ) {
        symbolTableDict[name]?.whereUsedList.append(inLine)
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    func whereSymbolDeclared( name: String ) throws -> Int {
        let symbolExists = symbolTableDict.keys.contains( name )
        guard symbolExists else {
            throw RexselErrorData
                .init(kind: RexselErrorKind
                    .missingSymbol( name: name ) )
        }
        return symbolTableDict[ name ]!.whereDeclared
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    /// Returns a string representing the symbol table
    var description: String {

        guard !symbolTableDict.isEmpty else {
            return ""
        }

        let maxLen = maxSymbolLength
        // First get a list of symbol names since we are going to sort them
        var keys: [String] = []
        var message = "Symbols in context \"\(title)\" in line \(blockLine+1), found: \(symbolTableDict.count)"
        if title == "::" {
            message = "Symbols in \"apply-template etc\" in line \(blockLine+1) context, found: \(symbolTableDict.count)"
        }

        message += " \( symbolTableDict.count > 1 ? "symbols" : "symbol")\n"

        var sortedSymbolTableDict = SymbolTableDictType()
        for ( _, entry ) in symbolTableDict {
            let typeAndName = "\(entry.entryType.description) \(entry.name)"
            sortedSymbolTableDict[typeAndName] = entry
            keys.append( typeAndName )
        }

        keys.sort( by: < )

        for name in keys {
            if let entry = sortedSymbolTableDict[name] {
                if entry.name.isNotEmpty {
                    message += entry.description( maxLength: maxLen ) + "\n"
                }
            } else {
                message = "????"
            }
        }

        return "\(message)"
    }

    // Convenience variable to return the maximum langth of the stored names.
    var maxSymbolLength: Int {
       var maxLen = 0
       for ( name, _ ) in symbolTableDict {
          if name.count > maxLen {
             maxLen = name.count
          }
       }
       return maxLen
    }

}
