import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        guard hexSanitized.count == 6 else {
            self.init(white: 0.0, alpha: alpha) // Возвращает черный, если формат неверный
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgbValue & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static var invertedLabel: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? .black
                : .white
        }
    }
    
    static var customBackGround2: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 65, green: 65, blue: 65, alpha: 0.85)
            : UIColor(red: 230, green: 232, blue: 235, alpha: 0.3)
        }
    }
}
