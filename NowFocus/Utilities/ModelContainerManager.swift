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
    let container: ModelContainer

    private init() {
        do {
            // 保存対象の @Model をすべてスキーマに含める
            container = try ModelContainer(for: FocusHistory.self, Habit.self)
        } catch {
            // コンテナ生成に失敗するのは設定不備など致命的な場合が多いため fail fast
            fatalError("Failed to create SwiftData ModelContainer: \(error)")
        }
    }
    
    @MainActor func saveFocusHistory(history: FocusHistory) {
        let context = container.mainContext
        context.insert(history)
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("ModelContainerManager: 保存失敗 - \(error)")
        }
    }
    
    // Habitを保存
    @MainActor func saveHabit(habit: Habit) {
        print("Habit保存開始：\(habit)")
        let context = container.mainContext
        context.insert(habit)
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            print("ModelContainerManager: Habitの保存に失敗 - \(error)")
        }
    }
    
    @MainActor func removeCategoryFromHistory(category: String) {
        print("ModelContainerManager: カテゴリー削除開始 - \(category)")
        
        // UserDefaultsからカテゴリーを削除
        var savedCategories = UserDefaultManager.savedCategories
        // カテゴリーが一致すればUserDefaultから削除
        savedCategories.removeAll { $0 == category }
        // UserDefaultのカテゴリーを更新
        UserDefaultManager.savedCategories = savedCategories
        
        // SwiftDataの該当カテゴリーの履歴を検索
        let descriptor = FetchDescriptor<FocusHistory>(
            predicate: #Predicate<FocusHistory> { history in
                history.category == category
            }
        )
        
        let context = container.mainContext
        do {
            let histories = try context.fetch(descriptor)
            print("ModelContainerManager: 対象履歴数 - \(histories.count)")
            
            // 該当する履歴を完全に削除
            for history in histories {
                context.delete(history)
            }
            // SwiftData保存
            if context.hasChanges {
                try context.save()
            }
            print("ModelContainerManager: カテゴリー削除完了")
        } catch {
            print("ModelContainerManager: カテゴリー削除失敗 - \(error)")
        }
    }
}
