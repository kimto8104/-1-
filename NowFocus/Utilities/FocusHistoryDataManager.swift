//
//  FocusHistoryDataManager.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/06/07.
//

import Foundation

// 集中した記録を管理するクラス
// 保存 / 削除 / 編集など
@MainActor
class FocusHistoryDataManager {
  static let shared = FocusHistoryDataManager()
  let modelContainerManger = ModelContainerManager.shared
  
  /// データから FocusHistory を作成し、SwiftData に保存します。
  /// - Parameters:
  ///   - startDate: 開始日付
  ///   - duration: 集中時間
  ///   - habit: 紐づける親 Habit（必須）
  func saveFocusHistoryData(startDate: Date, duration: TimeInterval, habit: Habit) {
    let focusHistory = FocusHistory(
      startDate: startDate,
      duration: duration,
      habit: habit
    )
    modelContainerManger.saveFocusHistory(history: focusHistory)
  }
}

