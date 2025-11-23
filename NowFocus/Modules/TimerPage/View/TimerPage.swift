//
//  TimerPage.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2023/03/07.
//

import SwiftUI
import AVFoundation
import CoreMotion
import SwiftData

// Presenterへ通知するためのProtocol
//protocol TimerPageDelegate: AnyObject {
//  func startMonitoringDeviceMotion()
//  func tapResetAlertOKButton()
//  func tapCompletedButton()
//  func tapCategorySelectionButton()
//}

// MARK: - View
struct TimerPage: View {
  @StateObject var model = TimerPageViewModel(motionManagerService: MotionManagerService(), timerService: TimerService(initialTime: 1))
  @State private var isShowingSettings = false
  @State private var isShowingNotificationSettings = false
  
  var body: some View {
    GeometryReader { gp in
      let hm = gp.size.width / 375
      let vm = gp.size.height / 667
      let multiplier = abs(hm - 1) < abs(vm - 1) ? hm : vm
      ZStack {
        // 新しい背景グラデーション
        LinearGradient(
          gradient: Gradient(colors: [
            Color(hex: "#F8F9FA")!,
            Color(hex: "#E9ECEF")!
          ]),
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea()
        
        // メインコンテンツ
        VStack {
          currentView(gp: gp, multiplier: multiplier)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        // タブバーを下部に固定
        VStack {
          Spacer()
          if !model.showResultView && (!model.showFailedView || model.selectedTab == .Clock) {
            tabBarView(multiplier: multiplier)
              .padding(.bottom, 30 * multiplier)
          }
        }
        
        // 連続日数お祝いポップアップ
        if model.showCelebrationPopup {
          CelebrationPopupView(
            consecutiveDays: model.consecutiveDays,
            isPresented: $model.showCelebrationPopup,
            onClose: {
              model.handleCompletionButtonTap()
            }
          )
        }
        
        // HabitSettingView - 中央表示
        if !model.isHabitAlreadyExist {
          ZStack {
            // 背景を暗くする
            Color.black.opacity(0.5)
              .ignoresSafeArea()
          }
        }
        
        // DEBUG専用: 全データ削除ボタン
        #if DEBUG
        VStack {
          HStack {
            Spacer()
            Button {
              model.deleteAllDataForDebug()
            } label: {
              Text("Delete All Data")
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.top, 50 * multiplier)
            .padding(.trailing, 20)
          }
          Spacer()
        }
        #endif
      }
    }
    .onAppear(perform: {
      model.startMonitoringDeviceMotion()
      model.startProgressAnimation()
      
      // 画面表示時にAnalyticsイベントを送信
      AnalyticsManager.shared.logScreenView(screenName: "Timer Page", screenClass: "TimerPage")
      
      // TimerPageが表示された時にHabitSettingViewを表示
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        withAnimation(.easeInOut(duration: 0.3)) {
          model.isHabitAlreadyExist = true
        }
        // Show Notification Settings on launch
        isShowingNotificationSettings = true
      }
    })
    
    .ignoresSafeArea()
    .alert("タイマーをリセットしました", isPresented: $model.showAlertForPause) {
      Button("OK") {
//        model.delegate?.tapResetAlertOKButton()
      }
    } message: {
      Text("１分始めることが大事")
    }
    .sheet(isPresented: $isShowingSettings) {
      SettingsView()
    }
    .sheet(isPresented: $isShowingNotificationSettings) {
        NotificationHalfModalSettingView()
            .presentationDetents([.medium])
    }
  } // body ここまで
}

// MARK: Private CurrentView
extension TimerPage {
  private func currentView(gp: GeometryProxy, multiplier: CGFloat) -> some View {
    ZStack(alignment: .topTrailing) {
      Group {
        if model.selectedTab == .Clock {
          HistoryPage()
            .environmentObject(model)
        } else if model.showFailedView {
          failedPage(gp: gp, multiplier: multiplier)
            .transition(.asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity), removal: .opacity))
        } else if model.showResultView {
          // resultViewの代わりに空のViewを表示
          Color.clear
        } else {
          timerView(gp: gp, multiplier: multiplier)
        }
      }
      
