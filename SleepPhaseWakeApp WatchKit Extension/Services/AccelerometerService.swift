//
//  AccelerometerService.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import Foundation
import CoreMotion

protocol SensorDataProvider {
    func startRecording()
    func stopRecording()
    func queryRecordedData(from startDate: Date, to endDate: Date, completion: @escaping ([CMSensorDataList]?) -> Void)
}

final class AccelerometerService: SensorDataProvider {
    static let shared = AccelerometerService()
    
    private let sensorRecorder = CMSensorRecorder()
    
    private init() {}
    
    func startRecording() {
        if CMSensorRecorder.isAccelerometerRecordingAvailable() {
            sensorRecorder.recordAccelerometer(forDuration: 30 * 60)
        }
    }
    
    func stopRecording() {
        // CMSensorRecorder doesn't have explicit stop method
        // Recording stops automatically after duration
    }
    
    func queryRecordedData(from startDate: Date, to endDate: Date, completion: @escaping ([CMSensorDataList]?) -> Void) {
        guard CMSensorRecorder.isAccelerometerRecordingAvailable() else {
            completion(nil)
            return
        }
        
        let dataList = sensorRecorder.accelerometerData(from: startDate, to: endDate)
        if let dataList = dataList {
            completion([dataList])
        } else {
            completion(nil)
        }
    }
}