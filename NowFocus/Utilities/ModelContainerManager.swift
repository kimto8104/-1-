//
//  ModelContainerManager.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/01/25.
//

import SwiftData

class ModelContainerManager {
  static let shared = ModelContainerManager()
  let container: ModelContainer?
  private init() {
    do {
      container = try ModelContainer(for: FocusHistory.self)
    } catch {
      print("Failed to save SwiftData at \(#line) Fix It")
      container = nil
    }
  }
  
  @MainActor func saveFocusHistory(history: FocusHistory) {
    print("ModelContainerManager: 保存開始 - カテゴリー: \(history.category ?? "nil"), 時間: \(history.duration)")
    self.container?.mainContext.insert(history)
    do {
        try self.container?.mainContext.save()
        print("ModelContainerManager: 保存成功 - カテゴリー: \(history.category ?? "nil"), 時間: \(history.duration)")
    } catch {
        print("ModelContainerManager: 保存失敗 - \(error)")
    }
  }
}
