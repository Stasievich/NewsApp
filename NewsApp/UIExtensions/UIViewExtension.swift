//
//  UIViewExtension.swift
//  NewsApp
//
//  Created by Victor on 4/2/21.
//

import Foundation
import UIKit

extension UIView {
    func clearBackgroundColor() {
        guard let UISearchBarBackground: AnyClass = NSClassFromString("UISearchBarBackground") else { return }
        
        for view in self.subviews {
            for subview in view.subviews where subview.isKind(of: UISearchBarBackground) {
                subview.alpha = 0
            }
        }
    }
    
    func addShadowBased(on rect: CGRect) {
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = .zero
        self.layer.shadowPath = UIBezierPath(rect: rect).cgPath
    }
}
