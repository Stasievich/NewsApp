//
//  Animations.swift
//  NewsApp
//
//  Created by Victor on 4/2/21.
//

import Foundation
import UIKit

enum TableAnimation {
    case moveUpWithFade(rowHeight: CGFloat, duration: TimeInterval, delay: TimeInterval)
    
    func getAnimation() -> TableCellAnimation {
        switch self {
        case .moveUpWithFade(let rowHeight, let duration, let delay):
            return TableAnimations.makeMoveUpWithFadeAnimation(rowHeight: rowHeight, duration: duration,
                                                                     delayFactor: delay)
        }
    }
}
