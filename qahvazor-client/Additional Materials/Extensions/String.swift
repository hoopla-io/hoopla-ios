//
//  String.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit
import CommonCrypto
import CryptoKit

extension String {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: Int(self.digits)) ?? self }
    
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}

extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

extension String {
    func toBase64() -> String {
        let data = self.data(using: String.Encoding.utf8)
        let base64 = data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        return base64
    }
}

extension String {
    var MD5: String {
        let computed = Insecure.MD5.hash(data: self.data(using: .utf8)!)
        return computed.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension String {
    func checkFileLink() -> URL {
        guard let fileLink = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let fileURL = URL(string: fileLink) else { return URL(fileURLWithPath: "") }
        return fileURL
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = self.data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [
                NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
            ], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    func isValidPhone() -> Bool {
        let phoneFormat = "\\+[0-9]{7,15}"
        let phonePredicate = NSPredicate(format:"SELF MATCHES %@", phoneFormat)
        return phonePredicate.evaluate(with: self)
    }
}

extension String {
    var initials: String {
        return self.components(separatedBy: " ")
            .reduce("") {
                ($0.isEmpty ? "" : "\($0.first?.uppercased() ?? "")") +
                ($1.isEmpty ? "" : "\($1.first?.uppercased() ?? "")")
            }
    }
}

extension String {
    func displayPhone() -> String {
        return self.applyPatternOnNumbers(pattern: "+### ## ### ## ##", replacmentCharacter: "#")
    }
    
    func originPhone() -> String {
        return self.applyPatternOnNumbers(pattern: "############", replacmentCharacter: "#")
    }
    
    func displayCardNumber() -> String {
        return self.applyPatternOnNumbers(pattern: "#### #### #### ####", replacmentCharacter: "#")
    }
    
    func originCardNumber() -> String {
        return self.applyPatternOnNumbers(pattern: "################", replacmentCharacter: "#")
    }
    
    func displayExpireDate() -> String {
        return self.applyPatternOnNumbers(pattern: "##/##", replacmentCharacter: "#")
    }
    
    func originExpireDate() -> String {
        return self.applyPatternOnNumbers(pattern: "####", replacmentCharacter: "#")
    }
    
    func displayBirthDayDate() -> String {
        return self.applyPatternOnNumbers(pattern: "##.##.####", replacmentCharacter: "#")
    }
    
    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
        return attributeString
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}

extension String {
    func extractID() -> Int? {
        let pattern = "\\d+"
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            
            if let match = results.first {
                let numberString = nsString.substring(with: match.range)
                return Int(numberString)
            }
        } catch let error {
            print("Invalid regex: \(error.localizedDescription)")
        }
        return nil
    }
}

