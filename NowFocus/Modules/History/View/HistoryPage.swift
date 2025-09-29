//
//  History.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2024/12/25.
//

import SwiftUI
import SwiftData

struct HistoryPage: View {
  @Query(animation: .bouncy) private var allHistory: [FocusHistory]
  @StateObject private var viewModel = HistoryViewModel()
  @State private var showingCategoryList = false
  @EnvironmentObject private var timerViewModel: TimerPageViewModel  // TimerPageViewModelを環境オブジェクトとして取得
  
  var body: some View {
    NavigationView {
      GeometryReader { gp in
        let hm = gp.size.width / 375
        let vm = gp.size.height / 667
        let multiplier = abs(hm - 1) < abs(vm - 1) ? hm : vm
        
        ZStack {
          // TimerPageと同じ背景グラデーション
          LinearGradient(
            gradient: Gradient(colors: [
              Color(hex: "#F8F9FA")!,
              Color(hex: "#E9ECEF")!
            ]),
            startPoint: .top,
            endPoint: .bottom
          )
          .ignoresSafeArea()
          
          VStack {
            // 上部スペースを固定サイズに変更
            Spacer().frame(height: 60 * multiplier)
            
            VStack(spacing: 30 * multiplier) {
              // 月間カレンダー
              monthlyCalendarCard(gp: gp, multiplier: multiplier)
            }
            
            Spacer() // 下部スペース
          }
          .padding(.horizontal, 20 * multiplier)
        }
      }
      .navigationBarHidden(true)
    }
    .onAppear {
      print("HistoryPage: onAppear - 履歴数: \(allHistory.count)")
      print("HistoryPage: 履歴の詳細:")
      for (index, history) in allHistory.enumerated() {
        print("HistoryPage: 履歴\(index + 1) - 日付: \(history.startDate), 時間: \(history.duration)")
      }
      viewModel.updateHistory(with: allHistory)
      
      // 画面表示時にAnalyticsイベントを送信
      AnalyticsManager.shared.logScreenView(screenName: "History Page", screenClass: "HistoryPage")
    }
    .onChange(of: allHistory) { newValue in
      viewModel.updateHistory(with: newValue)
    }
    .onChange(of: timerViewModel.selectedTab) { oldValue, newValue in
      if newValue == .Clock {
        print("HistoryPage: Tab changed to Clock - アニメーション開始")
        viewModel.startNumberAnimation()
      }
    }
  }
  
  // 連続日数カード
  private func consecutiveDaysCard(gp: GeometryProxy, multiplier: CGFloat) -> some View {
    VStack(spacing: 16 * multiplier) {
      Text(String(localized: "連続集中日数"))
        .font(.system(size: 20 * multiplier, weight: .medium))
        .foregroundColor(Color(hex: "#495057")!)
      
      VStack(spacing: 4 * multiplier) {
        Text("\(viewModel.displayedConsecutiveDays)")
          .font(.system(size: 48 * multiplier, weight: .bold, design: .rounded))
          .foregroundColor(Color(hex: "#339AF0")!)
          .contentTransition(.numericText())
        
        Text(String(localized: "日"))
          .font(.system(size: 20 * multiplier))
          .foregroundColor(Color(hex: "#339AF0")!)
      }
      
      Text(String(localized: "現在の記録"))
        .font(.system(size: 14 * multiplier))
        .foregroundColor(Color(hex: "#868E96")!)
    }
    .padding(.vertical, 20 * multiplier)
    .padding(.horizontal, 25 * multiplier)
    .frame(width: gp.size.width * 0.85)
    .background(
      RoundedRectangle(cornerRadius: 16 * multiplier)
        .fill(Color.white)
        .shadow(color: Color(hex: "#ADB5BD")!.opacity(0.15), radius: 8, x: 0, y: 4)
    )
  }

  // 月間カレンダーカード
  private func monthlyCalendarCard(gp: GeometryProxy, multiplier: CGFloat) -> some View {
    VStack(spacing: 16 * multiplier) {
      VStack(alignment: .center, spacing: 6 * multiplier) {
        HStack(alignment: .bottom, spacing: 4 * multiplier) {
          Text("\(viewModel.consecutiveDays)")
            .font(.system(size: 64 * multiplier, weight: .bold))
            .foregroundColor(viewModel.consecutiveDays == 1 ? Color(hex: "#FA5252")! : Color(hex: "#495057")!)
          
          Text(String(localized: "日"))
            .font(.system(size: 32 * multiplier, weight: .bold))
            .foregroundColor(Color(hex: "#495057")!)
        }
        
        Text(String(localized: "連続達成！"))
          .font(.system(size: 18 * multiplier, weight: .medium))
          .foregroundColor(Color(hex: "#495057")!)
      }
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 20 * multiplier)
      .padding(.vertical, 20 * multiplier)
      
      MonthlyCalendarView(
        currentDate: viewModel.currentCalendarDate,
        focusHistory: allHistory,
        multiplier: multiplier,
        onPreviousMonth: {
          viewModel.previousMonth()
        },
        onNextMonth: {
          viewModel.nextMonth()
        }
      )
    }
    .frame(width: gp.size.width * 0.85)
  }
  
  // カテゴリー選択リスト
  private func categoryListView(multiplier: CGFloat) -> some View {
    NavigationView {
      List {
        Button {
          viewModel.selectCategory(nil)
          showingCategoryList = false
        } label: {
          HStack {
            Text(String(localized: "全てのカテゴリー"))
              .font(.system(size: 16 * multiplier))
              .foregroundColor(Color(hex: "#495057")!)
            Spacer()
            if viewModel.selectedCategory == nil {
              Image(systemName: "checkmark")
                .foregroundColor(Color(hex: "#339AF0")!)
            }
          }
        }
      }
      
      .listStyle(InsetGroupedListStyle())
      .navigationTitle("カテゴリー選択")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showingCategoryList = false
          }) {
            Image(systemName: "xmark.circle.fill")
              .font(.system(size: 20 * multiplier))
              .foregroundColor(Color(hex: "#868E96")!)
          }
        }
      }
    }
  }
}

