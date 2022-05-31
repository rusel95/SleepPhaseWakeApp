//
//  ShortcutComplication.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 31.05.2022.
//

import SwiftUI
import ClockKit

struct ShortcutComplication: View {
    var body: some View {
        Image("Complication/Circular")
    }
}

struct ShortcutComplication_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ShortcutComplication()
            CLKComplicationTemplateGraphicCornerCircularView(
                ShortcutComplication()
            ).previewContext()
        }
    }
}
