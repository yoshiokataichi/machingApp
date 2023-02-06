import UIKit
import FirebaseAuth
import FirebaseFirestore
import PKHUD
import RxCocoa
import RxSwift

class HomeController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private var isCardAnimating = false
    
    private var user: User?
    //自分以外のユーザー情報
    private var users = [User]()
    
    let topControllerView = TopControllerView()
    let cardView = UIView()
    let bottomControllerView = BottomControllerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.fetchUserFromFirestore(uid: uid) { (user) in
            if let user = user {
                self.user = user
            }
        }
        fetchUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser?.uid == nil {
            let registerController = RegisterViewController()
            let nav = UINavigationController(rootViewController: registerController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
    
    //MARK: Methods
    private func fetchUsers() {
        HUD.show(.progress)
        self.users = []
        Firestore.fetchUsersFromFirestore { users in
            HUD.hide()
            self.users = users
            self.users.forEach { user in
                let card = CardView(user: user)
                self.cardView.addSubview(card)
                card.anchor(top: self.cardView.topAnchor, bottom: self.cardView.bottomAnchor, left: self.cardView.leftAnchor, right: self.cardView.rightAnchor)
            }
        }
        print("ユーザー情報の取得に成功")
    }
    
    private func setupLayout() {
        
        
        let stackView = UIStackView(arrangedSubviews: [topControllerView, cardView, bottomControllerView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        
        self.view.addSubview(stackView)
        [
            topControllerView.heightAnchor.constraint(equalToConstant: 100),
            bottomControllerView.heightAnchor.constraint(equalToConstant: 120),
            
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ].forEach { $0.isActive = true }
    }
    
    private func setupBindings() {
        topControllerView.profileButton.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                let profile = ProfileViewController()
                profile.user = self?.user
                profile.presentationController?.delegate = self
                self?.present(profile, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        bottomControllerView.reloadView.button?.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                self?.fetchUsers()
            }
            .disposed(by: disposeBag)
        
        bottomControllerView.nopeView.button?.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                guard let self = self else { return }
                if !self.isCardAnimating {
                    self.isCardAnimating = true
                    self.cardView.subviews.last?.removeCardViewAnimaiton(x: -600, completion: {
                        self.isCardAnimating = false
                    })
                }
            }
            .disposed(by: disposeBag)
        bottomControllerView.likeView.button?.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                guard let self = self else { return }
                if !self.isCardAnimating {
                    self.isCardAnimating = true
                    self.cardView.subviews.last?.removeCardViewAnimaiton(x: 600, completion: {
                        self.isCardAnimating = false
                    })
                }
            }
            .disposed(by: disposeBag)
    }
}

extension HomeController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if Auth.auth().currentUser == nil {
            self.user = nil
            self.users = []
            let registerController = RegisterViewController()
            let nav = UINavigationController(rootViewController: registerController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
}
