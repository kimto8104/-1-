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
protocol TimerPageDelegate: AnyObject {
  func startMonitoringDeviceMotion()
  func tapResetAlertOKButton()
  func tapCompletedButton()
  func tapCategorySelectionButton()
}

// MARK: - View
struct TimerPage: View {
  @ObservedObject var model = TimerPageViewModel()
  var body: some View {
    GeometryReader { gp in
      let hm = gp.size.width / 375
      let vm = gp.size.height / 667
      let multiplier = abs(hm - 1) < abs(vm - 1) ? hm : vm
      ZStack {
        GradientBackgroundUtil.gradientBackground(size: gp.size, multiplier: multiplier)
        
        VStack {
          Spacer()
            .frame(height: 120 * multiplier)
          if !model.showResultView && model.selectedTab == .Home {
            timerView(gp: gp, multiplier: multiplier)
          } else if model.totalFocusTime?.isEmpty != nil && model.selectedTab != .Clock {
            // 結果画面を表示する
            resultView(gp: gp, multiplier: multiplier)
              .transition(.blurReplace)
          } else {
            HistoryPage()
          }
          
          Spacer()
            .frame(height: 50 * multiplier)
          if !model.showResultView {
            tabBarView(multiplier: multiplier)
          }
          
          Spacer()
            .frame(width: 60 * multiplier, height: 60 * multiplier)
            .background(.red)
        }
        .frame(width: gp.size.width, height: gp.size.height)

        if model.isCategoryPopupPresented {
          Color.black.opacity(0.3)
          model.categoryPopup
          .transition(.move(edge: .bottom))
        }
      }
    }
    .onAppear(perform: {
      model.delegate?.startMonitoringDeviceMotion()
//      model.startProgressAnimation()
    })
    
    .ignoresSafeArea()
    .alert("タイマーをリセットしました", isPresented: $model.showAlertForPause) {
      Button("OK") {
        model.delegate?.tapResetAlertOKButton()
      }
    } message: {
      Text("１分始めることが大事")
    }
  } // body ここまで
}

// MARK: Private TimerPage
extension TimerPage {
  func timerView(gp: GeometryProxy, multiplier: CGFloat) -> some View {
    VStack(spacing: 20 * multiplier) {
      instructionText(gp: gp, multiplier: multiplier)
        .opacity(model.showResultView ? 0 : 1)
      circleTimer(multiplier: multiplier, time: model.remainingTime)
        .opacity(model.showResultView ? 0 : 1)
        .overlay(
          Circle()
            .stroke(.clear, lineWidth: 2)
            .overlay(Circle()
              .trim(from: max(0, model.progress - 0.1), to: model.progress)
              .stroke(
                LinearGradient(colors: [.white, .black ], startPoint: .leading, endPoint: .trailing),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
              ).blur(radius: 2)))
      Spacer()
        .frame(height: 10 * multiplier)
      categorySelectionButton(multiplier: multiplier)
    }
  }
  
  func circleTimer(multiplier: CGFloat, time: String) -> some View {
    ZStack {
      // 背景用のCircleに影をつける
      Circle()
        .fill(Color(hex: "#D1CDCD")!).opacity(0.42)
        .shadow(color: .black.opacity(0.4), radius: 4 * multiplier, x: 10 * multiplier, y: 10 * multiplier)
        .shadow(color: Color(hex: "#FFFCFC")!.opacity(0.3), radius: 10, x: -10, y: -5)
        .frame(width: 240 * multiplier, height: 240 * multiplier)
        .transition(.blurReplace())
      Text(time)
        .foregroundColor(.black)
        .shadow(color: .black.opacity(0.5), radius: 2 * multiplier, x: 0, y: 4 * multiplier)
        .font(.custom("IBM Plex Mono", size: 44 * multiplier))
        .shadow(color: Color(hex: "#FDF3F3")?.opacity(0.25) ?? .clear, radius: 4 * multiplier, x: -4 * multiplier, y: -4 * multiplier)
        .transition(.blurReplace())
    }
  }
  
  func instructionText(gp: GeometryProxy, multiplier: CGFloat) -> some View {
    Text("画面を下向きにしてタイマーを開始")
      .frame(width: gp.size.width * 0.9, height: 60 * multiplier)
      .padding(.horizontal, 10)
      .font(.custom("IBM Plex Mono", size: 20 * multiplier))
      .transition(.blurReplace())
  }
  
