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
        GradientBackgroundUtil.gradientBackground(size: gp.size, multiplier: multiplier)
        
        VStack(spacing: 20 * multiplier) {
          // カテゴリー選択ボタン
          Button {
            showingCategoryList = true
          } label: {
            HStack {
              Text(viewModel.selectedCategory ?? "全て")
                .font(.custom("IBM Plex Mono", size: 16 * multiplier))
                .foregroundColor(.black)
              Spacer()
              Text("▼")
                .foregroundColor(.black)
            }
            .padding(.horizontal, 20 * multiplier)
            .padding(.vertical, 10 * multiplier)
            .frame(width: 320 * multiplier, height: 54 * multiplier)
            .background(Color(hex: "FFFAFA")!.opacity(0.8))
            .cornerRadius(20 * multiplier)
          }
          
          // 合計集中時間
          VStack {
            Text(viewModel.selectedCategory == nil ? "合計集中時間" : "\(viewModel.selectedCategory!)の集中時間")
              .foregroundColor(.black)
              .shadow(color: .black.opacity(0.2), radius: 2 * multiplier, x: 0, y: 4 * multiplier)
              .font(.custom("IBM Plex Mono", size: 24 * multiplier))
              .padding(.bottom, 10)
            
            Text(viewModel.formatDuration(viewModel.filteredDuration))
              .foregroundColor(.black)
              .shadow(color: .black.opacity(0.2), radius: 2 * multiplier, x: 0, y: 4 * multiplier)
              .font(.custom("IBM Plex Mono", size: 44 * multiplier))
          }
          
          Spacer()
            .frame(width: 60 * multiplier, height: 60 * multiplier)
        }
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
//    .ignoresSafeArea()
  }
  
  private func categoryListView(multiplier: CGFloat) -> some View {
    NavigationView {
      List {
        Button {
          viewModel.selectCategory(nil)
          showingCategoryList = false
        } label: {
          HStack {
            Text("全て")
              .foregroundColor(.black)
            Spacer()
            if viewModel.selectedCategory == nil {
              Image(systemName: "checkmark")
                .foregroundColor(.blue)
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
                .foregroundColor(.black)
              Spacer()
              if viewModel.selectedCategory == category {
                Image(systemName: "checkmark")
                  .foregroundColor(.blue)
              }
            }
          }
        }
      }
      .navigationTitle("カテゴリー選択")
      .navigationBarTitleDisplayMode(.inline)
    }
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

#Preview {
  HistoryPage()
}
