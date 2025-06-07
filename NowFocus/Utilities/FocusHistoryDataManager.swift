//
//  FocusHistoryDataManager.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/06/07.
//

import Foundation
// 集中した記録を管理するクラス
// 保存
// 削除
// 編集など
@MainActor
class FocusHistoryDataManager {
  static let shared = FocusHistoryDataManager()
  let modelContainerManger = ModelContainerManager.shared
  
  // データからFocusHistoryを作成し、SwiftDataに保存をしてくれる
  // 開始日付
//  var startDate: Date
//  // 集中時間
//  var duration: TimeInterval
//  // カテゴリー
//  var category: String?
  func saveFocusHistoryData(startDate: Date, duration: TimeInterval, category: String?) {
    let focusHistory = FocusHistory(startDate: startDate, duration: duration, category: category)
    modelContainerManger.saveFocusHistory(history: focusHistory)
  }
}