  func categorySelectionButton(multiplier: CGFloat) -> some View {
    Button {
      model.delegate?.tapCategorySelectionButton()
    } label: {
      HStack(alignment: .center) {
        Spacer()
          .frame(width: 70 * multiplier)
        Text("カテゴリー")
          .font(.custom("IBM Plex Mono", size: 24 * multiplier))
          .foregroundStyle(.black)
          .minimumScaleFactor(0.5)
          .lineLimit(1)
        Spacer()
          .frame(width: 30 * multiplier)
        Text("▼")
          .frame(width: 24 * multiplier, height: 24 * multiplier)
          .foregroundStyle(.black)
        Spacer()
          .frame(width: 16 * multiplier)
      }
      .frame(width: 260 * multiplier, height: 54 * multiplier)
      .background(Color(hex: "F6F0F0"))
      .clipShape(RoundedRectangle(cornerRadius: 20 * multiplier))
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
    Color.black.opacity(0.8) // 背景を黒にする
      .ignoresSafeArea()
      .overlay(
        VStack(spacing: 20 * multiplier) {
          Text("１分から")
            .foregroundColor(.white)
            .font(.custom("IBM Plex Mono", size: 24 * multiplier))
          
          Text("\(model.totalFocusTime ?? "20分14秒")")
            .foregroundColor(.yellow)
            .font(.custom("IBM Plex Mono", size: 40 * multiplier))
            .bold()
          Text("も集中できた！")
            .foregroundColor(.white)
            .font(.custom("IBM Plex Mono", size: 32 * multiplier))
            .bold()
          Text("1分からでも習慣化させよう")
            .foregroundColor(.white)
            .font(.custom("IBM Plex Mono", size: 24 * multiplier))
            .bold()
          
          Button {
            
            withAnimation(.easeInOut(duration: 1.0)) {
              model.showResultView = false // 結果画面を閉じる
              
            }
            model.delegate?.tapCompletedButton()
          } label: {
            Text("👍完了")
              .foregroundColor(.black)
              .frame(width: 150 * multiplier, height: 50 * multiplier)
              .background(Color.white)
              .cornerRadius(10)
              .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
          }
        }
          .padding()
      )
  }
}

// MARK: Modifier
extension TimerPage {
  func delegate(_ value: TimerPageDelegate) -> Self {
    model.delegate = value
    return self
  }
}

// MARK: ViewModel
class TimerPageViewModel: ObservableObject {
  fileprivate var delegate: TimerPageDelegate?
  @Published fileprivate var selectedTab: TabIcon = .Home
  // 合計集中時間文字列
  @Published var totalFocusTime: String?
  @Published var isFaceDown: Bool = false
  @Published var timerState: TimerState = .start
  @Published var showAlertForPause = false
  @Published var remainingTime: String = "01:00"
  @Published var showResultView: Bool = false
  @Published var progress: CGFloat = 0
  
  
  // Category
  @Published var isCategoryPopupPresented = false
  var categoryPopup: CategoryPopup?  // モジュールをここで保持
  func showCategoryPopup() {
    categoryPopup = CategoryPopupRouter.createModule()
    withAnimation(.easeInOut(duration: 0.4)) {
      self.isCategoryPopupPresented = true
    }
  }
  
  func hideCategoryPopup() {
    withAnimation(.easeInOut(duration: 0.4)) {
      self.isCategoryPopupPresented = false
    }
    categoryPopup = nil
  }
//  func startProgressAnimation() {
//    progress = 0
//    withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
//      progress = 1
//    }
//  }
}

// ViewModel Method
extension TimerPageViewModel {
  
  func updateTotalFocusTime(totalFocusTimeString: String) {
    self.totalFocusTime = totalFocusTimeString
  }
  
  func updateIsFaceDown(isFaceDown: Bool) {
    self.isFaceDown = isFaceDown
  }
  
  func updateTimerState(timerState: TimerState) {
    self.timerState = timerState
  }
  
  func updateShowAlertForPause(showAlert: Bool) {
    self.showAlertForPause = showAlert
  }
  
  func updateRemainingTime(remainingTime: String) {
    self.remainingTime = remainingTime
  }
  
  func updateShowResultView(show: Bool) {
    withAnimation(.easeInOut(duration: 1.0)) {
      self.showResultView = show
    }
  }
}

struct TimerPage_Previews: PreviewProvider {
  static var previews: some View {
    TimerRouter.initializeTimerModule(with: 1)
  }
}