      // 設定ボタン (TimerView表示時のみ)
      if model.selectedTab == .Home && !model.showFailedView && !model.showResultView {
        Button {
          isShowingSettings = true
        } label: {
          Image(systemName: "gearshape.fill")
            .font(.system(size: 24 * multiplier))
            .foregroundColor(Color(hex: "#ADB5BD")!)
            .padding(20 * multiplier)
        }
        .padding(.top, 40 * multiplier) // ステータスバー分
      }
    }
  }
}

// MARK: Private TimerPage
extension TimerPage {
  func timerView(gp: GeometryProxy, multiplier: CGFloat) -> some View {
    VStack {
      Spacer() // 上部スペース
      
      VStack(spacing: 40 * multiplier) {
        instructionText(gp: gp, multiplier: multiplier)
          .opacity(model.showResultView ? 0 : 1)
        
        circleTimer(multiplier: multiplier, time: model.displayTime)
          .opacity(model.showResultView ? 0 : 1)
      }
      
      Spacer()
    }
    .padding(.horizontal, 20 * multiplier)
  }
  
  func circleTimer(multiplier: CGFloat, time: String) -> some View {
    ZStack {
      // タイマー背景円
      Circle()
        .fill(Color.white)
        .frame(width: 220 * multiplier, height: 220 * multiplier)
        .shadow(color: Color(hex: "#ADB5BD")!.opacity(0.2), radius: 10, x: 0, y: 5)
      
      VStack(spacing: 4 * multiplier) {
        // タイマーテキスト
        Text(model.displayTime)
          .foregroundColor(Color(hex: "#212529")!)
          .font(.system(size: 40 * multiplier, weight: .medium, design: .monospaced))
          .monospacedDigit() // 数字が等幅になるように
        
        // 追加集中時間モードの場合はHabit名を表示
        
          Text(model.currentHabitName)
              .foregroundStyle(.red)
              .font(.system(size: 20 * multiplier, weight: .medium))
      }
    }
  }
  
  func instructionText(gp: GeometryProxy, multiplier: CGFloat) -> some View {
    VStack(spacing: 16 * multiplier) {
      // 設定ボタン
      Button {
        model.isShowingHabitSettings = true
      } label: {
        HStack {
          Image(systemName: "gearshape.fill")
            .font(.system(size: 14 * multiplier))
            .foregroundColor(Color(hex: "#228BE6")!)
          
          Text("習慣を管理")
            .font(.system(size: 14 * multiplier, weight: .medium))
            .foregroundColor(Color(hex: "#228BE6")!)
        }
        .padding(.horizontal, 16 * multiplier)
        .padding(.vertical, 10 * multiplier)
        .background(
          RoundedRectangle(cornerRadius: 10 * multiplier)
            .fill(Color.white)
            .shadow(color: Color(hex: "#ADB5BD")!.opacity(0.15), radius: 4, x: 0, y: 2)
        )
      }
      
      // タイマー開始インストラクション
      HStack {
        Image(systemName: "arrow.turn.down.right")
          .font(.system(size: 16 * multiplier))
          .foregroundColor(Color(hex: "#228BE6")!)
        
        Text("画面を下向きにしてタイマーを開始")
          .font(.custom("IBM Plex Mono", size: 16 * multiplier))
          .foregroundColor(Color(hex: "#495057")!)
      }
      .padding(.horizontal, 20 * multiplier)
      .padding(.vertical, 12 * multiplier)
      .background(
        RoundedRectangle(cornerRadius: 12 * multiplier)
          .fill(Color(hex: "#F1F3F5")!)
      )
    }
  }
  

  
  func tabBarView(multiplier: CGFloat) -> some View {
    TabBarView(selectedTab: $model.selectedTab, multiplier: multiplier)
      .transition(.opacity)
  }
}

