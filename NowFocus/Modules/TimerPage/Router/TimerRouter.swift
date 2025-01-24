//
//  TimerRouter.swift
//  NowFocus
//
//  Created by Tomofumi Kimura on 2024/07/21.
//

import SwiftUI

// MARK: Protocol
protocol TimerRouterProtocol {
  static func initializeTimerModule(with time: Int) -> TimerPage
}

class TimerRouter: TimerRouterProtocol {
  static func initializeTimerModule(with time: Int) -> TimerPage {
    print("initializeTimerModule呼ばれています")
    let router = TimerRouter()
    let motionManagerService = MotionManagerService()
    let presenter = TimerPresenter()
    let interactor = TimerInteractor.shared
    interactor.presenter = presenter
    presenter.interactor = interactor
    presenter.router = router
    return presenter.view
  }
}
