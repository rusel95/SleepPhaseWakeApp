//
//  CMSensorDataList+Extension.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.05.2022.
//

import CoreMotion

extension CMSensorDataList: Sequence {

    public typealias Iterator = NSFastEnumerationIterator

    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }

}
