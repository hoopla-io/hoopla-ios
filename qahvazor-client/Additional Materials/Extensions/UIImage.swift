//
//  UIImage.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit

extension UIImage {
    static func imageWithColor(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIImage {
    static func appImage(_ name: AssetsImage) -> UIImage {
        return UIImage(named: name.rawValue) ?? UIImage()
    }
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIImage {
    static func imageWith(initials: String) -> UIImage {
        let size = 22.0
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        
        // Draw an opague circle
        UIColor.white.setFill()
        let circle = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size, height: size))
        circle.fill()
        
        // Setup text
        let font = UIFont.systemFont(ofSize: 12, weight: .bold)
        let textSize = (initials as NSString).size(withAttributes: [ .font: font ])
        
        // Erase text
        ctx.setBlendMode(.clear)
        let textRect = CGRect(x: (size - textSize.width) / 2, y: (size - textSize.height) / 2, width: textSize.width, height: textSize.height)
        (initials as NSString).draw(in: textRect, withAttributes: [ .font: font ])
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIImage {
    static func generateQRCode(key: String) -> UIImage? {
        let nameData = key.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(nameData, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            if let output = filter.outputImage?.transformed(by: transform){
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}

