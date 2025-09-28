//
//  ModelContainerManager.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/01/25.
//

/// ModelContainerManagerは、SwiftDataを使用したフォーカス履歴の永続化を管理するクラスです。
/// 主な機能：
/// - フォーカス履歴の保存（saveFocusHistory）
/// - Habitの保存（saveHabit / saveHabitReturningErrorType）
/// - カテゴリーの削除とそれに関連する履歴の更新（removeCategoryFromHistory）
/// - SwiftDataのコンテナとコンテキストの管理
/// シングルトンパターンを採用しており、アプリケーション全体で一つのインスタンスを共有します。

import SwiftData
import Foundation
import CoreData

// ドメイン固有の保存エラー。UI文言はViewModel/Presenter側で決定する。
enum HabitSaveError: Error {
    case duplicateHabitName(name: String) // ユニーク制約違反（habitName重複）
    case unknown(underlying: Error)       // 上記以外
}

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
    
    // Habitを保存（失敗時はHabitSaveErrorへマッピングしてthrow）
    @MainActor func saveHabit(habit: Habit) throws {
        print("Habit保存開始：\(habit.name)")
        let context = container.mainContext
        context.insert(habit)
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            // 保存に失敗した場合
            let mapped = mapToHabitSaveError(from: error, habitName: habit.name)
            print("ModelContainerManager: Habitの保存に失敗 - \(error) -> mapped: \(mapped)")
            throw mapped
        }
    }
    
    // Habitを保存し、エラータイプ（あれば）を返す。UI層での分岐に便利。
    @MainActor func saveHabitReturningErrorType(habit: Habit) -> HabitSaveError? {
        do {
            try saveHabit(habit: habit)
            return nil
        } catch let e as HabitSaveError {
            return e
        } catch {
            return .unknown(underlying: error)
        }
    }
    
    // MARK: - データ取得（全件）
    
    /// すべてのHabitを取得（名前順）
    @MainActor
    func fetchAllHabits() -> [Habit] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<Habit>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        do {
            let result = try context.fetch(descriptor)
            print("ModelContainerManager: Habit全件取得 - \(result.count)件")
            return result
        } catch {
            print("ModelContainerManager: Habit全件取得に失敗 - \(error)")
            return []
        }
    }
    
    /// すべてのFocusHistoryを取得（日付降順）
    @MainActor
    func fetchAllFocusHistories() -> [FocusHistory] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<FocusHistory>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        do {
            let result = try context.fetch(descriptor)
            print("ModelContainerManager: FocusHistory全件取得 - \(result.count)件")
            return result
        } catch {
            print("ModelContainerManager: FocusHistory全件取得に失敗 - \(error)")
            return []
        }
    }
    
    /// 任意の @Model タイプの全件取得（必要なら利用）
    @MainActor
    func fetchAll<T: PersistentModel>(_ type: T.Type) throws -> [T] {
        let context = container.mainContext
        let descriptor = FetchDescriptor<T>()
        return try context.fetch(descriptor)
    }
    
    // MARK: - デバッグ用ダンプ
    
    /// すべてのデータをログにダンプ出力（確認用）
    @MainActor
    func debugPrintAllData() {
        print("===== SwiftData Dump Start =====")
        
        let habits = fetchAllHabits()
        print("Habit: \(habits.count)件")
        for (idx, h) in habits.enumerated() {
            print("[Habit \(idx)] name=\(h.name), reason=\(h.reason ?? "nil")")
        }
        
        let histories = fetchAllFocusHistories()
        print("FocusHistory: \(histories.count)件")
        for (idx, fh) in histories.enumerated() {
            print("[History \(idx)] start=\(fh.startDate), duration=\(fh.duration)")
        }
        
        print("===== SwiftData Dump End =====")
    }
}

// NSErrorを解析してHabitSaveErrorへマッピング（UI文言はここで作らない）
private extension ModelContainerManager {
    func mapToHabitSaveError(from error: Error, habitName: String) -> HabitSaveError {
        let nsError = error as NSError
        
        // Core Data/SwiftData 経由のCocoaエラーのみ対象
        guard nsError.domain == NSCocoaErrorDomain else {
            return .unknown(underlying: error)
        }
        
        // ユニーク制約違反で典型的に発生するエラーコードを判定
        if let cocoaError = error as? CocoaError {
            switch cocoaError.code {
            case .persistentStoreSaveConflicts:
                // ユニーク制約が衝突したケースで発生
                return .duplicateHabitName(name: habitName)
            case .validationMultipleErrors:
                // SwiftData/ Core Data が複数のバリデーションエラーをまとめる場合がある
                // このアプリでは重複名が主目的なので重複として扱う
                return .duplicateHabitName(name: habitName)
            default:
                break
            }
        }
        
        // 判定できなければunknownとして包む
        return .unknown(underlying: error)
    }
}
