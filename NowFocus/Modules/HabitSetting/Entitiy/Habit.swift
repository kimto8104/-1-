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
    @Attribute(.unique) var name: String
    // 習慣化させる理由
    var reason: String?
    
    // @Relationship は「Habit ⇄ FocusHistory の関連」を宣言していて、親：Habit → 子：FocusHistory の一対多を表します。
    // deleteRule: .cascade → Habitが削除されたらFocsuHistoryも削除される
    // inverse: \FocusHistory.habitは逆参照(inverse)として、子側(FocusHistory)にある親参照プロパティhabitを指定している。
    // これによりSwiftDataは両方向の関係を理解し、片方を更新するともう片方も自動的に同期される。
    // （例: history.habit = habit とすると habit.focusHistories にも反映される）。
    @Relationship(deleteRule: .cascade, inverse: \FocusHistory.habit)
    var focusHistories: [FocusHistory] = []
    
    init (habitName: String, reason: String? = nil) {
        self.name = habitName
        self.reason = reason
    }
}
