//
//  ImageProviderFactory.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import ClockKit
import UIKit

enum ImageProviderFactory {
    
    static func makeSleepImageProvider(isActive: Bool) -> CLKImageProvider {
        let imageProvider = CLKImageProvider(onePieceImage: Icons.Sleep.getUIImage(isActive: isActive))
        imageProvider.tintColor = isActive ? .green : .white
        return imageProvider
    }
    
    static func makeFullColorSleepImageProvider(isActive: Bool) -> CLKFullColorImageProvider {
        CLKFullColorImageProvider(fullColorImage: Icons.Sleep.getUIImage(isActive: isActive))
    }
}