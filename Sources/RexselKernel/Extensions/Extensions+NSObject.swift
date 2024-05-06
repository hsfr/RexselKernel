//
//  Extensions+NSObject.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 24/12/2023.
//

import Foundation

// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

extension NSObject {
    var theClassName: String {
        return NSStringFromClass(type(of: self))
    }
}

