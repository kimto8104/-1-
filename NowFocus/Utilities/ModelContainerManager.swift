//
//  ModelContainerManager.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/01/25.
//

/// ModelContainerManagerは、SwiftDataを使用したフォーカス履歴の永続化を管理するクラスです。
/// 主な機能：
/// - フォーカス履歴の保存（saveFocusHistory）
/// - カテゴリーの削除とそれに関連する履歴の更新（removeCategoryFromHistory）
/// - SwiftDataのコンテナとコンテキストの管理
/// シングルトンパターンを採用しており、アプリケーション全体で一つのインスタンスを共有します。

import SwiftData
import Foundation

@MainActor
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
    print("ModelContainerManager: 保存開始 - カテゴリー: \(history.category ?? "nil"), 時間: \(history.duration), 開始日時: \(history.startDate)")
    self.container?.mainContext.insert(history)
    do {
        try self.container?.mainContext.save()
        print("ModelContainerManager: 保存成功 - カテゴリー: \(history.category ?? "nil"), 時間: \(history.duration), 開始日時: \(history.startDate)")
    } catch {
        print("ModelContainerManager: 保存失敗 - \(error)")
    }
  }
  
  @MainActor func removeCategoryFromHistory(category: String) {
    print("ModelContainerManager: カテゴリー削除開始 - \(category)")
    
    // UserDefaultsからカテゴリーを削除
    var savedCategories = UserDefaultManager.savedCategories
    savedCategories.removeAll { $0 == category }
    // UserDefaultのカテゴリーを更新
    UserDefaultManager.savedCategories = savedCategories
    
    // SwiftDataの該当カテゴリーの履歴を検索
    let descriptor = FetchDescriptor<FocusHistory>(
      predicate: #Predicate<FocusHistory> { history in
        history.category == category
      }
    )
    
    do {
      let histories = try container?.mainContext.fetch(descriptor) ?? []
      print("ModelContainerManager: 対象履歴数 - \(histories.count)")
      
      // 該当する履歴のカテゴリーをnilに更新
      for history in histories {
        history.category = nil
      }
      // SwiftData保存
      try container?.mainContext.save()
      print("ModelContainerManager: カテゴリー削除完了")
    } catch {
      print("ModelContainerManager: カテゴリー削除失敗 - \(error)")
    }
  }
}
