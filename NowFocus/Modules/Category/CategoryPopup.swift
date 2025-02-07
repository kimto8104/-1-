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
  func addCategory(name: String)
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
//    .background(Color(hex: "FFFAFA"))
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
        print("\(category) を編集") // 編集処理をここに記述
      }) {
        Text("編集")
          .frame(width: 68 * multiplier, height: 28 * multiplier)
          .foregroundColor(.black)
          .padding(.horizontal, 2 * multiplier)
          .padding(.vertical, 2 * multiplier)
          .background(Color.gray.opacity(0.2))
          .cornerRadius(20 * multiplier)
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
  
  func removeCategory(_ category: String) {
    if let index = categories.firstIndex(of: category) {
      categories.remove(at: index)
      saveCategories()
    }
  }
  
  func showAddCategoryPopup() {
    delegate?.showAddCategoryPopup()
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
  @Published var isPresented: Bool
  let multiplier: CGFloat
  let onAdd: (String) -> Void
  
  init(isPresented: Binding<Bool>, multiplier: CGFloat, onAdd: @escaping (String) -> Void) {
    self._isPresented = Published(wrappedValue: isPresented.wrappedValue)
    self.multiplier = multiplier
    self.onAdd = onAdd
  }
  
  func dismiss() {
    isPresented = false
  }
  
  func addCategory() {
    if !categoryName.isEmpty {
      onAdd(categoryName)
      dismiss()
    }
  }
}

// AddCategoryPopupの修正
struct AddCategoryPopup: View {
  @StateObject private var model: AddCategoryPopupViewModel
  
  init(isPresented: Binding<Bool>, multiplier: CGFloat, onAdd: @escaping (String) -> Void) {
    _model = StateObject(wrappedValue: AddCategoryPopupViewModel(isPresented: isPresented, multiplier: multiplier, onAdd: onAdd))
  }
  
  var body: some View {
    ZStack {
      Color.black.opacity(0.3)
        .ignoresSafeArea()
        .onTapGesture {
          model.dismiss()
        }
      
      VStack(spacing: 20 * model.multiplier) {
        // ヘッダー
        HStack {
          Spacer()
            .frame(width: 90 * model.multiplier)
          
          Text("カテゴリーを追加")
            .font(.custom("IBM Plex Mono", size: 20 * model.multiplier))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
          
          Spacer()
          
          Button(action: {
            model.dismiss()
          }) {
            Image("Category_CloseButton")
              .resizable()
              .foregroundStyle(Color(hex: "D9D9D9")!)
              .frame(width: 35 * model.multiplier, height: 31 * model.multiplier)
          }
          
          Spacer()
            .frame(width: 15 * model.multiplier)
        }
        .padding(.horizontal, 15 * model.multiplier)
        
        // テキストフィールド
        TextField("カテゴリー名", text: $model.categoryName)
          .font(.custom("IBM Plex Mono", size: 16 * model.multiplier))
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding(.horizontal, 20 * model.multiplier)
          .submitLabel(.done)
          .onSubmit {
            model.addCategory()
          }
        
        // 追加ボタン
        Button(action: {
          model.addCategory()
        }) {
          Text("追加")
            .font(.custom("IBM Plex Mono", size: 16 * model.multiplier))
            .frame(width: 200 * model.multiplier, height: 46 * model.multiplier)
            .background(model.categoryName.isEmpty ? Color(hex: "D9D9D9") : Color(hex: "4C4545"))
            .foregroundColor(.white)
            .cornerRadius(20 * model.multiplier)
        }
        .disabled(model.categoryName.isEmpty)
        .padding(.top, 20 * model.multiplier)
      }
      .frame(width: 280 * model.multiplier, height: 200 * model.multiplier)
      .background(Color(hex: "FFFAFA"))
      .cornerRadius(20 * model.multiplier)
    }
  }
}

