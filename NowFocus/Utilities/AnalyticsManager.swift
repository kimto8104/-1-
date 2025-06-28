//
//  AnalyticsManager.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/06/23.
//

import Foundation
import FirebaseAnalytics

/// Firebase Analyticsのラッパークラス
/// アプリ全体で一貫したイベント送信を管理
class AnalyticsManager {
    
    // MARK: - Singleton
    static let shared = AnalyticsManager()
    private init() {}
    
    // MARK: - Event Types
    enum EventType: String {
        case appLaunch = "app_launch"
        case timerStart = "timer_start"
        case timerPause = "timer_pause"
        case timerResume = "timer_resume"
        case timerComplete = "timer_complete"
        case timerCancel = "timer_cancel"
        case categoryAdd = "category_add"
        case categoryDelete = "category_delete"
        case focusSessionStart = "focus_session_start"
        case focusSessionComplete = "focus_session_complete"
        case consecutiveDaysAchieved = "consecutive_days_achieved"
        case settingsChanged = "settings_changed"
        case screenView = "screen_view"
    }
    
    // MARK: - Parameter Keys
    enum ParameterKey: String {
        case duration = "duration"
        case category = "category"
        case categoryName = "category_name"
        case consecutiveDays = "consecutive_days"
        case settingName = "setting_name"
        case settingValue = "setting_value"
        case timestamp = "timestamp"
        case debugMode = "debug_mode"
        case screenName = "screen_name"
        case screenClass = "screen_class"
    }
    
    // MARK: - Public Methods
    
    /// アプリ起動イベントを送信
    func logAppLaunch() {
        logEvent(.appLaunch, parameters: [
            ParameterKey.timestamp.rawValue: Date().timeIntervalSince1970,
            ParameterKey.debugMode.rawValue: isDebugMode
        ])
    }
    
    /// タイマー開始イベントを送信
    /// - Parameters:
    ///   - duration: タイマーの時間（秒）
    ///   - category: カテゴリ名
    func logTimerStart(category: String) {
        logEvent(.timerStart, parameters: [
            ParameterKey.category.rawValue: category,
            ParameterKey.timestamp.rawValue: Date().timeIntervalSince1970
        ])
    }
    
    /// タイマー一時停止イベントを送信
    /// - Parameters:
    ///   - duration: 残り時間（秒）
    ///   - category: カテゴリ名
    func logTimerPause(duration: TimeInterval, category: String) {
        logEvent(.timerPause, parameters: [
            ParameterKey.duration.rawValue: duration,
            ParameterKey.category.rawValue: category,
            ParameterKey.timestamp.rawValue: Date().timeIntervalSince1970
        ])
    }
    
    /// タイマー再開イベントを送信
    /// - Parameters:
    ///   - duration: 残り時間（秒）
    ///   - category: カテゴリ名
    func logTimerResume(duration: TimeInterval, category: String) {
        logEvent(.timerResume, parameters: [
            ParameterKey.duration.rawValue: duration,
            ParameterKey.category.rawValue: category,
            ParameterKey.timestamp.rawValue: Date().timeIntervalSince1970
        ])
    }
    
    /// タイマー完了イベントを送信
    /// - Parameters:
    ///   - duration: 完了した時間（秒）
    ///   - category: カテゴリ名
    func logTimerComplete(duration: TimeInterval, category: String) {
        logEvent(.timerComplete, parameters: [
            ParameterKey.duration.rawValue: duration,
            ParameterKey.category.rawValue: category,
            ParameterKey.timestamp.rawValue: Date().timeIntervalSince1970
        ])
    }
    
    /// タイマーキャンセルイベントを送信
    /// - Parameters:
    ///   - duration: キャンセル時の残り時間（秒）
    ///   - category: カテゴリ名
    func logTimerCancel(duration: TimeInterval, category: String) {
        logEvent(.timerCancel, parameters: [
            ParameterKey.duration.rawValue: duration,
            ParameterKey.category.rawValue: category,
            ParameterKey.timestamp.rawValue: Date().timeIntervalSince1970
        ])
    }
    
