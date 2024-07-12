//
//  RexelError+Kind.swift
//  RexselKernel
//
//  Copyright (c) 2024 Hugh Field-Richards. All rights reserved.

import Foundation

/// A preliminary set of error types.
///
/// Currently not used.
enum ErrorTypeEnum {
    case fatal     // Oh dear! Very bad so exit
    case error     // Take notice
    case warning   // Advisory
    case ignore
}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Error types
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

enum RexselErrorKind {
    case fatalError
    case sourceFileDoesNotExist( name: String )
    case cannotReadFromFile( name: String, desc: String )
    case foundUnexpectedSymbol( lineNumber: Int, found: String, inElement: String )
    case foundUnexpectedSymbolInsteadOf( lineNumber: Int, found: String, insteadOf: String, inElement: String )

    case foundUnexpectedExpression( lineNumber: Int, found: String )
    case unknownValue( lineNumber: Int, inElement: String, found: String, insteadOf: String )
    case alreadyDeclaredIn( lineNumber: Int, name: String, atLine: Int )
    case duplicateSymbol( lineNumber: Int, name: String, originalLine: Int )
    case duplicateNamespace( lineNumber: Int, name: String, where: Int )

    case duplicateParameter( lineNumber: Int, name: String, where: Int )
    case duplicateVariable( lineNumber: Int, name: String, where: Int )
    case expectedName( lineNumber: Int, name: String )
    case couldNotFindVariable( lineNumber: Int, name: String )
    case notSupported( lineNumber: Int, name: String, inElement: String )

    case missingItem( lineNumber: Int, what: String )
    case missingParameterName( lineNumber: Int )
    case missingVariableValue( lineNumber: Int, name: String )
    case missingTest( lineNumber: Int )
    case missingExpression( lineNumber: Int, name: String )

    case missingNamespace( lineNumber: Int )
    case missingURI( lineNumber: Int, symbol: String )
    case missingElementName( lineNumber: Int, position: Int, found: String )
    case missingName( lineNumber: Int, position: Int )
    case missingList( lineNumber: Int, symbol: String )

    case missingSymbol( name: String )
    case requiredElement( lineNumber: Int, name: String, inElement: String )
    case cannotHaveBothDefaultAndBlock( lineNumber: Int )
    case defaultAndBlockMissing( lineNumber: Int )
    case parameterMustBeFirst( lineNumber: Int, name: String, within: String )

    case parameterCannotAppearHere( lineNumber: Int )
    case globalVariableAlreadyDeclared( lineNumber: Int, name: String )
    case unmatchedQuotes( lineNumber: Int, position: Int )
    case invalidPattern( pattern: String, lineNumber: Int )
    case missingOpenCurlyBracket( lineNumber: Int )

    case unmatchedBrackets( lineNumber: Int, level: Int )
    case expectedCharacterNotString( lineNumber: Int, position: Int, found: String )
    case emptyBlock( lineNumber: Int )
    case foundReservedWord( lineNumber: Int, name: String, inElement: String )
    case invalidExpression( lineNumber: Int, found: String, insteadOf: String, inElement: String )

    case sortMustBeFirst( lineNumber: Int, within: String )
    case invalidXSLTVersion( lineNumber: Int, version: String )
    case invalidKeywordForVersion( lineNumber: Int, keyword: String, version: String )
    case missingSrcOrScript( lineNumber: Int )
    case cannotHaveBothSrcAndScript( lineNumber: Int )

    case missingScriptOption( lineNumber: Int, symbol: String )
    case prefixNotDeclared( lineNumber: Int, prefix: String )
    case syntaxRequiresElement( lineNumber: Int, name: String, inElement: String )
    case syntaxRequiresZeroOrOneElement( lineNumber: Int, name: String, inElement: String )
    case syntaxRequiresZeroOrMoreElement( lineNumber: Int, name: String, inElement: String )

