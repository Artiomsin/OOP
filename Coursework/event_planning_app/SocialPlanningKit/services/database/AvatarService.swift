import Foundation
import UIKit
import Combine

public class AvatarService: ObservableObject {
    public static let shared = AvatarService()

    @Published public var avatars: [String: UIImage] = [:] // ключ — userID, значение — аватарка

    public func loadAvatar(for userID: String, base64String: String?) {
        guard let base64 = base64String,
              let data = Data(base64Encoded: base64),
              let image = UIImage(data: data) else {
            avatars[userID] = nil
            return
        }
        avatars[userID] = image
    }

    public func uploadAvatar(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let resizedImage = image.resized(to: CGSize(width: 220, height: 220)),
              let imageData = resizedImage.jpegData(compressionQuality: 0.05) else {
            completion(nil)
            return
        }
        let base64String = imageData.base64EncodedString()
        completion(base64String)
    }
}

public extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

