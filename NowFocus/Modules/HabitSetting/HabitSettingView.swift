//
//  HabitSettingView.swift
//  FaceDownFocusTimer
//
//  Created by Tomofumi Kimura on 2025/08/17.
//

import SwiftUI
import Combine
import Observation

@Observable
class HabitSettingViewModel {
    var inputText: String = "" {
        didSet {
            isButtonEnabled = !inputText.isEmpty
        }
    }
    var isButtonEnabled: Bool = false
}

struct HabitSettingView: View {
    @State private var viewModel = HabitSettingViewModel()

    var body: some View {
    
    GeometryReader { gp in
      let hm = gp.size.width / 375
      let vm = gp.size.height / 667
      let multiplier = abs(hm - 1) < abs(vm - 1) ? hm : vm
      
      ZStack {
        VStack {
          Text("1分")
            .font(.system(size: 48 * multiplier))
            .fontWeight(.bold)
            .frame(width: 154 * multiplier, height: 100 * multiplier)
          
          Text("ならできるはず")
            .font(.title3)
            .fontWeight(.medium)
            .frame(width: 165 * multiplier, height: 20 * multiplier)
          Spacer()
            .frame(height: 20 * multiplier)
          
          TextField("1分ならできる習慣を入力", text: $viewModel.inputText)
            .padding(.horizontal)
            .font(.system(size: 18 * multiplier))
            .background(Color(hex: "#F7F5F5"))
            .frame(width: 310 * multiplier, height: 60 * multiplier)
            .clipShape(Capsule())
            .submitLabel(.done)
          
          Spacer()
            .frame(height: 40 * multiplier)
          
          Button {
            // 挑戦するAction here
          } label: {
            Text("挑戦する")
              .foregroundStyle(.white)
              .font(.title3)
              .fontWeight(.medium)
          }
          .frame(width: 174 * multiplier, height: 56 * multiplier)
          .background(viewModel.isButtonEnabled ? Color(hex: "#F65050") : Color.gray.opacity(0.5))
          .cornerRadius(40 * multiplier)
          .disabled(!viewModel.isButtonEnabled)
        }
        .frame(width: gp.size.width, height: gp.size.height)
      }
    }
  }
}

#Preview {
  HabitSettingView()
}
