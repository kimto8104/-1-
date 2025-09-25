//
//  Category.swift
//  FaceDownFocusTimer
//
//  Created by iosDevelopers on 2025/09/24.
//

import Foundation
import SwiftData

@Model
class Category {
    // データID
    @Attribute(.unique) var id: UUID = UUID()
    // カテゴリー名
    var categoryName: String
    // 習慣化させる理由
    var reason: String?
    
    init (categoryName: String, reason: String? = nil) {
        self.categoryName = categoryName
        self.reason = reason
    }
}
