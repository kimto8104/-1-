//
//  AddCategoryPopup.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/02/09.
//

import SwiftUI

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
            .frame(width: 40 * model.multiplier)
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


#Preview {
  @Previewable @State var isPresented = true
  AddCategoryPopup(
    isPresented: $isPresented,
    multiplier: 1
  ) { newCategory in
    print("added Category")
  }
}
