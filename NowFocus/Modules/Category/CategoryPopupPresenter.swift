//
//  CategoryPopupPresenter.swift
//  FaceDown Focus Timer
//
//  Created by Tomofumi Kimura on 2025/02/02.
//

protocol CategoryPopupPresenterProtocol {
  func viewDidLoad()
  func didTapAddCategory(name: String)
}

class CategoryPopupPresenter: CategoryPopupPresenterProtocol {
  private(set) lazy var view = CategoryPopup().delegate(self)
  var interactor: CategoryPopupInteractorProtocol?
  var router: CategoryPopupRouterProtocol?
  
  func viewDidLoad() {
//    let categories = interactor.fetchCategories()
//    view.updateCategoryList(categories: categories)
  }
  
  func didTapAddCategory(name: String) {
//    interactor.addCategory(name: name)
//    let updatedCategories = interactor.fetchCategories()
//    view.updateCategoryList(categories: updatedCategories)
  }
}

extension CategoryPopupPresenter: CategoryPopupDelegate {
  func updateCategoryList(categories: [String]) {
    
  }
}
