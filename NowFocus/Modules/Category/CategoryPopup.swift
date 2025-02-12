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
  @ObservedObject var model = CategoryPopupViewModel()
  var body: some View {
    GeometryReader { gp in
      let hm = gp.size.width / 375
      let vm = gp.size.height / 667
      let multiplier = abs(hm - 1) < abs(vm - 1) ? hm : vm
      ZStack {
        VStack {
          Spacer()
            .frame(height: 26 * multiplier)
          // ヘッダー部分
          header(multiplier: multiplier)
          
          // リスト部分
          List {
            ForEach(model.categories, id: \.self) { category in
              cell(multiplier: multiplier, category: category)
                .onTapGesture {
                  model.delegate?.didSelectCategory(name: category)
                }
            }
            .onDelete { indexSet in
              indexSet.forEach { index in
                let category = model.categories[index]
                model.removeCategory(category)
              }
            }
          }
          .listStyle(PlainListStyle())
          .frame(height: 400 * multiplier)
          .scrollContentBackground(.hidden)
          
          // カテゴリーを追加ボタン
          addCategoryButton(multiplier: multiplier)
          
        }
        .frame(width: 320 * multiplier, height: 565 * multiplier)
        .background(Color(hex: "FFFAFA"))
        .cornerRadius(20 * multiplier)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      }
      .shadow(color: .black.opacity(0.25), radius: 4, x: 4, y: 4)
      .overlay {
        if model.showingAddCategoryPopup {
          AddCategoryPopup(
            isPresented: $model.showingAddCategoryPopup,
            multiplier: multiplier
          ) { newCategory in
            model.delegate?.addCategory(name: newCategory)
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
      Spacer()
      Button(action: {
        model.closePopup()
      }) {
        Image("Category_CloseButton")
          .resizable()
          .foregroundStyle(Color(hex: "D9D9D9")!)
      }
      .frame(width: 35 * multiplier, height: 31 * multiplier)
      Spacer()
        .frame(width: 15 * multiplier)
    }
    .frame(height: 30 * multiplier)
    .background(Color.clear)
  }
  
  func cell(multiplier: CGFloat, category: String) -> some View {
    HStack {
      Spacer()
        .frame(width: 32 * multiplier)
      
      Text(category)
        .font(.custom("IBM Plex Mono", size: 14 * multiplier))
      
      Spacer()
      
      Button(action: {
        model.delegate?.didSelectCategory(name: category)
      }) {
        Text("")
          .frame(width: 68 * multiplier, height: 28 * multiplier)
//          .foregroundColor(.black)
//          .padding(.horizontal, 2 * multiplier)
//          .padding(.vertical, 2 * multiplier)
//          .background(Color.gray.opacity(0.2))
//          .cornerRadius(20 * multiplier)
      }
      
      Spacer()
        .frame(width: 16 * multiplier)
    }
    .frame(height: 56 * multiplier)
    .listRowInsets(EdgeInsets())
    .listRowSeparator(.hidden)
    .listRowBackground(Color.clear)
  }
  
  func addCategoryButton(multiplier: CGFloat) -> some View {
    Button(action: {
      model.showAddCategoryPopup()
    }) {
      Text("カテゴリーを追加")
        .font(.custom("IBM Plex Mono", size: 16 * multiplier))
        .frame(width: 246 * multiplier)
        .frame(height: 46 * multiplier)
        .background(Color(hex: "4C4545"))
        .foregroundColor(.white)
        .cornerRadius(20 * multiplier)
    }
  }
}

// MARK: Modifier
extension CategoryPopup {
  func delegate(_ value: CategoryPopupDelegate) -> Self {
    model.delegate = value
    return self
  }
}

// ViewModel for CategoryPopup
class CategoryPopupViewModel: ObservableObject {
  weak var delegate: CategoryPopupDelegate?
  @Published var categories: [String] = []
  @Published var showingAddCategoryPopup = false
  
  init() {
    self.loadCategories()
  }
  
  @MainActor func removeCategory(_ category: String) {
    // SwiftDataの更新
    delegate?.removeCategoryFromHistory(category: category)
    if let index = categories.firstIndex(of: category) {
      categories.remove(at: index)
      saveCategories()
    }
  }
  
  func showAddCategoryPopup() {
    delegate?.showAddCategoryPopup()
  }
  
  func hideAddCategoryPopup() {
    delegate?.hideAddCategoryPopup()
  }
  
  // Add new category
  func addCategory(newCategory: String = "新しいカテゴリー") {
    categories.append(newCategory)
    saveCategories()
  }
  
  private func loadCategories() {
    categories = UserDefaultManager.savedCategories
  }
  
  private func saveCategories() {
    UserDefaultManager.savedCategories = categories
  }
  
  func closePopup() {
    delegate?.closePopup()
  }
}

struct CategoryPopup_Previews: PreviewProvider {
  static var previews: some View {
    CategoryPopup()
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


