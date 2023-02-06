import UIKit
import RxCocoa
import RxSwift

class TopControllerView: UIView {
    
    private let disposeBag = DisposeBag()
    
    let tinderButton: UIButton = createTopButton(imageName: "tinder-selected", unselectedImage: "tinder-unselected")
    let goodbutton: UIButton = createTopButton(imageName: "good-selected", unselectedImage: "good-unselected")
    let commentButton: UIButton = createTopButton(imageName: "comment-selected", unselectedImage: "comment-unselected")
    let profileButton: UIButton = createTopButton(imageName: "profile-selected", unselectedImage: "profile-unselected")
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupLayout()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func createTopButton(imageName: String, unselectedImage: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: imageName), for: .selected)
        button.setImage(UIImage(named: unselectedImage), for: .normal)
        return button
    }

    private func setupLayout() {
        let baseStackView = UIStackView(arrangedSubviews: [tinderButton, goodbutton, commentButton, profileButton])
        baseStackView.axis = .horizontal
        baseStackView.distribution = .fillEqually
        baseStackView.spacing = 43
        baseStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(baseStackView)

        baseStackView.anchor(top: topAnchor, bottom: bottomAnchor, left: leftAnchor, right: rightAnchor, leftPadding: 40, rightPadding: 40)
        tinderButton.isSelected = true
    }
    
    private func setupBindings() {
        tinderButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.handleSelectedButton(selectedButton: self.tinderButton)
            })
        .disposed(by: disposeBag)
        goodbutton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.handleSelectedButton(selectedButton: self.goodbutton)
            })
        .disposed(by: disposeBag)
        commentButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.handleSelectedButton(selectedButton: self.commentButton)
            })
        .disposed(by: disposeBag)
        profileButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.handleSelectedButton(selectedButton: self.profileButton)
            })
        .disposed(by: disposeBag)
    }
 
    private func handleSelectedButton(selectedButton: UIButton) {
        let buttons = [tinderButton, goodbutton, commentButton, profileButton]
        
        buttons.forEach { button in
            if button == selectedButton {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
    }
}
