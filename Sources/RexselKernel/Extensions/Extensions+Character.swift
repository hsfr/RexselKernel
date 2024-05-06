//
//  Extensions+Character.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 24/12/2023.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension Character {

   func isAlphaCharacter() -> Bool
   {
      return ( self >= "a" && self <= "z" ) || ( self >= "A" && self <= "Z" )
   }

   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

   func isNumericCharacter() -> Bool
   {
      return ( self >= "0" && self <= "9" )
   }

   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

   func isAlphaNumericCharacter() -> Bool
   {
      return isAlphaCharacter() || isNumericCharacter()
   }

   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
   // -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

   func isHexCharacter() -> Bool
   {
      switch self {
         case "a"..<"f", "h", "r" :
            return true
         case "A"..<"F", "H", "R" :
            return true
         default : return false
      }

   }
}

