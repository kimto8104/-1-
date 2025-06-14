//
//  CelebrationPopupView.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/06/13.
//

import SwiftUI

struct CelebrationPopupView: View {
  let consecutiveDays: Int
  @Binding var isPresented: Bool
  
  // アニメーション用の状態変数
  @State private var displayedNumber: Int = 0
  @State private var isAnimating = false
  @State private var isNumberScaling = false
  
  var body: some View {
    ZStack {
      // 背景のオーバーレイ
      Color.black.opacity(0.4)
        .edgesIgnoringSafeArea(.all)
        .opacity(isAnimating ? 1 : 0)
        .onTapGesture {
          withAnimation(.spring()) {
            isPresented = false
          }
        }
      
      // ポップアップのメインコンテンツ
      VStack(spacing: 28) {
        // 連続日数の強調表示
        ZStack {
          Circle()
            .fill(Color.blue.opacity(0.1))
            .frame(width: 160, height: 160)
            .scaleEffect(isAnimating ? 1 : 0.8)
          
          VStack(spacing: 4) {
            Text("\(displayedNumber)")
              .font(.system(size: isNumberScaling ? 72 : 64, weight: .bold, design: .rounded))
              .foregroundColor(.blue)
              .contentTransition(.numericText())
              .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isNumberScaling)
            
            Text("日")
              .font(.title2)
              .foregroundColor(.blue)
              .opacity(isAnimating ? 1 : 0)
              .offset(y: isAnimating ? 0 : 10)
          }
        }
        .rotation3DEffect(
          .degrees(isAnimating ? 360 : 0),
          axis: (x: 0, y: 1, z: 0)
        )
        
        // メッセージ
        VStack(spacing: 12) {
          Text("おめでとうございます！")
            .font(.title2)
            .fontWeight(.bold)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
          
          Text("1分から始まる")
            .font(.title3)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
        }
        
        // 閉じるボタン
        Button(action: {
          withAnimation(.spring()) {
            isPresented = false
          }
        }) {
          Text("閉じる")
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 200, height: 44)
            .background(Color.blue)
            .cornerRadius(22)
        }
        .opacity(isAnimating ? 1 : 0)
        .scaleEffect(isAnimating ? 1 : 0.8)
      }
      .padding(32)
      .background(
        RoundedRectangle(cornerRadius: 24)
          .fill(Color(UIColor.systemBackground))
          .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
      )
      .padding(.horizontal, 40)
      .scaleEffect(isAnimating ? 1 : 0.8)
    }
    .onAppear {
      // アニメーションの開始
      withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
        isAnimating = true
      }
      
      // 数字のカウントアップアニメーション
      for i in 0...consecutiveDays {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
          withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            displayedNumber = i
          }
        }
      }
      
      // カウントアップアニメーション後に数字を拡大
      DispatchQueue.main.asyncAfter(deadline: .now() + Double(consecutiveDays) * 0.05 + 0.3) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
          isNumberScaling = true
        }
      }
    }
  }
}

#Preview {
  CelebrationPopupView(consecutiveDays: 7, isPresented: .constant(true))
}
