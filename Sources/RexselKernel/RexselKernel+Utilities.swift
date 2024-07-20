//
//  RexselKernel+Utilities.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 19/07/2024.
//

import Foundation

extension RexselKernel {

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Return list of close matches.
    ///
    /// The critera for a close match is when weighting
    /// is greater than 0.9.
    ///
    /// - Parameters:
    ///   - str : String to compare
    ///   - list : List of potential matches.
    /// - Returns: Array of found close matches.

    func getListOfCloseMatches( _ str: String, with withList: [String] ) -> [String] {
        var returnList = [String]()
        for entry in withList {
            if jaroWinklerMatch( str, entry ) > 0.9 {
                returnList.append(entry)
            }
        }
        return returnList
    }

    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
    //
    /// Matching strings based on Jara-Winkler matching.
    ///
    /// Based on solution in RosettaCode. It also relies on the
    /// String extension for subscripted strings.
    ///
    /// - Parameters:
    ///   - str_1 : String to compare with *str_2*
    ///   - str_2 : String to compare with *str_1*
    /// - Returns: Matching index 0...1, where 1 is match and 0 is no match.

    func jaroWinklerMatch(_ str_1: String, _ str_2: String) -> Double {

        // Convenience constants for later.
        let str_1_len: Int = str_1.count
        let str_2_len: Int = str_2.count

        // If both strings are empty then "match".
        if str_1_len == 0 && str_2_len == 0 {
            return 1.0
        }

        // If one or other strings are empty then no match.
        if str_1_len == 0 || str_2_len == 0 {
            return 0.0
        }

        var match_distance: Int = 0

        if str_1_len == 1 && str_2_len == 1 {
            match_distance = 1
        } else {
            match_distance = ([str_1_len, str_2_len].max()!/2) - 1
        }

        var str_1_matches = [Bool]()
        var str_2_matches = [Bool]()

        // Set up matches array to be correct length (Swift does not have sizing when initializing).
        for _ in 1...str_1_len { str_1_matches.append(false) }
        for _ in 1...str_2_len { str_2_matches.append(false) }

        var matches: Double = 0.0
        var transpositions: Double = 0.0

        // Scan the str_1 characters
        for i in 0...str_1_len-1 {

            let start = [0, (i-match_distance)].max()!
            let end = [(i + match_distance), str_2_len-1].min()!

            if start > end {
                break
            }

            for j in start...end {
                if str_2_matches[j] { continue }

                if str_1[i] != str_2[j] {
                    continue
                }
        
                // We must have a match
                str_1_matches[i] = true
                str_2_matches[j] = true
                matches += 1
                break
            }
        }

        if matches == 0 {
            return 0.0
        }

        var k = 0
        for i in 0...str_1_len-1 {
            if !str_1_matches[i] {
                continue
            }
            while !str_2_matches[k] {
                k += 1
            }
            if str_1[i] != str_2[k] {
                transpositions += 1
            }

            k += 1
        }

        let top = ( matches / Double(str_1_len) ) + ( matches / Double(str_2_len ) ) + ( matches - ( transpositions / 2 ) ) / matches
        return top/3
    }

}
