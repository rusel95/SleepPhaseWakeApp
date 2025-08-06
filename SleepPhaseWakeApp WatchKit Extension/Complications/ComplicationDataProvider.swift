//
//  ComplicationDataProvider.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 04.08.2025.
//

import Foundation
import ClockKit
import SwiftUI

protocol ComplicationDataProviding {
    func getCurrentEntry(for family: CLKComplicationFamily) -> CLKComplicationTimelineEntry?
    func getSampleTemplate(for family: CLKComplicationFamily) -> CLKComplicationTemplate?
}

final class ComplicationDataProvider: ComplicationDataProviding {
    private let stateManager = AppStateManager.shared
    
    func getCurrentEntry(for family: CLKComplicationFamily) -> CLKComplicationTimelineEntry? {
        guard let template = getTemplate(for: family, isSample: false) else { return nil }
        return CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
    }
    
    func getSampleTemplate(for family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        return getTemplate(for: family, isSample: true)
    }
    
    private func getTemplate(for family: CLKComplicationFamily, isSample: Bool) -> CLKComplicationTemplate? {
        let sleepInfo = getSleepInfo(isSample: isSample)
        
        switch family {
        case .circularSmall:
            return createCircularSmallTemplate(with: sleepInfo)
        case .modularSmall:
            return createModularSmallTemplate(with: sleepInfo)
        case .modularLarge:
            return createModularLargeTemplate(with: sleepInfo)
        case .utilitarianSmall, .utilitarianSmallFlat:
            return createUtilitarianSmallTemplate(with: sleepInfo)
        case .utilitarianLarge:
            return createUtilitarianLargeTemplate(with: sleepInfo)
        case .extraLarge:
            return createExtraLargeTemplate(with: sleepInfo)
        case .graphicCorner:
            return createGraphicCornerTemplate(with: sleepInfo)
        case .graphicBezel:
            return createGraphicBezelTemplate(with: sleepInfo)
        case .graphicCircular:
            return createGraphicCircularTemplate(with: sleepInfo)
        case .graphicRectangular:
            return createGraphicRectangularTemplate(with: sleepInfo)
        case .graphicExtraLarge:
            return createGraphicExtraLargeTemplate(with: sleepInfo)
        @unknown default:
            return nil
        }
    }
    
    private func getSleepInfo(isSample: Bool) -> SleepComplicationInfo {
        if isSample {
            return SleepComplicationInfo(
                state: .notStarted,
                wakeUpTime: Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date()) ?? Date(),
                isActive: false
            )
        }
        
        return SleepComplicationInfo(
            state: stateManager.measureState,
            wakeUpTime: stateManager.wakeUpDate,
            isActive: stateManager.measureState == .started
        )
    }
    
    // MARK: - Template Creation Methods
    
    private func createCircularSmallTemplate(with info: SleepComplicationInfo) -> CLKComplicationTemplate {
        let imageProvider = ImageProviderFactory.makeSleepImageProvider(isActive: info.isActive)
        return CLKComplicationTemplateCircularSmallSimpleImage(imageProvider: imageProvider)
    }
    
    private func createModularSmallTemplate(with info: SleepComplicationInfo) -> CLKComplicationTemplate {
        let imageProvider = ImageProviderFactory.makeSleepImageProvider(isActive: info.isActive)
        return CLKComplicationTemplateModularSmallSimpleImage(imageProvider: imageProvider)
    }
    
    private func createModularLargeTemplate(with info: SleepComplicationInfo) -> CLKComplicationTemplate {
        let headerText = CLKSimpleTextProvider(text: "Sleep Phase")
        let body1Text = CLKSimpleTextProvider(text: info.statusText)
        let body2Text = CLKSimpleTextProvider(text: info.timeText)
        
        return CLKComplicationTemplateModularLargeStandardBody(
            headerTextProvider: headerText,
            body1TextProvider: body1Text,
            body2TextProvider: body2Text
        )
    }
    
    private func createUtilitarianSmallTemplate(with info: SleepComplicationInfo) -> CLKComplicationTemplate {
        let imageProvider = ImageProviderFactory.makeSleepImageProvider(isActive: info.isActive)
        return CLKComplicationTemplateUtilitarianSmallSquare(imageProvider: imageProvider)
    }
    
    private func createUtilitarianLargeTemplate(with info: SleepComplicationInfo) -> CLKComplicationTemplate {
        let textProvider = CLKSimpleTextProvider(text: info.isActive ? "Sleep tracking active" : "Tap to set alarm")
        
        return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: textProvider)
    }
    
    private func createExtraLargeTemplate(with info: SleepComplicationInfo) -> CLKComplicationTemplate {
        let imageProvider = ImageProviderFactory.makeSleepImageProvider(isActive: info.isActive)
        return CLKComplicationTemplateExtraLargeSimpleImage(imageProvider: imageProvider)
    }
    
    private func createGraphicCornerTemplate(with info: SleepComplicationInfo) -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicCornerCircularView(
            ComplicationViews.GraphicCornerView(info: info)
        )
    }
    
    private func createGraphicBezelTemplate(with info: SleepComplicationInfo) -> CLKComplicationTemplate {
        let circularTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeImage(
            gaugeProvider: CLKSimpleGaugeProvider(style: .fill, gaugeColor: .green, fillFraction: info.isActive ? 1.0 : 0.0),
            imageProvider: ImageProviderFactory.makeFullColorSleepImageProvider(isActive: true)
        )
        
        let textProvider = CLKSimpleTextProvider(text: info.statusText)
        
        return CLKComplicationTemplateGraphicBezelCircularText(
            circularTemplate: circularTemplate,
            textProvider: textProvider
        )
    }
    
    private func createGraphicCircularTemplate(with info: SleepComplicationInfo) -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicCircularView(
            ComplicationViews.GraphicCircularView(info: info)
        )
    }
    
    private func createGraphicRectangularTemplate(with info: SleepComplicationInfo) -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicRectangularFullView(
            ComplicationViews.GraphicRectangularView(info: info)
        )
    }
    
    private func createGraphicExtraLargeTemplate(with info: SleepComplicationInfo) -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicExtraLargeCircularView(
            ComplicationViews.GraphicExtraLargeView(info: info)
        )
    }
}

// MARK: - Supporting Types

struct SleepComplicationInfo {
    let state: MeasureState
    let wakeUpTime: Date
    let isActive: Bool
    
    var statusText: String {
        switch state {
        case .notStarted:
            return "Not Started"
        case .started:
            return "Tracking Sleep"
        case .finished:
            return "Wake Up Complete"
        }
    }
    
    var timeText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: wakeUpTime)
    }
}