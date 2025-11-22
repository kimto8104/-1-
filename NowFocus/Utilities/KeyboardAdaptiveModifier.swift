//
//  KeyboardAdaptiveModifier.swift
//  FaceDownFocusTimer
//
//  Created by iosDevelopers on 2025/09/22.
//

import SwiftUI

/// キーボード表示/非表示に応じて、ビュー全体を上に持ち上げる Modifier
/// - currentheight に応じて下方向の offset を負値で与える（= 見た目は上に移動）
/// - ホームインジケータ分（safe area の bottom）を差し引くかどうかを選べます。
struct KeyboardAdaptiveModifier: ViewModifier {
  @StateObject private var keyboardResponder = KeyboardResponder()
  
  /// ホームインジケータ分を差し引く（true 推奨）
  var subtractSafeAreaBottom: Bool = true
  /// キーボード高さに掛ける係数（0.0〜1.0 目安）
  var factor: CGFloat = 0.7
  /// 上げる量の上限（安全のためにクランプ）
  var maxLift: CGFloat = 260
  /// 微調整のための固定オフセット（正: さらに上げる / 負: 抑える）
  var extraOffset: CGFloat = 0
  /// アニメーション
  var animation: Animation = .easeOut(duration: 0.25)
  
  func body(content: Content) -> some View {
    GeometryReader { proxy in
      let safeBottom = proxy.safeAreaInsets.bottom
      // ベースのキーボード高さ（必要ならホームインジケータ分を差し引く）
      let base = max(0, keyboardResponder.currentheight - (subtractSafeAreaBottom ? safeBottom : 0))
      // 係数で減衰 + 微調整
      let proposed = base * max(0, factor) + extraOffset
      // 上限クランプ（負にならないように）
      let lift = min(max(0, proposed), maxLift)
      
      content
        .offset(y: -lift)
        .animation(animation, value: keyboardResponder.currentheight)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
  }
}

extension View {
  /// キーボードの出入りに応じてビュー全体を上に持ち上げる
  /// - Parameters:
  ///   - subtractSafeAreaBottom: ホームインジケータ分を差し引くか（true 推奨）
  ///   - factor: キーボード高さに掛ける係数（例: 0.6 なら60%だけ持ち上げ）
  ///   - maxLift: 上げ量の上限
  ///   - extraOffset: 微調整の固定値（負で抑える）
  ///   - animation: アニメーション
  func keyboardAdaptiveOffset(
    subtractSafeAreaBottom: Bool = true,
    factor: CGFloat = 0.7,
    maxLift: CGFloat = 260,
    extraOffset: CGFloat = 0,
    animation: Animation = .easeOut(duration: 0.25)
  ) -> some View {
    modifier(
      KeyboardAdaptiveModifier(
        subtractSafeAreaBottom: subtractSafeAreaBottom,
        factor: factor,
        maxLift: maxLift,
        extraOffset: extraOffset,
        animation: animation
      )
    )
  }
}
