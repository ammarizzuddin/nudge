//
//  MascotAnimationMode.swift
//  Nudge
//
//  Created by Ammar Rosli on 07/10/2026.
//

import Foundation

enum MascotAnimationMode: String, CaseIterable, Identifiable {
    case full
    case reduced
    case still

    var id: Self { self }

    var title: String {
        switch self {
        case .full:
            return "Full"
        case .reduced:
            return "Reduced"
        case .still:
            return "Still"
        }
    }
}
