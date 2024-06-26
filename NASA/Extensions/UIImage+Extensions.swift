//
//  File.swift
//  NASA
//
//  Created by Alexander Ognerubov on 10.05.2024.
//

import UIKit

extension UIImage {
    func scalePreservingAspectRatio(targetSizeScale: Double) -> UIImage {
        let scaledImageSize = CGSize(
            width: size.width * targetSizeScale,
            height: size.height * targetSizeScale)
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        return scaledImage
    }
}
