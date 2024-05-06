//
//  Source.swift
//  Rexsel
//
//  Copyright (c) 2024 Hugh Field-Richards. All rights reserved.
//

import Foundation

typealias SourceLineType = ( index: Int, line: String )

public class Source: NSObject {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Logging properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

#if HESTIA_LOGGING
    fileprivate var rLogger: RexselLogger!
#endif

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    /// File held as a string
    public var fileString: String = ""

    /// Array pf source file lines
    var sourceLines: [SourceLineType] = []

    /// Array pf source file lines
    var normalosedSourceLines: [SourceLineType] = []

    /// Index of next line to read
    var lineIndex = 0

    /// The error for this line
    var isEndOfFile: Bool {
        return ( lineIndex >= sourceLines.count )
    }

    /// The error for this line
    public var errors = RexselErrorList()

    /// return unprocessed description of file (no blank lines)
    public var shortDescription: String {
        var message = ""
        for src in sourceLines {
            if !lineIsEmpty( src.line ) {
                message += "\n\(src.index):\(src.line)"
            }
        }
        return message
    }

    /// return unprocessed description of file (with blank lines)
    override public var description: String {
        var message = ""
        for line in sourceLines {
            message += "\n\(line.index): \(line.line)"
        }
        return message
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Initialisation
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    public override init() {
        super.init()
#if HESTIA_LOGGING
        rLogger = RexselLogger()
#endif
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Public Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Read an internal string from TextView string

    public func readIntoCompilerStringFromFile( _ fileName: String, inFolder inDir: String = "" ) {
        do {
            var filePathName = fileName
            if inDir.isNotEmpty {
                filePathName += "\(inDir)/\(fileName)"
            }
            let fileURL = URL( fileURLWithPath: filePathName )
            let source = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = source.components( separatedBy: "\n" )
            clearSource()
            for i in 0..<lines.count {
               sourceLines.append( ( i, lines[i] ) )
            }
            lineIndex = 0
        }  catch {
            print( " Cannot read from file \(inDir)/\(fileName)")
        }
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

   func getLine() -> ( sourceLine: SourceLineType, endOfFile: Bool ) {
#if HESTIA_LOGGING
       rLogger.log( self, .debug,"Getting line \(lineIndex) ")
#endif
        guard !isEndOfFile else {
            lineIndex = 0
            return ( ( 0, "" ), true )
        }
        var sourceLine = sourceLines[ lineIndex ]
#if HESTIA_LOGGING
      rLogger.log( self, .debug,"  fetched line at \(lineIndex): \(sourceLine.line)")
#endif

        if lineIsNotEmpty( sourceLine.line ) && lineIndex <= sourceLines.count {
            sourceLine = sourceLines[ lineIndex ]
        } else {
#if HESTIA_LOGGING
          rLogger.log( self, .debug,"  Empty line at \(lineIndex)")
#endif
          sourceLine = ( lineIndex, "" )
        }
        lineIndex += 1
        return ( sourceLine, isEndOfFile )
    }
    
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    
    fileprivate func lineIsEmpty( _ line: String ) -> Bool {
        return line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    
    fileprivate func lineIsNotEmpty( _ line: String ) -> Bool {
        return line.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty
    }
    
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    
    func clearSource() {
        fileString = ""
        sourceLines = [SourceLineType]()
    }
    
}
