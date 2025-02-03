//
//  CategoryPopup.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/02/01.
//

import SwiftUI

protocol CategoryPopupDelegate: AnyObject {
  func updateCategoryList(categories: [String])
}

struct CategoryPopup: View {
  @Environment(\.presentationMode) var presentationMode
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
          List(model.categories, id: \.self) { category in
            cell(multiplier: multiplier, category: category)
          }
          .listStyle(PlainListStyle())
          .frame(height: 400 * multiplier)
          
          // カテゴリーを追加ボタン
          addCategoryButton(multiplier: multiplier)
          
        }
        .frame(width: 320 * multiplier, height: 565 * multiplier)
        .background(Color(hex: "FFFAFA"))
        .cornerRadius(20 * multiplier)
        // ここで中央に配置
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      }
      .shadow(color: .black.opacity(0.25), radius: 4, x: 4, y: 4)
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
        presentationMode.wrappedValue.dismiss()
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
    .background(Color(hex: "FFFAFA"))
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
          .foregroundColor(.black) // ボタンの色を変更
          .padding(.horizontal, 2 * multiplier)
          .padding(.vertical, 2 * multiplier)
          .background(Color.gray.opacity(0.2)) // ボタンの背景色を設定
          .cornerRadius(20 * multiplier)
      }
      
      Spacer()
        .frame(width: 16 * multiplier)
      
    }
    .frame(height: 56 * multiplier)
    .listRowInsets(EdgeInsets()) // デフォルトの余白を消す
    .listRowSeparator(.hidden)
  }
  
  func addCategoryButton(multiplier: CGFloat) -> some View {
    // ボトムボタン
    Button(action: {
      model.categories.append("新しいカテゴリー")
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
  fileprivate var delegate: CategoryPopupDelegate?
  @Published var categories: [String] = ["仕事", "勉強", "運動", "読書"]
  
  // Add new category
  func addCategory(_ newCategory: String = "新しいカテゴリー") {
    categories.append(newCategory)
  }
}

struct CategoryPopupView_Previews: PreviewProvider {
  static var previews: some View {
    CategoryPopup()
  }
}

