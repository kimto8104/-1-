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
  @ObservedObject var model = TimerPageViewModel()
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
          if !model.showResultView && model.selectedTab == .Home {
            timerView(gp: gp, multiplier: multiplier)
          } else if model.totalFocusTime?.isEmpty != nil && model.selectedTab != .Clock {
            let _ = print("totalFocusTime: \(model.totalFocusTime)")
            resultView(gp: gp, multiplier: multiplier)
              .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
          } else {
            HistoryPage()
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        // タブバーを下部に固定
        VStack {
          Spacer()
          if !model.showResultView {
            tabBarView(multiplier: multiplier)
              .padding(.bottom, 30 * multiplier)
          }
        }
        
        // カテゴリーポップアップ
        if model.isCategoryPopupPresented {
          let _ = print("ポップアップ表示条件成立: isCategoryPopupPresented=\(model.isCategoryPopupPresented)")
          Color.black.opacity(0.3)
          model.categoryPopup
            .opacity(model.isCategoryPopupPresented ? 1 : 0)
        }
      }
    }
    .onAppear(perform: {
//      model.delegate?.startMonitoringDeviceMotion()
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

// MARK: Private TimerPage
extension TimerPage {
  func timerView(gp: GeometryProxy, multiplier: CGFloat) -> some View {
    VStack {
      Spacer() // 上部スペース
      
      VStack(spacing: 40 * multiplier) {
        instructionText(gp: gp, multiplier: multiplier)
          .opacity(model.showResultView ? 0 : 1)
        
        circleTimer(multiplier: multiplier, time: model.remainingTime)
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
      
      // タイマーテキスト
      Text(time)
        .foregroundColor(Color(hex: "#212529")!)
        .font(.system(size: 40 * multiplier, weight: .medium, design: .monospaced))
        .monospacedDigit() // 数字が等幅になるように
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
//      model.delegate?.tapCategorySelectionButton()
    } label: {
      HStack(spacing: 10 * multiplier) {
        Image(systemName: "tag.fill")
          .font(.system(size: 16 * multiplier))
          .foregroundColor(Color(hex: "#339AF0")!)
        
        Text(model.selectedCategory ?? "カテゴリー選択")
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
      // 背景をブラー効果付きの半透明に
      Color(hex: "#212529")!.opacity(0.9)
        .ignoresSafeArea()
        .blur(radius: 0.5)
      
      // コンテンツカード
      VStack(spacing: 24 * multiplier) {
        // 成功アイコン
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 60 * multiplier))
          .foregroundColor(Color(hex: "#51CF66")!)
          .padding(.bottom, 10 * multiplier)
        
        Text("集中完了！")
          .font(.custom("IBM Plex Mono", size: 28 * multiplier))
          .fontWeight(.bold)
          .foregroundColor(.white)
        
        VStack(spacing: 10 * multiplier) {
          Text("１分から")
            .foregroundColor(Color(hex: "#DEE2E6")!)
            .font(.custom("IBM Plex Mono", size: 20 * multiplier))
          
          Text("\(model.totalFocusTime ?? "20分14秒")")
            .foregroundColor(Color(hex: "#74C0FC")!)
            .font(.custom("IBM Plex Mono", size: 42 * multiplier))
            .fontWeight(.bold)
          
          Text("も集中できた！")
            .foregroundColor(Color(hex: "#DEE2E6")!)
            .font(.custom("IBM Plex Mono", size: 20 * multiplier))
        }
        .padding(.vertical, 20 * multiplier)
        
        Text("1分からでも習慣化させよう")
          .foregroundColor(Color(hex: "#ADB5BD")!)
          .font(.custom("IBM Plex Mono", size: 16 * multiplier))
          .padding(.bottom, 10 * multiplier)
        
        Button {
          withAnimation(.easeInOut(duration: 0.5)) {
            model.showResultView = false
          }
//          model.delegate?.tapCompletedButton()
        } label: {
          Text("完了")
            .font(.custom("IBM Plex Mono", size: 18 * multiplier))
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(width: 180 * multiplier, height: 54 * multiplier)
            .background(
              LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#339AF0")!, Color(hex: "#228BE6")!]),
                startPoint: .leading,
                endPoint: .trailing
              )
            )
            .cornerRadius(27 * multiplier)
            .shadow(color: Color(hex: "#1971C2")!.opacity(0.3), radius: 8, x: 0, y: 4)
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

struct TimerPage_Previews: PreviewProvider {
  static var previews: some View {
//    TimerRouter.initializeTimerModule(with: 1)
  }
}
