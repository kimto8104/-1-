//
//  HistoryDetailPage.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/06/15.
//

import SwiftUI
import SwiftData

struct HistoryDetailPage: View {
  @Query(animation: .bouncy) private var allHistory: [FocusHistory]
  @StateObject private var viewModel: HistoryDetailViewModel
  @State private var showingCategoryList = false
  
  init(initialCategory: String?) {
    _viewModel = StateObject(wrappedValue: HistoryDetailViewModel(initialCategory: initialCategory))
  }
  
  var body: some View {
    GeometryReader { gp in
      let hm = gp.size.width / 375
      let vm = gp.size.height / 667
      let multiplier = abs(hm - 1) < abs(vm - 1) ? hm : vm
      
      ZStack {
        // 背景グラデーション
        LinearGradient(
          gradient: Gradient(colors: [
            Color(hex: "#F8F9FA")!,
            Color(hex: "#E9ECEF")!
          ]),
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack(spacing: 20 * multiplier) {
          // カテゴリー選択ボタン
          categorySelectionButton(multiplier: multiplier)
            .padding(.top, 20 * multiplier)
          
          // 履歴リスト
          ScrollView {
            LazyVStack(spacing: 12 * multiplier) {
              ForEach(viewModel.filteredHistory.sorted(by: { $0.startDate > $1.startDate })) { history in
                historyCardView(history: history, multiplier: multiplier)
              }
            }
            .padding(.horizontal, 5 * multiplier)
          }
        }
        .padding(.horizontal, 20 * multiplier)
      }
      .sheet(isPresented: $showingCategoryList) {
        categoryListView(multiplier: multiplier)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
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
        
        Text(viewModel.selectedCategory ?? String(localized: "全てのカテゴリー"))
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
class HistoryDetailViewModel: ObservableObject {
  @Published var allHistory: [FocusHistory] = []
  @Published var categoryDurations: [String: TimeInterval] = [:]
  @Published var selectedCategory: String?
  
  var filteredHistory: [FocusHistory] {
    if let category = selectedCategory {
      return allHistory.filter { $0.category == category }
    }
    return allHistory
  }
  
  var filteredDuration: TimeInterval {
    if let category = selectedCategory {
      return categoryDurations[category] ?? 0
    }
    return totalDuration
  }
  
  var totalDuration: TimeInterval {
    allHistory.reduce(0) { $0 + $1.duration }
  }
  
  init(initialCategory: String?) {
    self.selectedCategory = initialCategory
  }
  
  func updateHistory(with history: [FocusHistory]) {
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
      if let category = history.category {
        durations[category, default: 0] += history.duration
      }
    }
    
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

#Preview {
  NavigationView {
    HistoryDetailPage(initialCategory: nil)
  }
}
