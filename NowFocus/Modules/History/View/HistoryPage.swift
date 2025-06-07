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
  
  var body: some View {
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
            // ヘッダー
            Text("集中履歴")
              .font(.system(size: 24 * multiplier, weight: .medium))
              .foregroundColor(Color(hex: "#212529")!)
              .padding(.bottom, 10 * multiplier)
            
            // カテゴリー選択ボタン
            categorySelectionButton(multiplier: multiplier)
              .padding(.bottom, 10 * multiplier)
            
            // 合計集中時間カード
            timeStatisticsCard(gp: gp, multiplier: multiplier)
            
            // 履歴リスト
            ScrollView {
              LazyVStack(spacing: 12 * multiplier) {
                // フィルター適用されたリスト表示
                let filteredHistory = viewModel.selectedCategory == nil ? 
                  allHistory : 
                  allHistory.filter { $0.category == viewModel.selectedCategory }
                
                ForEach(filteredHistory.sorted(by: { $0.startDate > $1.startDate })) { history in
                  historyCardView(history: history, multiplier: multiplier)
                }
              }
              .padding(.horizontal, 5 * multiplier)
            }
          }
          
          Spacer() // 下部スペース
        }
        .padding(.horizontal, 20 * multiplier)
      }
      .sheet(isPresented: $showingCategoryList) {
        categoryListView(multiplier: multiplier)
      }
    }
    .onAppear {
      print("HistoryPage: onAppear - 履歴数: \(allHistory.count)")
      print("HistoryPage: カテゴリー一覧: \(allHistory.compactMap { $0.category })")
      viewModel.updateHistory(with: allHistory)
    }
  }
  
  // カテゴリー選択ボタン
  private func categorySelectionButton(multiplier: CGFloat) -> some View {
    Button {
      showingCategoryList = true
    } label: {
      HStack(spacing: 10 * multiplier) {
        Image(systemName: "tag.fill")
          .font(.system(size: 16 * multiplier))
          .foregroundColor(Color(hex: "#339AF0")!)
        
        Text(viewModel.selectedCategory ?? "全てのカテゴリー")
          .font(.system(size: 18 * multiplier, weight: .medium))
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
  
  // 集中時間統計カード
  private func timeStatisticsCard(gp: GeometryProxy, multiplier: CGFloat) -> some View {
    VStack(spacing: 16 * multiplier) {
      // カテゴリー名またはテキスト
      Text(viewModel.selectedCategory == nil ? "合計集中時間" : "\(viewModel.selectedCategory!)の集中時間")
        .font(.system(size: 20 * multiplier, weight: .medium))
        .foregroundColor(Color(hex: "#495057")!)
      
      // 時間表示
      Text(viewModel.formatDuration(viewModel.filteredDuration))
        .font(.system(size: 36 * multiplier, weight: .semibold, design: .monospaced))
        .foregroundColor(Color(hex: "#339AF0")!)
        .tracking(-0.5) // 文字間隔を少し詰める
        .lineLimit(1)
        .minimumScaleFactor(0.7) // 長い時間でも表示できるように
        .padding(.vertical, 10 * multiplier)
      
      // 小さい説明文
      Text("これまでの集計")
        .font(.system(size: 14 * multiplier))
        .foregroundColor(Color(hex: "#868E96")!)
    }
    .padding(.vertical, 30 * multiplier)
    .padding(.horizontal, 25 * multiplier)
    .frame(width: gp.size.width * 0.85)
    .background(
      RoundedRectangle(cornerRadius: 16 * multiplier)
        .fill(Color.white)
        .shadow(color: Color(hex: "#ADB5BD")!.opacity(0.15), radius: 8, x: 0, y: 4)
    )
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
            Text("全てのカテゴリー")
              .font(.system(size: 16 * multiplier))
              .foregroundColor(Color(hex: "#495057")!)
            Spacer()
            if viewModel.selectedCategory == nil {
              Image(systemName: "checkmark")
                .foregroundColor(Color(hex: "#339AF0")!)
            }
          }
        }
        
        ForEach(Array(viewModel.categoryDurations.keys.sorted()), id: \.self) { category in
          Button {
            viewModel.selectCategory(category)
            showingCategoryList = false
          } label: {
            HStack {
              Text(category)
                .font(.system(size: 16 * multiplier))
                .foregroundColor(Color(hex: "#495057")!)
              Spacer()
              if viewModel.selectedCategory == category {
                Image(systemName: "checkmark")
                  .foregroundColor(Color(hex: "#339AF0")!)
              }
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
  
  // 履歴カード表示
  private func historyCardView(history: FocusHistory, multiplier: CGFloat) -> some View {
    VStack(alignment: .leading, spacing: 10 * multiplier) {
      // 日付と時間
      HStack {
        Text(formatDate(history.startDate))
          .font(.system(size: 16 * multiplier, weight: .medium))
          .foregroundColor(Color(hex: "#495057")!)
        
        Spacer()
        
        Text(viewModel.formatDuration(history.duration))
          .font(.system(size: 16 * multiplier, weight: .semibold))
          .foregroundColor(Color(hex: "#228BE6")!)
      }
      
      // カテゴリーとトリガー回数
      HStack {
        if let category = history.category {
          // カテゴリー表示
          HStack(spacing: 6 * multiplier) {
            Image(systemName: "tag.fill")
              .font(.system(size: 14 * multiplier))
              .foregroundColor(Color(hex: "#228BE6")!)
            
            Text(category)
              .font(.system(size: 14 * multiplier))
              .foregroundColor(Color(hex: "#495057")!)
          }
        }
        
        Spacer()
        
        // 上向き回数表示
        HStack(spacing: 6 * multiplier) {
          Image(systemName: "rotate.3d")
            .font(.system(size: 14 * multiplier))
            .foregroundColor(Color(hex: "#228BE6")!)
        }
      }
    }
    .padding(.horizontal, 16 * multiplier)
    .padding(.vertical, 14 * multiplier)
    .background(
      RoundedRectangle(cornerRadius: 12 * multiplier)
        .fill(Color.white)
        .shadow(color: Color(hex: "#ADB5BD")!.opacity(0.1), radius: 4, x: 0, y: 2)
    )
  }
  
  // 日付フォーマット
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    return formatter.string(from: date)
  }
}

// MARK: ViewModel
class HistoryViewModel: ObservableObject {
  @Published var allHistory: [FocusHistory] = []
  @Published var categoryDurations: [String: TimeInterval] = [:]
  @Published var selectedCategory: String? = nil
  
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
    print("HistoryViewModel: 更新開始 - 履歴数: \(history.count)")
    self.allHistory = history
    updateCategoryDurations()
    
    // 選択中のカテゴリーが削除されていた場合、選択を解除
    if let selectedCategory = selectedCategory,
       !categoryDurations.keys.contains(selectedCategory) {
      self.selectedCategory = nil
    }
  }
  
  private func updateCategoryDurations() {
    var durations: [String: TimeInterval] = [:]
    
    for history in allHistory {
      if let category = history.category {  // nilの場合は集計しない
        durations[category, default: 0] += history.duration
      }
    }
    
    print("HistoryViewModel: カテゴリー集計結果: \(durations)")
    categoryDurations = durations
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
    selectedCategory = category
  }
}

// カードに上向き回数表示を追加
struct HistoryItemCard: View {
  let history: FocusHistory
  let multiplier: CGFloat
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8 * multiplier) {
      // 既存のコード
      
      // 上向きになった回数表示を追加
      HStack {
        Image(systemName: "rotate.3d")
          .font(.system(size: 14 * multiplier))
          .foregroundColor(Color(hex: "#228BE6")!)
      }
    }
    // ... 残りの既存のコード
  }
}

#Preview {
  HistoryPage()
}
