//
//  Icons.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import UIKit
import SwiftUI

enum Icons {
    enum Sleep {
        static let active = "bed.double.fill"
        static let inactive = "bed.double"
        
        static func getUIImage(isActive: Bool) -> UIImage {
            let systemName = isActive ? active : inactive
            return UIImage(systemName: systemName) ?? UIImage()
        }
        
        static func getImage(isActive: Bool) -> Image {
            Image(systemName: isActive ? active : inactive)
        }
    }
}