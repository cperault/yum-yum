//
//  RoundedImageExtension.swift
//  Yum Yum
//
//  Created by Christopher Perault on 12/17/21.
//

import UIKit
/*
 following extension found at:
 https://medium.com/@ahmedmuslimani609/rounded-corner-images-and-why-it-kills-your-app-248750884379
 */
extension UIImage{
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: 15
        ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
