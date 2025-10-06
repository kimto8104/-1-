//
//  FocusHistory.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/01/07.
//

import Foundation
import SwiftData

@Model
class FocusHistory {
    // データID
    @Attribute(.unique) var id: UUID = UUID()
    // 開始日付
    var startDate: Date
    // 集中時間
    var duration: TimeInterval
    // 紐づくHabit（逆参照は Habit 側で指定済み）
    var habit: Habit
    
    init(startDate: Date, duration: TimeInterval, habit: Habit) {
        self.startDate = startDate
        self.duration = duration
        self.habit = habit
    }
}
