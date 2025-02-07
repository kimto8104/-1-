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
  // カテゴリー
  var category: String?
  
  init(startDate: Date, duration: TimeInterval, category: String? = nil) {
    self.startDate = startDate
    self.duration = duration
    self.category = category
  }
}
