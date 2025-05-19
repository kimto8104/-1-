import SwiftUI
import Combine

protocol CategoryServiceProtocol {
    var selectedCategoryPublisher: AnyPublisher<String?, Never> { get }
    var isCategoryPopupPresentedPublisher: AnyPublisher<Bool, Never> { get }
    var categoryPopup: CategoryPopup? { get }
    
    func showCategoryPopup()
    func hideCategoryPopup()
    func updateSelectedCategory(_ category: String?)
    func removeSelectedCategory()
}

class CategoryService: CategoryServiceProtocol {
    // MARK: - Published Properties
    @Published private(set) var selectedCategory: String?
    @Published private(set) var isCategoryPopupPresented = false
    @Published private(set) var categoryPopup: CategoryPopup?
    
    // MARK: - Publishers
    var selectedCategoryPublisher: AnyPublisher<String?, Never> {
        $selectedCategory.eraseToAnyPublisher()
    }
    
    var isCategoryPopupPresentedPublisher: AnyPublisher<Bool, Never> {
        $isCategoryPopupPresented.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    func showCategoryPopup() {
        let presenter = CategoryPopupPresenter()
        let view = presenter.view
        let router = CategoryPopupRouter(view: view, parentView: nil)
        let interactor = CategoryPopupInteractor()
        
        interactor.presenter = presenter
        presenter.interactor = interactor
        presenter.router = router
        
        self.categoryPopup = presenter.view
        
        withAnimation(.easeInOut(duration: 0.2)) {
            self.isCategoryPopupPresented = true
        }
    }
    
    func hideCategoryPopup() {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.isCategoryPopupPresented = false
        }
    }
    
    func updateSelectedCategory(_ category: String?) {
        self.selectedCategory = category
        hideCategoryPopup()
    }
    
    func removeSelectedCategory() {
        self.selectedCategory = nil
    }
} 