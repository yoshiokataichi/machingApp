import UIKit

class CardInfoLabel: UILabel {
    //nopeとGoodのラベル
     init(text: String, textColor: UIColor) {
         super.init(frame: .zero)
        font = .boldSystemFont(ofSize: 45)
        self.text = text
        layer.borderWidth = 3
        layer.borderColor = textColor.cgColor
        layer.cornerRadius = 10
        self.textColor = textColor
        textAlignment = .center
        alpha = 0
    }
    
    //その他のtestColorが白のラベル
    init(font: UIFont) {
        super.init(frame: .zero)
        self.font = font
         textColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
