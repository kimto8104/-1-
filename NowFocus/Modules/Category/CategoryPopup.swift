//
//  CategoryPopup.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/02/01.
//

import SwiftUI

protocol CategoryPopupDelegate: AnyObject {
  func updateCategoryList(categories: [String])
  func closePopup()
  func showAddCategoryPopup()
  func hideAddCategoryPopup()
  func addCategory(name: String)
  func didSelectCategory(name: String)
  @MainActor func removeCategoryFromHistory(category: String)
}

struct CategoryPopup: View {
  @StateObject var viewModel: CategoryPopupViewModel
  
  init(
    onCategorySelect: @escaping (String) -> Void,
    onDismiss: @escaping () -> Void
  ) {
    _viewModel = StateObject(
      wrappedValue: CategoryPopupViewModel(
        onCategorySelect: onCategorySelect,
        onDismiss: onDismiss
      )
    )
  }
  
  var body: some View {
    GeometryReader { gp in
      let hm = gp.size.width / 375
      let vm = gp.size.height / 667
      let multiplier = abs(hm - 1) < abs(vm - 1) ? hm : vm
      ZStack {
        // 背景のブラー効果
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
          Spacer()
            .frame(height: 26 * multiplier)
          // ヘッダー部分
          header(multiplier: multiplier)
          
          // リスト部分
          List {
            ForEach(viewModel.categories, id: \.self) { category in
              cell(multiplier: multiplier, category: category)
                .onTapGesture {
                  viewModel.selectCategory(category)
                }
            }
            .onDelete { indexSet in
              indexSet.forEach { index in
                let category = viewModel.categories[index]
                viewModel.removeCategory(category)
              }
            }
          }
          .listStyle(PlainListStyle())
          .frame(height: 400 * multiplier)
          .scrollContentBackground(.hidden)
          
          // カテゴリーを追加ボタン
          addCategoryButton(multiplier: multiplier)
            .padding(.bottom, 30 * multiplier)
          
        }
        .frame(width: 320 * multiplier, height: 565 * multiplier)
        .background(Color.white)
        .cornerRadius(24 * multiplier)
        .shadow(color: Color(hex: "#ADB5BD")!.opacity(0.2), radius: 10, x: 0, y: 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      }
      .overlay {
        if viewModel.showingAddCategoryPopup {
          AddCategoryPopup(
            isPresented: $viewModel.showingAddCategoryPopup,
            multiplier: multiplier
          ) { newCategory in
            // closure for add category
            viewModel.addNewCategory(newCategory)
          }
        }
      }
    }
  }
}

extension CategoryPopup {
  func header(multiplier: CGFloat) -> some View {
    HStack {
      Spacer()
        .frame(width: 90 * multiplier)
      Text("カテゴリー")
        .font(.custom("IBM Plex Mono", size: 24 * multiplier))
        .foregroundColor(Color(hex: "#212529")!)
      Spacer()
      Button(action: {
        viewModel.dismiss()
      }) {
        Image(systemName: "xmark")
          .font(.system(size: 20 * multiplier))
          .foregroundColor(Color(hex: "#868E96")!)
      }
      .frame(width: 35 * multiplier, height: 31 * multiplier)
      Spacer()
        .frame(width: 15 * multiplier)
    }
    .frame(height: 30 * multiplier)
    .background(Color.clear)
  }
  
  func cell(multiplier: CGFloat, category: String) -> some View {
    HStack(spacing: 10 * multiplier) {
      Image(systemName: "tag.fill")
        .font(.system(size: 16 * multiplier))
        .foregroundColor(Color(hex: "#339AF0")!)
      
      Text(category)
        .font(.custom("IBM Plex Mono", size: 18 * multiplier))
        .fontWeight(.medium)
        .foregroundColor(Color(hex: "#495057")!)
      
      Spacer()
      
      Image(systemName: "chevron.right")
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
    .listRowInsets(EdgeInsets())
    .listRowSeparator(.hidden)
    .listRowBackground(Color.clear)
  }
  
  func addCategoryButton(multiplier: CGFloat) -> some View {
    Button(action: {
      viewModel.showAddCategoryPopup()
    }) {
      HStack(spacing: 10 * multiplier) {
        Image(systemName: "plus")
          .font(.system(size: 16 * multiplier))
        Text("カテゴリーを追加")
          .font(.custom("IBM Plex Mono", size: 18 * multiplier))
          .fontWeight(.medium)
      }
      .foregroundColor(.white)
      .frame(width: 220 * multiplier, height: 54 * multiplier)
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
}

// MARK: - ViewModel
class CategoryPopupViewModel: ObservableObject {
  @Published var categories: [String] = []
  @Published var showingAddCategoryPopup = false
  
  private let onCategorySelect: (String) -> Void
  private let onDismiss: () -> Void
  
  init(
    onCategorySelect: @escaping (String) -> Void,
    onDismiss: @escaping () -> Void
  ) {
    self.onCategorySelect = onCategorySelect
    self.onDismiss = onDismiss
    loadCategories()
  }
  
  func selectCategory(_ category: String) {
    onCategorySelect(category)
  }
  
  func dismiss() {
    onDismiss()
  }
  
  func addNewCategory(_ category: String) {
    categories.append(category)
    saveCategories()
    selectCategory(category)
  }
  
  @MainActor func removeCategory(_ category: String) {
    if let index = categories.firstIndex(of: category) {
      categories.remove(at: index)
      saveCategories()
    }
  }
  
  func showAddCategoryPopup() {
    showingAddCategoryPopup = true
  }
  
  func hideAddCategoryPopup() {
    showingAddCategoryPopup = false
  }
  
  private func loadCategories() {
    categories = UserDefaultManager.savedCategories
  }
  
  private func saveCategories() {
    UserDefaultManager.savedCategories = categories
  }
}

struct CategoryPopup_Previews: PreviewProvider {
  static var previews: some View {
    CategoryPopup(
      onCategorySelect: { _ in },
      onDismiss: {}
    )
  }
}

// AddCategoryPopupViewModel
class AddCategoryPopupViewModel: ObservableObject {
  @Published var categoryName = ""
  var isPresented: Binding<Bool>
  let multiplier: CGFloat
  let onAdd: (String) -> Void
  
  init(isPresented: Binding<Bool>, multiplier: CGFloat, onAdd: @escaping (String) -> Void) {
    self.isPresented = isPresented
    self.multiplier = multiplier
    self.onAdd = onAdd
  }
  
  func dismiss() {
    isPresented.wrappedValue = false
  }
  
  func addCategory() {
    if !categoryName.isEmpty {
      onAdd(categoryName)
      dismiss()
    }
  }
}


