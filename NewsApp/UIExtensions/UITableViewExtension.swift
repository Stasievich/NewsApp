//
//  UITableViewExtension.swift
//  NewsApp
//
//  Created by Victor on 4/2/21.
//

import Foundation
import UIKit

extension UITableView {
    func reloadDataWithAutoSizingCell() {
        self.reloadData()
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.reloadData()
    }
}
