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

// MARK: - View
struct TimerPage<T: TimerPresenterProtocol>: View {
  @Environment(\.modelContext) private var modelContext
  @StateObject var presenter: T
  @State private var progress: CGFloat = 0
  @State private var showResultView: Bool = false
  var id: UUID = UUID()
  @Binding var isTimerPageActive: Bool // タブ表示制御用のバインディング
  var body: some View {
    GeometryReader { gp in
      let hm = gp.size.width / 375
      let vm = gp.size.height / 667
      let multiplier = abs(hm - 1) < abs(vm - 1) ? hm : vm
      ZStack {
        GradientBackgroundUtil.gradientBackground(size: gp.size, multiplier: multiplier)
        if !showResultView {
          let _ = print("TimerPage's: \(presenter.showAlertForPause) + \(presenter.isFaceDown)")
          timerView(gp: gp, multiplier: multiplier)
        } else if presenter.totalFocusTime?.isEmpty != nil {
          // 結果画面を表示する
          resultView(gp: gp, multiplier: multiplier)
            .transition(.blurReplace)
        }
      }
    }
    .onAppear(perform: {
      print("TImerPageViewが現れた：\(self.id)")
      presenter.startMonitoringDeviceMotion()
      withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
        progress = 1
      }
    })
    .onChange(of: presenter.isFaceDown,{ _, newValue in
      if presenter.timerState != .start { self.isTimerPageActive = true }
      if newValue == false && presenter.timerState == .completed {
        // SwiftData にFocusHistoryを保存
        if let startDate = presenter.startDate , let totalFocusTimeInTimeInterval = presenter.totalFocusTimeInTimeInterval {
          let focusHistory = FocusHistory(startDate: startDate, duration: totalFocusTimeInTimeInterval)
          modelContext.insert(focusHistory)
          do {
            // SwiftDataに変更があれば保存
            if modelContext.hasChanges {
              try modelContext.save()
            }
          } catch {
            print("Failed to save SwiftData at \(#line) Fix It")
          }
        }
        
        //画面が上向きで集中が完了してるなら結果画面を表示する
        withAnimation(.easeInOut(duration: 1.0)) {
          showResultView = true
        }
      }
    })
    .ignoresSafeArea()
    .alert("タイマーをリセットしました", isPresented: $presenter.showAlertForPause) {
      Button("OK") {
        presenter.resetTimer()
        presenter.updateTimerState(timerState: .start)
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
        .opacity(showResultView ? 0 : 1)
      circleTimer(multiplier: multiplier, time: presenter.time)
        .opacity(showResultView ? 0 : 1)
        .overlay(
          Circle()
            .stroke(.clear, lineWidth: 2)
            .overlay(Circle()
              .trim(from: max(0, progress - 0.1), to: progress)
              .stroke(
                LinearGradient(colors: [.white, .black ], startPoint: .leading, endPoint: .trailing),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
              ).blur(radius: 2)))
      
    }.position(x: gp.size.width / 2, y: gp.size.height / 2)
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
          
          Text("\(presenter.totalFocusTime ?? "20分14秒")")
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
            let _ = print("この結果画面を出す前のTimerPageViewのIDは: \(self.id)")
            withAnimation(.easeInOut(duration: 1.0)) {
              showResultView = false // 結果画面を閉じる
              isTimerPageActive = false
            }
            presenter.resetTimer()
            presenter.updateTimerState(timerState: .start)
            presenter.startMonitoringDeviceMotion()
            
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

struct TimerPage_Previews: PreviewProvider {
  static var previews: some View {
    @Previewable @State var isTimerPageActive: Bool = true
    
    TimerRouter.initializeTimerModule(with: 1, isTimerPageActive: $isTimerPageActive)
  }
}
