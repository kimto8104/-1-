//
//  KeyboardResponder.swift
//  FaceDownFocusTimer
//
//  Created by iosDevelopers on 2025/09/21.
//

import Foundation
import SwiftUI
import Combine

final class KeyboardResponder: ObservableObject {
    @Published var currentheight: CGFloat = 0
    // キーボードが表示される直前に送られる通知をCombine の Publisher として受け取れるようにしている
    // NotificationCenter.defaultシステム全体の通知を配信する通知センター
    // UIResponder.keyboardWillShowNotification キーボードが表示される直前に投稿される通知の名前
    // publisher(for) 指定した通知をCombineのPublisherに変換している。これにより通知を受け取るたびにイベントが流れる
    
    // keyboardWillShowNotification は NotificationCenter.Publisher 型（Notification を発行する Publisher）になり、sink や assign などで購読すると、キーボード表示前のタイミングで呼ばれて、通知の userInfo からキーボードのフレームやアニメーション時間などを取り出して UI を更新する、といった処理ができます。
    var keyboardWillShowNotification = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
    var keyboardWillHideNotification = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
    private var cancellableSet: Set<AnyCancellable> = []
    
    init() {
        keyboardWillShowNotification.map { notification in
            CGFloat((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0 )
        }
        // currentHeight へUIResponder.keyboardFrameEndUserInfoKeyを流している
        .assign(to: \.currentheight, on: self)
        // 通知を受け取って currentheight を更新する」というストリームを作っても、保持しなければ一瞬で消えてしまう。
        // Set<AnyCancellable> に入れておくことで、そのストリームが生き続け、通知が来るたびに currentheight が更新される。
        .store(in: &cancellableSet)
        
        keyboardWillHideNotification.map { notification in
            CGFloat(0)
        }
        .assign(to: \.currentheight, on: self)
        .store(in: &cancellableSet)
    }
}
