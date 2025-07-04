//
//  AppDelegate.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2023/05/02.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseMessaging
import Speech

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    //    firebaseConfigure()
    FirebaseApp.configure()
    // --- FCMの設定 ---
    // Push通知のデリゲート設定
    UNUserNotificationCenter.current().delegate = self
    
    // FCMのデリゲート設定
    Messaging.messaging().delegate = self
    // Push通知の許可をリクエスト
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { _, _ in }
    )
    application.registerForRemoteNotifications()
    
    // 音声認識の許可を要求
    requestSpeechAuthorization()
    
    return true
  }
  
  // 音声認識の権限を要求
  private func requestSpeechAuthorization() {
    SFSpeechRecognizer.requestAuthorization { authStatus in
      DispatchQueue.main.async {
        switch authStatus {
        case .authorized:
          print("✅ Speech recognition authorized")
        case .denied:
          print("❌ Speech recognition denied")
        case .restricted:
          print("⚠️ Speech recognition restricted")
        case .notDetermined:
          print("❓ Speech recognition not determined")
        @unknown default:
          print("❓ Speech recognition unknown status")
        }
      }
    }
  }
  
  // APNsからデバイストークンが取得できた場合に呼ばれる
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("✅ APNsへのデバイス登録に成功しました。 deviceToken: \(deviceToken)")
    // FCMにAPNsトークンを設定
    Messaging.messaging().apnsToken = deviceToken
  }
  
  // APNsへの登録が【失敗】した場合
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("🛑 APNsへのデバイス登録に失敗しました。エラー: \(error.localizedDescription)")
  }
  
  // バックグラウンドでプッシュ通知を受信した場合に呼ばれる
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("📱 バックグラウンドでプッシュ通知を受信しました: \(userInfo)")
    
    // 通知データの処理
    handleNotificationData(userInfo)
    
    // バックグラウンド処理の完了を通知
    completionHandler(.newData)
  }
  
  // アプリがフォアグラウンドの状態で通知を受け取った場合に呼ばれる
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("📱 フォアグラウンドでプッシュ通知を受信しました: \(notification.request.content.userInfo)")
    
    // 通知データの処理
    handleNotificationData(notification.request.content.userInfo)
    
    // ここで通知の表示方法を決定（バナー、サウンドなど）
    completionHandler([[.banner, .sound]])
  }
  
  // 通知をタップした時に呼ばれる
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    print("👆 通知がタップされました: \(response.notification.request.content.userInfo)")
    
    // 通知データの処理
    handleNotificationData(response.notification.request.content.userInfo)
    
    // 必要に応じて特定の画面に遷移する処理をここに追加
    
    completionHandler()
  }
  
  // --- FCM関連のデリゲートメソッド ---
  
  // FCMトークンが更新された場合に呼ばれる
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")
    // このfcmTokenをサーバーに送信して、特定のユーザーに通知を送る際に利用します。
    
    if let token = fcmToken {
      print("📱 FCMトークン: \(token)")
      print("📱 このトークンをFirebaseコンソールで使用してテスト通知を送信できます")
    }
  }
  
  // MARK: - Private Methods
  
  /// 通知データを処理する
  /// - Parameter userInfo: 通知のユーザー情報
  private func handleNotificationData(_ userInfo: [AnyHashable: Any]) {
    print("📱 通知データを受信しました:")
    print("   - 全データ: \(userInfo)")
    
    // 通知の種類を判定
    if let notificationType = userInfo["type"] as? String {
      print("   - 通知タイプ: \(notificationType)")
      switch notificationType {
      case "focus_reminder":
        print("集中リマインダー通知を受信")
        // 集中リマインダー関連の処理
        handleFocusReminderNotification(userInfo)
      case "achievement":
        print("達成通知を受信")
        // 達成通知関連の処理
        handleAchievementNotification(userInfo)
      case "daily_reset":
        print("日次リセット通知を受信")
        // 日次リセット関連の処理
        handleDailyResetNotification(userInfo)
      default:
        print("未知の通知タイプ: \(notificationType)")
      }
    } else {
      print("   - 通知タイプが指定されていません（テスト通知の可能性）")
    }
    
    // カスタムデータの処理
    if let customData = userInfo["custom_data"] as? [String: Any] {
      print("   - カスタムデータ: \(customData)")
    }
    
    // 基本的な通知データ
    if let title = userInfo["title"] as? String {
      print("   - タイトル: \(title)")
    }
    if let body = userInfo["body"] as? String {
      print("   - 本文: \(body)")
    }
  }
  
  /// 集中リマインダー通知の処理
  private func handleFocusReminderNotification(_ userInfo: [AnyHashable: Any]) {
    // 集中リマインダー関連の処理を実装
    // 例: アプリ内で集中セッションを開始するなど
  }
  
  /// 達成通知の処理
  private func handleAchievementNotification(_ userInfo: [AnyHashable: Any]) {
    // 達成通知関連の処理を実装
    // 例: 連続日数や目標達成の表示など
  }
  
  /// 日次リセット通知の処理
  private func handleDailyResetNotification(_ userInfo: [AnyHashable: Any]) {
    // 日次リセット関連の処理を実装
    // 例: デイリーデータのリセットなど
    UserDefaultManager.resetDailyDataIfDateChanged()
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // バックグラウンド復帰時にもリセットを確認
    UserDefaultManager.resetDailyDataIfDateChanged()
  }
}