// MARK: ViewModel
class HistoryViewModel: ObservableObject {
  @Published var allHistory: [FocusHistory] = []
  @Published var categoryDurations: [String: TimeInterval] = [:]
  @Published var selectedCategory: String? = nil
  @Published var consecutiveDays: Int = 0
  @Published var isPulsing: Bool = false
  
  // カレンダー関連の状態
  @Published var currentCalendarDate: Date = Date()
  
  // 数字アニメーション用の状態
  @Published var displayedConsecutiveDays: Int = 0
  
  init() {
    print("HistoryViewModel: 初期化")
  }
  
  var filteredDuration: TimeInterval {
    if let selectedCategory = selectedCategory {
      return categoryDurations[selectedCategory] ?? 0
    }
    return totalDuration
  }
  
  var totalDuration: TimeInterval {
    allHistory.reduce(0) { $0 + $1.duration }
  }
  
  func updateHistory(with history: [FocusHistory]) {
    print("HistoryViewModel: updateHistory開始")
    print("HistoryViewModel: 受け取った履歴数: \(history.count)")
    print("HistoryViewModel: 現在の選択カテゴリー: \(selectedCategory ?? "nil")")
    
    self.allHistory = history
    updateConsecutiveDays()
    
    // 選択中のカテゴリーが削除されていた場合、選択を解除
    if let selectedCategory = selectedCategory,
       !categoryDurations.keys.contains(selectedCategory) {
      print("HistoryViewModel: 選択中のカテゴリーが削除されたため、選択を解除: \(selectedCategory)")
      self.selectedCategory = nil
    }
  }
  
  private func updateConsecutiveDays() {
    Task { @MainActor in
      print("HistoryViewModel: updateConsecutiveDays開始")
      print("HistoryViewModel: 選択中のカテゴリー: \(selectedCategory ?? "nil")")
      // 連続日数が更新されたらアニメーションを開始
      startNumberAnimation()
    }
  }
  
  func formatDuration(_ duration: TimeInterval) -> String {
    let hours = Int(duration) / 3600
    let minutes = (Int(duration) % 3600) / 60
    let seconds = Int(duration) % 60
    
    if hours > 0 {
      return "\(hours)時間\(minutes)分\(seconds)秒"
    } else if minutes > 0 {
      return "\(minutes)分\(seconds)秒"
    } else {
      return "\(seconds)秒"
    }
  }
  
  func selectCategory(_ category: String?) {
    print("HistoryViewModel: selectCategory呼び出し")
    print("HistoryViewModel: 前のカテゴリー: \(selectedCategory ?? "nil")")
    print("HistoryViewModel: 新しいカテゴリー: \(category ?? "nil")")
    
    selectedCategory = category
    updateConsecutiveDays()  // カテゴリー変更時に連続日数を更新
  }
  
  // アニメーションを開始するメソッド
  func startPulsingAnimation() {
    isPulsing = true
  }
  
  // 数字のアニメーションを開始
  func startNumberAnimation() {
    // アニメーションの初期状態にリセット
    displayedConsecutiveDays = 0
    
    // 数字のカウントアップアニメーション
    for i in 0...consecutiveDays {
      DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
          self.displayedConsecutiveDays = i
        }
      }
    }
  }
  
  // カレンダー操作メソッド
  func previousMonth() {
    withAnimation(.easeInOut(duration: 0.3)) {
      currentCalendarDate = Calendar.current.date(byAdding: .month, value: -1, to: currentCalendarDate) ?? currentCalendarDate
    }
  }
  
  func nextMonth() {
    withAnimation(.easeInOut(duration: 0.3)) {
      currentCalendarDate = Calendar.current.date(byAdding: .month, value: 1, to: currentCalendarDate) ?? currentCalendarDate
    }
  }
}

#Preview {
  HistoryPage()
}
