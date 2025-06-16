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
          if !model.showResultView && !model.showFailedView {
            tabBarView(multiplier: multiplier)
              .padding(.bottom, 30 * multiplier)
          }
        }
        
        // カテゴリーポップアップ
        if model.isCategoryPopupPresented {
          CategoryPopup(
            onCategorySelect: { category in
              model.selectedCategory = category
              model.isCategoryPopupPresented = false
            },
            onDismiss: {
              model.isCategoryPopupPresented = false
            }
          )
          .opacity(model.isCategoryPopupPresented ? 1 : 0)
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
      }
    }
    .onAppear(perform: {
      model.startMonitoringDeviceMotion()
      model.startProgressAnimation()
      
    })
    
    .ignoresSafeArea()
    .alert("タイマーをリセットしました", isPresented: $model.showAlertForPause) {
      Button("OK") {
//        model.delegate?.tapResetAlertOKButton()
      }
    } message: {
      Text("１分始めることが大事")
    }
  } // body ここまで
}

// MARK: Private CurrentView
extension TimerPage {
  private func currentView(gp: GeometryProxy, multiplier: CGFloat) -> some View {
    Group {
      if model.selectedTab == .Clock {
        HistoryPage()
          .environmentObject(model)
      } else if model.showFailedView {
        failedPage(gp: gp, multiplier: multiplier)
          .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
      } else if model.showResultView {
        // resultViewの代わりに空のViewを表示
        Color.clear
      } else {
        timerView(gp: gp, multiplier: multiplier)
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
          
        categorySelectionButton(multiplier: multiplier)
      }
      
      Spacer()
    }
    .padding(.horizontal, 20 * multiplier)
  }
  
  func circleTimer(multiplier: CGFloat, time: String) -> some View {
    ZStack {
      Circle()
        .trim(from: 0, to: model.progress)
        .stroke(
          LinearGradient(
            colors: [Color(hex: "#339AF0")!, Color(hex: "#228BE6")!],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          style: StrokeStyle(lineWidth: 10 * multiplier, lineCap: .round)
        )
        .frame(width: 260 * multiplier, height: 260 * multiplier)
        .rotationEffect(.degrees(-90))
      
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
        
        // 追加集中時間モードの場合は「継続中」と表示
        if model.continueFocusingMode {
          Text("継続中")
            .foregroundColor(Color(hex: "#339AF0")!)
            .font(.system(size: 16 * multiplier, weight: .medium))
        }
      }
    }
    .scaleEffect(model.isPulsating ? 1.05 : 0.95)
    .animation(
      Animation.easeInOut(duration: 1.8)
        .repeatForever(autoreverses: true),
      value: model.isPulsating
    )
    .onAppear {
      model.isPulsating = true
    }
  }
  
  func instructionText(gp: GeometryProxy, multiplier: CGFloat) -> some View {
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
  
  func categorySelectionButton(multiplier: CGFloat) -> some View {
    Button {
      model.tapCategorySelectionButton()
//      model.saveMockDataHistory()
    } label: {
      HStack(spacing: 10 * multiplier) {
        Image(systemName: "tag.fill")
          .font(.system(size: 16 * multiplier))
          .foregroundColor(Color(hex: "#339AF0")!)
        
        Text(String(localized: String.LocalizationValue(model.selectedCategory)))
          .font(.custom("IBM Plex Mono", size: 18 * multiplier))
          .fontWeight(.medium)
          .foregroundColor(Color(hex: "#495057")!)
        
        Spacer()
        
        Image(systemName: "chevron.down")
          .font(.system(size: 14 * multiplier))
          .foregroundColor(Color(hex: "#868E96")!)
      }
      .padding(.horizontal, 20 * multiplier)
      .padding(.vertical, 16 * multiplier)
      .background(
        RoundedRectangle(cornerRadius: 12 * multiplier)
          .fill(Color.white)
          .shadow(color: Color(hex: "#ADB5BD")!.opacity(0.1), radius: 4, x: 0, y: 2)
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

// MARK: - CategoryPopup Handling
extension TimerPageViewModel {
  var categoryPopupDelegate: CategoryPopupDelegate {
    CategoryPopupDelegateImpl(parent: self)
  }
  
  class CategoryPopupDelegateImpl: @preconcurrency CategoryPopupDelegate {
    private weak var parent: TimerPageViewModel?
    
    init(parent: TimerPageViewModel) {
      self.parent = parent
    }
    
    func updateCategoryList(categories: [String]) {
      // カテゴリーリストの更新は CategoryPopupViewModel に任せる
    }
    
    @MainActor func closePopup() {
      parent?.isCategoryPopupPresented = false
    }
    
    func showAddCategoryPopup() {
      // 新規カテゴリー追加ポップアップの表示は CategoryPopupViewModel に任せる
    }
    
    func hideAddCategoryPopup() {
      // 新規カテゴリー追加ポップアップの非表示は CategoryPopupViewModel に任せる
    }
    
    @MainActor func addCategory(name: String) {
      parent?.selectedCategory = name
      parent?.isCategoryPopupPresented = false
    }
    
    @MainActor func didSelectCategory(name: String) {
      parent?.selectedCategory = name
      parent?.isCategoryPopupPresented = false
    }
    
    @MainActor func removeCategoryFromHistory(category: String) {
      // カテゴリーの削除は CategoryPopupViewModel に任せる
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
