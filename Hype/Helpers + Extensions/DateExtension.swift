//
//  DateExtension.swift
//  Hype
//
//  Created by Ethan Perkins on 12/6/21.
//

import Foundation

extension Date {
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}
