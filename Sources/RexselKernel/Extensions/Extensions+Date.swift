//
//  Extensions+Date.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 12/08/2024.
//

import Foundation

extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    var microsecondsSince1970: Double {
        Double((self.timeIntervalSince1970 * 1000000.0).rounded())
    }
}
