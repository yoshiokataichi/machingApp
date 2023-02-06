import UIKit

class CardImageView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
        layer.cornerRadius = 10
        contentMode = .scaleAspectFill
//        image = UIImage(named: "ikeda")
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
