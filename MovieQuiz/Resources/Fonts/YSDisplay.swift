//
//  YSDisplay.swift
//  MovieQuiz
//
//  Created by Алина Тихомирова on 30.04.2025.
//

import UIKit

enum YSDisplay: String {
    case bold = "-Bold"
    case medium = "-Medium"
    
    func font(with size: CGFloat) -> UIFont {
        UIFont(name: "YSDisplay\(self.rawValue)", size: size) ?? .systemFont(ofSize: size)
    }
}
