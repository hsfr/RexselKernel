//
//  Extensions+String.swift
//  Rexsel

//
//  Created by Hugh Field-Richards on 25/10/2016.
//  Copyright © 2016 Hugh Field-Richards. All rights reserved.
//

import Foundation
import Cocoa
import RegexBuilder

extension String {
    var isValidQname : Bool {
        let regex = try! NSRegularExpression( pattern: "^[$a-zA-Z][a-zA-Z0-9]*(:[a-zA-Z][a-zA-Z0-9]*)?$",
                                              options: NSRegularExpression.Options())
        let theRange = NSMakeRange( 0, self.count )
        let n = regex.numberOfMatches( in: self,
                                       options: NSRegularExpression.MatchingOptions(),
                                       range: theRange )
        return ( n > 0 )
    }
}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension String {

    var isValidURL: Bool {
        get {
            let regEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
            let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
            return predicate.evaluate(with: self)
        }
    }

    // Return URL if file name/path
    var fileURL: URL {
        return URL(fileURLWithPath: self)
    }

    // Extract fle extension
    var pathExtension: String {
        return fileURL.pathExtension
    }

    // Get the complete filename or last path folder
    var lastPathComponent: String {
        return fileURL.lastPathComponent
    }

    // Extract the complete path
    var pathComponent: String {
        return fileURL.path
    }

    // Extract tyhe path as an array of strings (folder names).
    var pathComponents: [String] {
        return fileURL.pathComponents
    }

}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension String {

    func matchRegex( using regex: String ) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

   func countInstances(of stringToFind: String ) -> Int {
      var stringToSearch = self
      var count = 0
      repeat {
         guard let foundRange = stringToSearch.range(of: stringToFind, options: .diacriticInsensitive) else {
            break
         }
         stringToSearch = stringToSearch.replacingCharacters( in: foundRange, with: "" )
         count += 1

      } while (true)

      return count
   }

   func chopPrefix( count: Int = 1 ) -> String {
      return String( self.dropFirst( count ) )
   }

   func chopSuffix( count: Int = 1 ) -> String {
      return String( self.dropLast( count ) )
   }

   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   /// number of lines in the whole string ignoring the last new line character

   var numberOfLines: Int {
      return self.numberOfLines(in: self.startIndex..<self.endIndex, includingLastLineEnding: false)
   }

   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   /// count the number of lines in the range

   func numberOfLines( in range: NSRange, includingLastLineEnding: Bool ) -> Int
   {
      guard let characterRange = Range(range, in: self) else { return 0 }
      return self.numberOfLines(in: characterRange, includingLastLineEnding: includingLastLineEnding)
   }

   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   /// count the number of lines in the range

   func numberOfLines( in range: Range<String.Index>, includingLastLineEnding: Bool ) -> Int
   {
      guard !self.isEmpty, !range.isEmpty else { return 0 }

      var count = 0
      self.enumerateSubstrings(in: range, options: [.byLines, .substringNotRequired]) { (_, _, _, _) in
         count += 1
      }

      if includingLastLineEnding,
         let last = self[range].unicodeScalars.last,
         CharacterSet.newlines.contains(last) {
         count += 1
      }
      return count
   }

   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   /// count the number of lines at the character index (1-based).

   func lineNumber( at location: Int ) -> Int
   {
      guard !self.isEmpty, location > 0 else { return 1 }
      // Count number of lines from beginning of the text
      return self.numberOfLines( in: NSRange( location: 0, length: location ), includingLastLineEnding: true )
   }

   /// Convenience check to make condition clearer
   var isNotEmpty: Bool {
      return !self.isEmpty
   }

   /// Extract substring from index to end.
   /// ```swift
   ///   let testSubscript = "abcdefghijklmnopqrstuvwxyz"
   ///   print( testSubscript.substring( fromIndex: 5 ) )
   ///   // "fghijklmnopqrstuvwxyz"
   /// ```
   func substring( fromIndex: Int ) -> String {
      return self[min(fromIndex, count) ..< count]
   }

   /// Extract substring from beginning to index.
   /// ```swift
   ///   let testSubscript = "abcdefghijklmnopqrstuvwxyz"
   ///   print( testSubscript.substring( toIndex: 5 ) )
   ///   // "abcde"
   /// ```
   func substring( toIndex: Int ) -> String {
       return self[0 ..< max(0, toIndex)]
   }

    /// Extract single character at index.
    /// ```swift
    ///   let testSubscript = "abcdefghijklmnopqrstuvwxyz"
    ///   print( testSubscript[4] )
    ///   // "e"
    /// ```
    subscript( i: Int ) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }

    subscript ( r: Range<Int> ) -> String {
        let range = Range( uncheckedBounds: ( lower: max( 0, min( count, r.lowerBound) ),
                                              upper: min( count, max( 0, r.upperBound ) ) ) )
      let start = index( startIndex, offsetBy: range.lowerBound)
      let end = index(start, offsetBy: range.upperBound - range.lowerBound )
      return String( self[start ..< end] )
   }
}

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension String {

   /// Return decimal formatted `NSNumber` value of string
   var numberValue: NSNumber? {
      let formatter = NumberFormatter()
      formatter.numberStyle = .decimal
      return formatter.number( from: self )
   }

   /// Return `Float` value of string
   var floatValue: Float {
      return (self as NSString).floatValue
   }

   /// Return currency value of string
   var currencyString: String {
      let formatter = NumberFormatter()
      formatter.numberStyle = .currency
      formatter.maximumFractionDigits = 2
      return formatter.string( from: NSNumber( value: self.floatValue ) )!
   }

   /// Return `Int` value of string
   var intValue: Int {
      return (self as NSString).integerValue
   }

}