    case syntaxRequiresOneOrMoreElement( lineNumber: Int, name: String, inElement: String )
    case syntaxCannotHaveBothElements( lineNumber: Int, names: [String], inElement: String )
    case syntaxMustHaveAtLeastOneOfElements( lineNumber: Int, names: [String], inElement: String )

    case endOfFile

    case unknownError( lineNumber: Int, message: String )


    var number: Int {
        switch self {
            case .fatalError: return 101
            case .sourceFileDoesNotExist( _ ) : return 102
            case .cannotReadFromFile( _, _ ) : return 103
            case .missingOpenCurlyBracket( _ ) : return 104
            case .foundUnexpectedSymbol( _, _, _ ) : return 105

            case .foundUnexpectedSymbolInsteadOf( _, _, _, _ ) : return 106
            case .foundUnexpectedExpression( _, _ ) : return 107
            case .unknownValue( _, _, _, _ ) : return 108
            case .alreadyDeclaredIn( _, _, _ ) : return 109
            case .duplicateSymbol( _, _, _ ) : return 110

            case .missingSymbol( _ ) : return 111
            case .duplicateNamespace( _, _, _ ) : return 112
            case .duplicateParameter( _, _, _ ) : return 113
            case .duplicateVariable( _, _, _ ) : return 114
            case .expectedName( _, _ ) : return 115

            case .couldNotFindVariable( _, _ ) : return 116
            case .notSupported( _, _, _ ) : return 117
            case .requiredElement( _, _, _ ) : return 118
            case .missingItem( _, _ ) : return 119
            case .missingParameterName( _ ) : return 120

            case .missingVariableValue( _, _ ) : return 121
            case .missingTest( _ ) : return 122
            case .missingElementName( _, _, _ ) : return 123
            case .missingName( _, _ ) : return 124
            case .missingNamespace( _ ) : return 125

            case .missingURI( _, _ ) : return 126
            case .missingList( _, _ ) : return 127
            case .cannotHaveBothDefaultAndBlock( _ ) : return 128
            case .defaultAndBlockMissing( _ ) : return 129
            case .missingExpression( _, _ ) : return 130

            case .parameterMustBeFirst( _, _, _ ) : return 131
            case .parameterCannotAppearHere( _ ) : return 132
            case .globalVariableAlreadyDeclared( _, _ ) : return 133
            case .unmatchedQuotes( _, _ ) : return 134
            case .invalidPattern( _, _ ) : return 135

            case .unmatchedBrackets( _, _ ) : return 136
            case .expectedCharacterNotString( _, _, _ ) : return 137
            case .emptyBlock( _ ) : return 138
            case .foundReservedWord( _, _, _ ) : return 139
            case .invalidExpression( _, _, _, _ ) : return 140

            case .sortMustBeFirst( _, _ ) : return 141
            case .invalidXSLTVersion(_, _ ) : return 142
            case .invalidKeywordForVersion( _, _, _ ) : return 143
            case .missingSrcOrScript( _ ) : return 144
            case .cannotHaveBothSrcAndScript( _ ) : return 145

            case .missingScriptOption( _, _ ) : return 146
            case .prefixNotDeclared( _, _ ) : return 147
            case .syntaxRequiresElement( _, _, _ ) : return 148
            case .syntaxRequiresZeroOrOneElement( _, _, _ ) : return 149
            case .syntaxRequiresZeroOrMoreElement( _, _, _ ) : return 150

            case .syntaxRequiresOneOrMoreElement( _, _, _ ) : return 151
            case .syntaxCannotHaveBothElements( _, _, _ ) : return 152
            case .syntaxMustHaveAtLeastOneOfElements( _, _, _ ) : return 153

            case .endOfFile : return 1001

            case .unknownError( _, _ ) : return 1002
        }

    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    var description: String {
        switch self {
            case .fatalError: return "Fatal error"
        
            case .sourceFileDoesNotExist( let name ) :
                return "File \"\(name)\" does not exist"
      
            case .cannotReadFromFile( let name, let desc ) : 
                return "Cannot read from file \"\(name)\": \(desc)"

            case .missingOpenCurlyBracket( let lineNumber ) : 
                return "Missing \"{\" in line \(lineNumber)"

            case .foundUnexpectedSymbol( let lineNumber, let found, let inElement ) :
                if found.isNotEmpty {
                    return "Unexpected symbol \"\(found)\" found in \"\(inElement)\" in line \(lineNumber)"
                } else {
                    return "Unexpected symbol in \"\(inElement)\" in line \(lineNumber)"
                }

            case .foundUnexpectedSymbolInsteadOf( let lineNumber, let found, let insteadOf, let inElement ) :
                switch ( found.isNotEmpty, inElement.isNotEmpty ) {
                    case ( true, true ) :
                        return "Unexpected symbol \"\(found)\" instead of \"\(insteadOf)\" in \"\(inElement)\" in line \(lineNumber)"
                    case ( true, false ) :
                        return "Unexpected symbol \"\(found)\" instead of \"\(insteadOf)\" in line \(lineNumber)"
                    case ( false, true ) :
                        return "Unexpected symbol found instead of \"\(insteadOf)\" in \"\(inElement)\" in line \(lineNumber)"
                    case ( false, false ) :
                        return "Unexpected symbol found instead of \"\(insteadOf)\" in line \(lineNumber)"
                }

            case .foundUnexpectedExpression( let lineNumber, let found ) :
                return "Found unexpected expression \(found) in line \(lineNumber)"

            case .unknownValue( let lineNumber, let name, let found, let insteadOf ) :
                return "Illegal value for \"\(name)\", found \"\(found)\" instead of \(insteadOf) in line \(lineNumber)"

            case .alreadyDeclaredIn( let lineNumber, let name, let atLine ) :
                return "\"\(name)\" in line \(atLine) is already declared in line \(lineNumber)"

            case .duplicateSymbol( let lineNumber, let name, let orig ) : 
                return "\"\(name)\" symbol in \(lineNumber) already declared in line \(orig)"
           
            case .missingSymbol( let name ) :
                return "Missing symbol \"\(name)\""

            case .duplicateNamespace( let lineNumber, let name, let orig ) : 
                return "\"\(name)\" namespace in \(lineNumber) already declared in line \(orig)"
       
            case .duplicateParameter( let lineNumber, let name, let orig ) :
                return "\"\(name)\" parameter in \(lineNumber) already declared in line \(orig)"
      
            case .duplicateVariable( let lineNumber, let name, let orig ) :
                return "\"\(name)\" variable in \(lineNumber) already declared in line \(orig)"
       
            case .expectedName( let lineNumber, let name ) :
                return "Expected name after \"\(name)\" in line \(lineNumber)"

            case .couldNotFindVariable( let lineNumber, let name ) : 
                return "Could not find \"\(name)\" in line \(lineNumber)"

            case .notSupported( let lineNumber, let name, let inElement ) :
                return "\"\(name)\" not supported in element \"\(inElement)\" in line \(lineNumber)"
            
            case .requiredElement( let lineNumber, let name, let inElement ) :
                return "\"\(name)\" required in element \"\(inElement)\" in line \(lineNumber)"

            case .missingItem( let lineNumber, let what ) :
                return "Missing item \(what) in line \(lineNumber)"

            case .missingParameterName( let lineNumber ) : 
                return "Missing parameter name in line \(lineNumber)"

            case .missingVariableValue( let lineNumber, let name ) : 
                return "Missing value for \"\(name)\" in line \(lineNumber)"

            case .missingTest( let lineNumber ) : 
                return "Missing test expression in line \(lineNumber)"

            case .missingExpression( let lineNumber, let name ) :
                return "Missing \"\(name)\" expression in line \(lineNumber)"

            case .missingURI( let lineNumber, let symbol ) : 
                return "Missing URI, found \"\(symbol)\" in line \(lineNumber)"

            case .missingList( let lineNumber, let symbol ) :
                return "Missing list of elements for \"\(symbol)\" in line \(lineNumber)"

            case .cannotHaveBothDefaultAndBlock( let lineNumber ) : 
                return "A variable/parameter cannot have default and enclosed templates in line \(lineNumber)"
       
            case .defaultAndBlockMissing( let lineNumber ) :
                return "There must be either a simple value or enclosed templates in line \(lineNumber)"

            case .parameterMustBeFirst( let lineNumber, let name, let within ) :
                return "Parameter \"\(name)\" in \"\(within)\" in line \(lineNumber) must follow declaration."
          
            case .parameterCannotAppearHere( let lineNumber ) :
                return "Parameters cannot appear in parameter/variable blocks in line \(lineNumber)."

            case .globalVariableAlreadyDeclared( let lineNumber, let name ) :
                return "A variable/parameter \"\(name)\" aleardy declared globally in line \(lineNumber)"
   
            case .unmatchedQuotes( _, let lineNumber ) : 
                return "Invalid Unmatched quotes in line \(lineNumber)"

            case .missingElementName( let lineNumber, _, let found ) : 
                return "Missing element/attribute name, found terminal \"\(found)\" in line \(lineNumber)"

            case .missingName( let lineNumber, _ ) : 
                return "Missing name in line \(lineNumber)"

            case .missingNamespace( let lineNumber ) : 
                return "Missing namespace value in line \(lineNumber)"

            case .invalidPattern( let pattern, let lineNumber ) : 
                return "Invalid pattern \"\(pattern)\" for match in line \(lineNumber)"

            case .unmatchedBrackets( let lineNumber, _ ) : 
                return "Unmatched brackets in \(lineNumber)"

            case .expectedCharacterNotString( let lineNumber, _, let value ) : 
                return "Expected character but got string \"\(value)\" in \(lineNumber)"

            case .emptyBlock( let lineNumber ) :
                return "Missing or empty block in \(lineNumber)"

            case .foundReservedWord( let lineNumber, let name, let within ) :
                return "Found unexpected reserved word \"\(name)\" in \"\(within)\" in line \(lineNumber)"

            case .invalidExpression( let lineNumber, let found, let insteadOf, let inElement ) :
                if found.isNotEmpty {
                    return "Invalid string \"\(found)\" instead of \"\(insteadOf)\" in \"\(inElement)\" in line \(lineNumber)"
                } else {
                    return "Null string instead of \"\(insteadOf)\" in \"\(inElement)\" in line \(lineNumber)"
                }

            case .sortMustBeFirst( let lineNumber, let within ) :
                return "Sort in \"\(within)\" in line \(lineNumber) must follow declaration."

            case .invalidXSLTVersion( let lineNumber, let version ) :
                return "Illegal XSLT version \"\(version)\" in line \(lineNumber)."

            case .invalidKeywordForVersion( let lineNumber, let keyword, let version ) :
                return "Illegal keyword \"\(keyword)\" for version \"\(version)\" in line \(lineNumber)"

            case .missingSrcOrScript( let lineNumber ) : 
                return "Script statement must have either src or script declared in line \(lineNumber)"

            case .cannotHaveBothSrcAndScript( let lineNumber ) :
                return "Script statement cannot have both src or script declared in line \(lineNumber)"

            case .missingScriptOption( let lineNumber, let symbol ) :
                return "Script statement needs \(symbol) declared in line \(lineNumber)"

            case .prefixNotDeclared( let lineNumber, let prefix ) :
                return "Namespace prefix \"\(prefix)\" not declared in script declaration in line \(lineNumber)"

            case .syntaxRequiresElement( let lineNumber, let name, let inElement ) : 
                return "\"\(inElement)\" requires \"\(name)\" in line \(lineNumber)"

            case .syntaxRequiresZeroOrOneElement( let lineNumber, let name, let inElement ) :
                return "\"\(inElement)\" requires zero or one \"\(name)\" in line \(lineNumber)"

            case .syntaxRequiresZeroOrMoreElement( let lineNumber, let name, let inElement ) :
                return "\"\(inElement)\" requires zero or more \"\(name)\" in line \(lineNumber)"

            case .syntaxRequiresOneOrMoreElement( let lineNumber, let name, let inElement ) :
                return "\"\(inElement)\" requires one or more \"\(name)\" in line \(lineNumber)"

            case .syntaxCannotHaveBothElements( let lineNumber, let names, let inElement ) :
                var namesString = ""
                for entry in names {
                    namesString += "\"\(entry)\" "
                }
                return "Cannot have \(namesString)together in \"\(inElement)\" in line \(lineNumber)"

            case .syntaxMustHaveAtLeastOneOfElements( let lineNumber, let names, let inElement ) :
                var namesString = ""
                for entry in names {
                    namesString += "\"\(entry)\" "
                }
                return "Must have at least one of \(namesString)present in \"\(inElement)\" in line \(lineNumber)"

            case .endOfFile : return "Early end of file"

            case .unknownError( let lineNumber, _ ) : return "Unknown error in line \(lineNumber)"
        }
    }

    var suggestion: String {
        switch self {
            case .fatalError: return "Check source and output"
    
            case .sourceFileDoesNotExist( _ ) : return "check correct path/name"
       
            case .cannotReadFromFile( _, _ ) : return "Check permissions etc."
       
            case .missingOpenCurlyBracket( _ ) : return "Insert bracket."

            case .foundUnexpectedSymbol( _, _, _ ) :
                return "Check spelling, missing expression, bracket or quote?"

            case .foundUnexpectedSymbolInsteadOf( _, _, _, _ ) :
                return "Check spelling, missing expression, bracket or quote?"

            case .foundUnexpectedExpression( _, _ ) : return "Check missing keyword."

            case .unknownValue( _, _, _, _ ) : return "Supply correct value."
          
            case .alreadyDeclaredIn( _, _, _ ) : return "Remove duplicate."

            case .duplicateSymbol( _, _, _ ) : return "Remove duplicate or check spelling."
          
            case .missingSymbol( _ ) : return "Insert pattern."

            case .duplicateNamespace( _, _, _ ) : return "Remove duplicate or check spelling."
          
            case .duplicateParameter( _, _, _ ) : return "Remove duplicate from current block or check spelling."
          
            case .duplicateVariable( _, _, _ ) : return "Remove duplicate from current block or check spelling."
          
            case .expectedName( _, let name ) :
                return "Syntax: \(name) <qname> \( (name == "variable" || name == "parameter" ) ? "<expression> or" : "" ) <block>."

            case .couldNotFindVariable( _, let name ) : return "Check \"\(name)\" is defined in current block/context."

            case .notSupported( _, _, _ ) : return "Remove item."
          
            case .requiredElement( _, _, _ ) : return "Insert element."
            
            case .missingItem( _, _ ) : return "Insert item."

            case .missingParameterName( _ ) : return "Insert parameter name."
            
            case .missingVariableValue( _, _ ) : return "Insert variable/constant value or block."
            
            case .missingTest( _ ) : return "Insert test."
            
            case .missingExpression( _, _ ) : return "Insert expression."

            case .missingElementName( _, _, _ ) : return "Supply valid element name."
            
            case .missingName( _, _ ) : return "Insert name"
            
            case .missingNamespace( _ ) : return "Supply valid namespace URI."
            
            case .missingURI( _, _ ) : return "Insert URI."
            
            case .missingList( _, _ ) : return "Supply at least  one item."

            case .cannotHaveBothDefaultAndBlock( _ ) : return "Remove either default/select or enclosed templates."
          
            case .defaultAndBlockMissing( _ ) : return "Supply either default/select or enclosed templates."

            case .parameterMustBeFirst( _, _, _ ) : return "Check order."
            
            case .parameterCannotAppearHere( _ ) : return "Remove parameter staement."

            case .globalVariableAlreadyDeclared( _, _ ) : return "Check name of either declaration."
            
            case .unmatchedQuotes( _, _ ) : return "Check source."
            
            case .invalidPattern( _, _ ) : return "Check pattern syntax."

            case .unmatchedBrackets( _, let level ) :
                if level < 0 {
                    return "Too many close brackets?"
                } else {
                    return "Too many open brackets?"
                }

            case .expectedCharacterNotString( _, _, let value ) :
                var ch = value
                return "Stripping everything after first character \"\(ch.removeFirst())\"."

            case .emptyBlock( _ ) : return "Supply block"
         
            case .foundReservedWord( _, _, _ ) : return "Check spelling."

            case .invalidExpression( _, _, _, _ ) : return "Check string expression."

            case .sortMustBeFirst( _, _ ) : return "Check order."

            case .invalidXSLTVersion( _, _ ) :
                return "Check version number for tis stylesheet."

            case .invalidKeywordForVersion( _, _, _ ) :
                return "Update version number or remove keyword."

            case .missingSrcOrScript( _ ) :
                return "Enter either required expression"

            case .cannotHaveBothSrcAndScript( _ ) :
                return "Remove one of the expressions"

            case .missingScriptOption( _, let symbol ) :
                return "Insert \(symbol) \"expression\" pair"

            case .prefixNotDeclared( _, let prefix ) :
                return "Insert namespace pair declaration for \"\(prefix)\""

            case .syntaxRequiresElement( _, _, let inElement ) :
                return "Check syntax requirements for \"\(inElement)\""

            case .syntaxRequiresZeroOrOneElement( _, _, let inElement ) :
                return "Check syntax requirements for \"\(inElement)\""

            case .syntaxRequiresZeroOrMoreElement( _, _, let inElement ) :
                return "Check syntax requirements for \"\(inElement)\""

            case .syntaxRequiresOneOrMoreElement( _, _, let inElement ) :
                return "Check syntax requirements for \"\(inElement)\""

            case .syntaxCannotHaveBothElements( _, _, _ ) :
                return "Remove one of the keywords"

            case .syntaxMustHaveAtLeastOneOfElements( _, _, _ ) :
                return "Insert one of the keywords"

            case .endOfFile : return "Check mismatched brackets?"

            case .unknownError( _, let message ) :
                if message.isNotEmpty {
                    return "\(message)"
                } else {
                    return "No suggestion"
                }
        }
    }
}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// MARK: - Rexsel Error Data Structure
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

struct RexselErrorData: Error {
  
