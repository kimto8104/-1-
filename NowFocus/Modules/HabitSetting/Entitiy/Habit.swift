//
//  Habit.swift
//  FaceDownFocusTimer
//
//  Created by iosDevelopers on 2025/09/24.
//

import Foundation
import SwiftData

// @Modelマクロを使うことでSwiftDataがデータのモデルとして扱ってくれて、様々なことをしてくれる
@Model
class Habit {
    // @AttributeはSwiftDataの属性オプションで、同じ値が重複しない、ユニークなプロパティにしてくれる
    // データID
    @Attribute(.unique) var id: UUID = UUID()
    // Habit名も重複禁止にする
    @Attribute(.unique) var habitName: String
    // 習慣化させる理由
    var reason: String?
    
    init (habitName: String, reason: String? = nil) {
        self.habitName = habitName
        self.reason = reason
    }
}
