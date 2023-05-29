//
//  UIColor+Extension.swift
//  MusicPlayerTestovoe
//
//  Created by MacBook Air on 27.05.2023.
//

import Foundation
import UIKit

//MARK: - Custom color for UI Elements

extension UIColor {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let backgroundColor = UIColor(named: "BackgroundColor")
    let accentColor = UIColor(named: "Accent")
}

