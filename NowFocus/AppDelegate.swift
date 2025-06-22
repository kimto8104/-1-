//
//  AppDelegate.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2023/05/02.
//

import Foundation
import UIKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
      if granted {
        print("通知の許可が得られました")
      } else if let error = error {
        print(error.localizedDescription)
      }
    }
    return true
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // バックグラウンド復帰時にもリセットを確認
    UserDefaultManager.resetDailyDataIfDateChanged()
  }
}
