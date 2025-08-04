//
//  MovementDetector.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import Foundation
import CoreMotion

protocol AccelerometerDataHandler {
    func handleAccelerometerData(_ data: CMAccelerometerData) -> Bool
}

final class MovementDetector: AccelerometerDataHandler {
    private let movementThreshold: Double
    
    init(movementThreshold: Double = 1.2) {
        self.movementThreshold = movementThreshold
    }
    
    func handleAccelerometerData(_ data: CMAccelerometerData) -> Bool {
        let totalAcceleration = sqrt(
            pow(data.acceleration.x, 2) +
            pow(data.acceleration.y, 2) +
            pow(data.acceleration.z, 2)
        )
        
        return totalAcceleration > movementThreshold
    }
}