    /// カテゴリ追加イベントを送信
    /// - Parameter categoryName: 追加されたカテゴリ名
    func logCategoryAdd(categoryName: String) {
        logEvent(.categoryAdd, parameters: [
            ParameterKey.categoryName.rawValue: categoryName,
            ParameterKey.timestamp.rawValue: Date().timeIntervalSince1970
        ])
    }
    
    /// カテゴリ削除イベントを送信
    /// - Parameter categoryName: 削除されたカテゴリ名
    func logCategoryDelete(categoryName: String) {
        logEvent(.categoryDelete, parameters: [
            ParameterKey.categoryName.rawValue: categoryName,
            ParameterKey.timestamp.rawValue: Date().timeIntervalSince1970
        ])
    }
    
    /// フォーカスセッション開始イベントを送信
    /// - Parameters:
    ///   - duration: セッション時間（秒）
    ///   - category: カテゴリ名
    func logFocusSessionStart(duration: TimeInterval, category: String) {
        logEvent(.focusSessionStart, parameters: [
            ParameterKey.duration.rawValue: duration,
            ParameterKey.category.rawValue: category,
            ParameterKey.timestamp.rawValue: Date().timeIntervalSince1970
        ])
    }
    
    /// フォーカスセッション完了イベントを送信
    /// - Parameters:
    ///   - duration: 完了した時間（秒）
    ///   - category: カテゴリ名
    func logFocusSessionComplete(duration: TimeInterval, category: String) {
        logEvent(.focusSessionComplete, parameters: [
            ParameterKey.duration.rawValue: duration,
            ParameterKey.category.rawValue: category,
            ParameterKey.timestamp.rawValue: Date().timeIntervalSince1970
        ])
    }
    
    /// 連続日数達成イベントを送信
    /// - Parameter consecutiveDays: 達成した連続日数
    func logConsecutiveDaysAchieved(consecutiveDays: Int) {
        logEvent(.consecutiveDaysAchieved, parameters: [
            ParameterKey.consecutiveDays.rawValue: consecutiveDays,
            ParameterKey.timestamp.rawValue: Date().timeIntervalSince1970
        ])
    }
    
    /// 設定変更イベントを送信
    /// - Parameters:
    ///   - settingName: 変更された設定名
    ///   - settingValue: 新しい設定値
    func logSettingsChanged(settingName: String, settingValue: String) {
        logEvent(.settingsChanged, parameters: [
            ParameterKey.settingName.rawValue: settingName,
            ParameterKey.settingValue.rawValue: settingValue,
            ParameterKey.timestamp.rawValue: Date().timeIntervalSince1970
        ])
    }
    
    /// 画面表示イベントを送信
    /// - Parameters:
    ///   - screenName: 画面名
    ///   - screenClass: 画面クラス名
    func logScreenView(screenName: String, screenClass: String) {
        logEvent(.screenView, parameters: [
            ParameterKey.screenName.rawValue: screenName,
            ParameterKey.screenClass.rawValue: screenClass,
            ParameterKey.timestamp.rawValue: Date().timeIntervalSince1970
        ])
    }
    
    // MARK: - Private Methods
    
    /// イベントを送信する内部メソッド
    /// - Parameters:
    ///   - eventType: イベントタイプ
    ///   - parameters: パラメータ
    private func logEvent(_ eventType: EventType, parameters: [String: Any]? = nil) {
        #if DEBUG
        print("📊 Analytics Event: \(eventType.rawValue)")
        if let parameters = parameters {
            print("📊 Parameters: \(parameters)")
        }
        #endif
        
        Analytics.logEvent(eventType.rawValue, parameters: parameters)
    }
    
    /// デバッグモードかどうかを判定
    private var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
