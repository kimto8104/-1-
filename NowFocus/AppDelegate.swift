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
//    firebaseConfigure()
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
  
//  private func firebaseConfigure() {
//    #if DEBUG
//    let filePath = Bundle.main.path(forResource: "GoogleService-Info-Debug", ofType: "plist")
//    #else
//    let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
//    #endif
//    
//    guard let filePath = filePath else {
//      return
//    }
//    
//    guard let options = FirebaseOptions(contentsOfFile: filePath) else {
//      return
//    }
//    
//    FirebaseApp.configure(options: options)
//  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // バックグラウンド復帰時にもリセットを確認
    UserDefaultManager.resetDailyDataIfDateChanged()
  }
}