// MARK: ResultView②
extension TimerPage {
  func resultView(gp: GeometryProxy, multiplier: CGFloat) -> some View {
    ZStack {
      // 背景のオーバーレイ
      Color.black.opacity(0.4)
        .edgesIgnoringSafeArea(.all)
      
      // コンテンツカード
      VStack(spacing: 28 * multiplier) {
        // 達成時間の強調表示
        ZStack {
          Circle()
            .fill(Color(hex: "#339AF0")!.opacity(0.1))
            .frame(width: 160 * multiplier, height: 160 * multiplier)
            .scaleEffect(model.isResultViewAnimating ? 1 : 0.8)
          
          VStack(spacing: 4 * multiplier) {
            Text(model.totalFocusTime ?? "20分14秒")
              .font(.system(size: 42 * multiplier, weight: .bold, design: .rounded))
              .foregroundColor(Color(hex: "#339AF0")!)
            
            Text("集中")
              .font(.title2)
              .foregroundColor(Color(hex: "#339AF0")!)
              .opacity(model.isResultViewAnimating ? 1 : 0)
              .offset(y: model.isResultViewAnimating ? 0 : 10)
          }
        }
        .rotation3DEffect(
          .degrees(model.isResultViewAnimating ? 360 : 0),
          axis: (x: 0, y: 1, z: 0)
        )
        
        // メッセージ
        VStack(spacing: 12 * multiplier) {
          Text("おめでとうございます！")
            .font(.title2)
            .fontWeight(.bold)
            .opacity(model.isResultViewAnimating ? 1 : 0)
            .offset(y: model.isResultViewAnimating ? 0 : 20)
          
          Text("1分からでも習慣化させよう")
            .font(.title3)
            .opacity(model.isResultViewAnimating ? 1 : 0)
            .offset(y: model.isResultViewAnimating ? 0 : 20)
        }
        
        // 完了ボタン
        Button {
          withAnimation(.spring()) {
            model.handleCompletionButtonTap()
          }
        } label: {
          Text("完了")
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 200 * multiplier, height: 44 * multiplier)
            .background(Color.blue)
            .cornerRadius(22 * multiplier)
        }
        .opacity(model.isResultViewAnimating ? 1 : 0)
        .scaleEffect(model.isResultViewAnimating ? 1 : 0.8)
      }
      .padding(32 * multiplier)
      .background(
        RoundedRectangle(cornerRadius: 24 * multiplier)
          .fill(Color(UIColor.systemBackground))
          .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
      )
      .padding(.horizontal, 40 * multiplier)
      .scaleEffect(model.isResultViewAnimating ? 1 : 0.8)
    }
  }
}

// MARK: Failed Page
extension TimerPage {
  func failedPage(gp: GeometryProxy, multiplier: CGFloat) -> some View {
    ZStack {
      // 背景をブラー効果付きの半透明に
      Color(hex: "#212529")!.opacity(0.9)
        .ignoresSafeArea()
        .blur(radius: 0.5)
      
      // コンテンツカード
      VStack(spacing: 24 * multiplier) {
        // 失敗アイコン
        Image(systemName: "xmark.circle.fill")
          .font(.system(size: 60 * multiplier))
          .foregroundColor(Color(hex: "#FA5252")!)
          .padding(.bottom, 10 * multiplier)
        
        Text("集中が中断されました")
          .font(.custom("IBM Plex Mono", size: 28 * multiplier))
          .fontWeight(.bold)
          .foregroundColor(.white)
        
        Text("次は1分からでも始めてみましょう")
          .foregroundColor(Color(hex: "#ADB5BD")!)
          .font(.custom("IBM Plex Mono", size: 16 * multiplier))
          .padding(.bottom, 10 * multiplier)
        
        Button {
          withAnimation(.easeInOut(duration: 0.5)) {
            model.handleCompletionButtonTap()
          }
        } label: {
          Text("もう一度チャレンジ")
            .font(.custom("IBM Plex Mono", size: 18 * multiplier))
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(width: 220 * multiplier, height: 54 * multiplier)
            .background(
              LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#FA5252")!, Color(hex: "#E03131")!]),
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .cornerRadius(27 * multiplier)
            .shadow(color: Color(hex: "#C92A2A")!.opacity(0.3), radius: 8, x: 0, y: 4)
        }
      }
      .padding(.horizontal, 30 * multiplier)
      .padding(.vertical, 40 * multiplier)
      .background(
        RoundedRectangle(cornerRadius: 24 * multiplier)
          .fill(Color(hex: "#343A40")!)
          .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
      )
      .padding(.horizontal, 20 * multiplier)
    }
  }
}

#Preview("English") {
  TimerPage()
    .environment(\.locale, .init(identifier: "en"))
}

#Preview("Korean") {
  TimerPage()
    .environment(\.locale, .init(identifier: "ko"))
}

#Preview("Japanese") {
  TimerPage()
    .environment(\.locale, .init(identifier: "ja"))
}

#Preview("Traditional Chinese") {
  TimerPage()
    .environment(\.locale, .init(identifier: "zh-Hant"))
}

#Preview("Vietnamese") {
  TimerPage()
    .environment(\.locale, .init(identifier: "vi"))
}

