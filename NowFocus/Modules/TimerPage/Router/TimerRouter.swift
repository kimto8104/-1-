//
//  TimerRouter.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2024/07/21.
//

import SwiftUI

// MARK: Protocol
protocol TimerRouterProtocol {
  static func initializeTimerModule(with time: Int, isTimerPageActive: Binding<Bool>) -> TimerPage<TimerPresenter>
}

class TimerRouter: TimerRouterProtocol {
  static func initializeTimerModule(with time: Int, isTimerPageActive: Binding<Bool>) -> TimerPage<TimerPresenter> {
    print("initializeTimerModule呼ばれています")
    let router = TimerRouter()
    let presenter = TimerPresenter(time: time)
    
    let interactor = TimerInteractor.shared
    interactor.presenter = presenter
    presenter.interactor = interactor
    presenter.router = router
    
    let view = TimerPage(presenter: presenter, isTimerPageActive: isTimerPageActive)
    print("新たにTimerPageViewとpresenterが生成されました：presenterID:\(presenter.id), TimerPageView ID: \(view.id)")
    return view
  }
}
