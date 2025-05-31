////
////  CategoryPopupPresenter.swift
////  FaceDown Focus Timer
////
////  Created by Tomofumi Kimura on 2025/02/02.
////
//
//protocol CategoryPopupPresenterDelegate {
//  func viewDidLoad()
//  func didTapAddCategory(name: String)
//  func showAddCategoryPopup()
//  func didSelectCategory(_ category: String)
//}
//
//class CategoryPopupPresenter: CategoryPopupPresenterDelegate {
//  
//  private(set) lazy var view = CategoryPopup().delegate(self)
//  var interactor: CategoryPopupInteractorProtocol?
//  var router: CategoryPopupRouterProtocol?
//  var timerPresenter: (any TimerPresenterProtocol)?
//  func viewDidLoad() {
////    let categories = interactor.fetchCategories()
////    view.updateCategoryList(categories: categories)
//  }
//  
//  func didTapAddCategory(name: String) {
//    view.model.addCategory(newCategory: name)
//    view.model.showingAddCategoryPopup = false
//    timerPresenter?.updateSelectedCategory(name)
//  }
//  
//  func didSelectCategory(_ category: String) {
//    timerPresenter?.updateSelectedCategory(category)
//  }
//}
//
//extension CategoryPopupPresenter: CategoryPopupDelegate {
//  
//  @MainActor func removeCategoryFromHistory(category: String) {
//    interactor?.removeCategoryFromHistory(category: category)
//    timerPresenter?.removeSelectedCategoryByCategoryPopup(category)
//    
//  }
//  
//  func didSelectCategory(name: String) {
//    didSelectCategory(name)
//  }
//  
//  func addCategory(name: String) {
//    didTapAddCategory(name: name)
//  }
//  
//  func closePopup() {
//    router?.dismissCategoryPopup()
//  }
//  
//  func updateCategoryList(categories: [String]) {
//    
//  }
//  
//  func showAddCategoryPopup() {
//    view.model.showingAddCategoryPopup = true
//  }
//  
//  func hideAddCategoryPopup() {
//    view.model.showingAddCategoryPopup = false
//  }
//}
