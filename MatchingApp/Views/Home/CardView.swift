import UIKit
import SDWebImage

class CardView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    private let cardImageView = CardImageView(frame: .zero)
    private let infoButton = UIButton(type: .system).createCardInfoButton()
    private let nameLabel = CardInfoLabel(font: .systemFont(ofSize: 40, weight: .heavy))
    private let residenceLabel = CardInfoLabel(font: .systemFont(ofSize: 20, weight: .regular))
    private let hobbyLabel = CardInfoLabel(font: .systemFont(ofSize: 25, weight: .regular))
    private let introductionLabel = CardInfoLabel(font: .systemFont(ofSize: 25, weight: .regular))
    private let goodLabel = CardInfoLabel(text: "GOOD", textColor: UIColor.rgb(red: 137, green: 223, blue: 86))
    private let nopeLabel = CardInfoLabel(text: "NOPE", textColor: UIColor.rgb(red: 222, green: 110, blue: 110))
//    private let nopeLabel = CardInfoLabel(text: "NOPE", textColor: UIColor.rgb(red: 222, green: 110, blue: 110))
    
    init(user: User) {
         super.init(frame: .zero)
        setupLayout(user: user)
        setupGradientLayer()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panCardView))
        self.addGestureRecognizer(panGesture)
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = self.bounds
    }
    
    @objc private func panCardView(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        guard let view = gesture.view else { return }
        
        if gesture.state == .changed {
            self.hundlePanChange(translation: translation)
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.3) {
                self.handlePanEnded(view: view, translation: translation)
            }
        }
    }
    
    private func setupGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.3, 1.1]
        cardImageView.layer.addSublayer(gradientLayer)
        
    }
    
    
    
    private func hundlePanChange(translation: CGPoint) {
        let degree: CGFloat = translation.x / 20
        let angle = degree * .pi / 100
        
        let rotateTranslation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotateTranslation.translatedBy(x: translation.x, y: translation.y)
        
        let ratio: CGFloat = 1 / 100
        let ratioValue = ratio * translation.x
        
        if translation.x > 0 {
            self.goodLabel.alpha = ratioValue
        } else if translation.x < 0 {
            self.nopeLabel.alpha = -ratioValue
        }
    }
    
    private func handlePanEnded(view: UIView, translation: CGPoint) {
        if translation.x <= -120 {
            view.removeCardViewAnimaiton(x: -600)
        } else if translation.x >= 120 {
            view.removeCardViewAnimaiton(x: 600)
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.7, options: []) {
                self.transform = .identity
                self.layoutIfNeeded()
                self.goodLabel.alpha = 0
                self.nopeLabel.alpha = 0
        }
    }
}
    
    private func setupLayout(user: User) {
        let infoVerticalStackView = UIStackView(arrangedSubviews: [residenceLabel, hobbyLabel, introductionLabel])
        infoVerticalStackView.axis = .vertical
        
        let baseStackView = UIStackView(arrangedSubviews: [infoVerticalStackView, infoButton])
        baseStackView.axis = .horizontal
    
        //VIew??????????????????
        addSubview(cardImageView)
        addSubview(nameLabel)
        addSubview(baseStackView)
        addSubview(goodLabel)
        addSubview(nopeLabel)
        cardImageView.anchor(top: topAnchor, bottom: bottomAnchor, left: leftAnchor, right: rightAnchor, leftPadding: 10, rightPadding: 10)
        infoButton.anchor(width: 40)
        baseStackView.anchor(bottom: cardImageView.bottomAnchor, left: cardImageView.leftAnchor, right: cardImageView.rightAnchor, bottomPadding: 20, leftPadding: 20, rightPadding: 20 )
        nameLabel.anchor(bottom: baseStackView.topAnchor, left: cardImageView.leftAnchor, bottomPadding: 10, leftPadding: 20)
        goodLabel.anchor(top: cardImageView.topAnchor, left: cardImageView.leftAnchor, width: 140, height: 55, topPadding: 25, leftPadding: 20)
        nopeLabel.anchor(top: cardImageView.topAnchor, right: cardImageView.rightAnchor, width: 140, height: 55, topPadding: 25, rightPadding: 20)
        
        //?????????????????????View?????????
        nameLabel.text = user.name
        introductionLabel.text = user.introduction
        hobbyLabel.text = user.hobby
        residenceLabel.text = user.residence
        
        if let url = URL(string: user.profileImageUrl) {
            cardImageView.sd_setImage(with: url)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
