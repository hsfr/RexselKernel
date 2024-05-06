//
//  RexselKernel+Enumerations.swift.swift
//  Rexsel
//
//  Created by Hugh Field-Richards on 10/01/2024.
//

import Foundation

enum YesNoEnum {
    case yes
    case no
    case unknown

    var description: String {
        switch self {
            case .yes : return "yes"
            case .no : return "no"
            case .unknown : return "unknown"
        }
    }

    static func translate( _ value: String ) -> YesNoEnum {
        switch value {
            case "yes" : return .yes
            case "no" : return .no
            default : return .unknown
        }
    }

    static func translate( _ value: Bool ) -> YesNoEnum {
        switch value {
            case true : return .yes
            case false : return .no
        }
    }
}