    var kind: RexselErrorKind = .unknownError(lineNumber: 0, message: "")
 
    var line: Int = 0
  
    var position: Int = 0

    /// Error type: fatal, error, etc.
    ///
    /// Assume that this will be an ordinary error
    /// when the structure is initialised. Not
    /// used at present other than fatal.
    var type: ErrorTypeEnum = .error

    /// Optional message associated with this error
    var errorMessage: String = ""

    /// Number of this error
    var errorNumber: Int {
        return kind.number
    }

    /// A hash of the entire error messgae.
    ///
    /// This is used when several identical messages could appear in
    /// the  error list. It makes sure that duplicates are removed
    /// for ease of reading.
    var hashValue: Int {
        get {
            return errorMessage.hashValue
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    init( kind: RexselErrorKind,
          line: Int? = 0, position: Int? = 0, source: String? = "",
          type: ErrorTypeEnum? = .error,
          message: String? = "" ) {
        self.kind = kind
        self.line = line!
        self.position = position!
        self.type = type!
        self.errorMessage = message!
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    var description: String {
        let mess = "\n**** (\(errorNumber)) \(kind.description)\n     \(kind.suggestion)"
        return mess
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    var xml: String {
        return "<!-- **** (\(errorNumber)) \(kind.description) : \(kind.suggestion) -->"
    }

}

