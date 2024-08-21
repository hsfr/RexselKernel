//
//  Source.swift
//  RexselKernel
//
//  Copyright 2024 Hugh Field-Richards. All rights reserved.

import Foundation

typealias SourceLineType = ( index: Int, line: String )

public class Source: NSObject {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Instance properties
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

    let isLogging = false  // Adjust as required

    /// File held as a string
    public var fileString: String = ""

    /// Array pf source file lines
    var sourceLines: [SourceLineType] = []

    /// Array pf source file lines
    var normalosedSourceLines: [SourceLineType] = []

    /// Index of next line to read
    var lineIndex = 0

    /// End of file (last line) reached.
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
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // MARK: - Public Methods
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Prime compiler from string
    ///
    /// - Parameters:
    ///   - source: A string of the entire stylesheet to be translated.

    public func readIntoCompilerString( _ source: String ) {
        let lines = source.components( separatedBy: "\n" )
        clearSource()
        for i in 0..<lines.count {
            sourceLines.append( ( i, lines[i] ) )
        }
        lineIndex = 0
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Get nextline from the existing source.
    ///
    /// Useful when testing.
    ///
    /// - Returns: ( ( index of line, source line ), _true_ if end of file )

    func getLineFromSource() -> ( sourceLine: SourceLineType, endOfFile: Bool ) {
        if isLogging {
            rLogger.log( self, .debug,"Getting line \(lineIndex) ")
        }

        guard !isEndOfFile else {
            lineIndex = 0
            return ( ( 0, "" ), true )
        }

        var sourceLine = sourceLines[ lineIndex ]

        if isLogging {
            rLogger.log( self, .debug,"  fetched line at \(lineIndex): \(sourceLine.line)")
        }

        if lineIsNotEmpty( sourceLine.line ) && lineIndex <= sourceLines.count {
            sourceLine = sourceLines[ lineIndex ]
        } else {
            if isLogging {
                rLogger.log( self, .debug,"  Empty line at \(lineIndex)")
            }
            sourceLine = ( lineIndex, "" )
        }

        lineIndex += 1
        return ( sourceLine, isEndOfFile )
    }


    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Prime compiler from file
    ///
    /// - Parameters:
    ///   - fileName: Name of the file containing stylesheet to be translated.
    ///   - inFolder: Folder with the file.

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
    //
    /// Get nextline from the stylesheet
    ///
    /// - Returns: ( ( index of line, source line ), _true_ if end of file )

    func getLineFromSourcePanel() -> ( sourceLine: SourceLineType, endOfFile: Bool ) {
        if isLogging {
            rLogger.log( self, .debug,"Getting line \(lineIndex) ")
        }

        guard !isEndOfFile else {
            lineIndex = 0
            return ( ( 0, "" ), true )
        }

        var sourceLine = sourceLines[ lineIndex ]

        if isLogging {
            rLogger.log( self, .debug,"  fetched line at \(lineIndex): \(sourceLine.line)")
        }

        if lineIsNotEmpty( sourceLine.line ) && lineIndex <= sourceLines.count {
            sourceLine = sourceLines[ lineIndex ]
        } else {
            if isLogging {
                rLogger.log( self, .debug,"  Empty line at \(lineIndex)")
            }
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
