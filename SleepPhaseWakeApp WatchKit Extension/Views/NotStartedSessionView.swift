//
//  NotStartedSessionView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 06.05.2022.
//

import SwiftUI

struct NotStartedSessionView: View {

    // MARK: - Property

    @AppStorage("measureState") private var state: MeasureState = .noStarted
    @AppStorage("wakeUpDate") private var wakeUpDate: Date = Date() // default value should never be used
    @AppStorage("isSimulationMode") private var isSimulationMode: Bool = false
    @AppStorage("selectedHour") private var selectedHour: Int = 8
    @AppStorage("selectedMinute") private var selectedMinute: Int = 0

    @State private var dragViewWidth: CGFloat = WKInterfaceDevice.current().screenBounds.size.width - 8
    @State private var buttonOffset: CGFloat = 0
    @State private var isAnimating: Bool = false

    private var hours: [String] = (0 ... 24).map { String($0) }
    private var minutes: [String] = (0 ... 60).map { String($0) }

    private let dragButtonSideSize: CGFloat = 55.0

    // MARK: - Body

    var body: some View {
        ZStack {
            VStack {
                Text("Select wake up time:")
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : -20)
                    .animation(.easeInOut(duration: 1), value: isAnimating)
                    .frame(alignment: .center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .gesture(LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                        isSimulationMode = !isSimulationMode
                    })

                Spacer(minLength: 10)

                HStack(alignment: .center) {
                    Picker(selection: $selectedHour) {
                        ForEach(0 ..< hours.count) {
                            Text(hours[$0])
                        }
                    } label: { }

                    Text (" : ")
                        .frame(alignment: .center)
                        .offset(y: -2)

                    Picker(selection: $selectedMinute) {
                        ForEach(0 ..< minutes.count) {
                            Text(minutes[$0])
                        }
                    } label: { }
                }
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeInOut(duration: 1), value: isAnimating)

                Spacer(minLength: 10)

                // MARK: Drag View

                ZStack {
                    // 1. CAPSULES (STATIC)
                    Capsule()
                        .fill(Color.white.opacity(0.2))

                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .padding(4)

                    // 2. CALL-TO-ACTION (STATIC)

                    Image(systemName: isSimulationMode ? "testtube.2" : "bed.double.fill")
                        .font(.system(size: 26, weight: .bold))
                        .offset(x: 20)

                    // 3. CAPSULE (DYNAMIC WIDTH)

                    HStack {
                        Capsule()
                            .fill(Color.white)
                            .frame(width: buttonOffset + dragButtonSideSize, alignment: .center)
                        Spacer()
                    }

                    // 4. CIRCLE (DRAGABLE)
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.white)

                            Circle()
                                .fill(Color.secondary)
                                .padding(4)

                            Image(systemName: "chevron.right.2")
                                .foregroundColor(Color.white)
                                .font(.system(size: 24, weight: .bold))
                        } //: ZStack
                        .frame(width: dragButtonSideSize, height: dragButtonSideSize, alignment: .center)
                        .offset(x: buttonOffset)
                        .gesture(
                            DragGesture()
                                .onChanged({ gesture in
                                    if gesture.translation.width > 0 &&
                                    buttonOffset <= dragViewWidth - dragButtonSideSize {
                                        buttonOffset = gesture.translation.width
                                    }
                                })
                                .onEnded({ _ in
                                    withAnimation(.easeOut(duration: Constants.defaultAnimationDuration)) {
                                        if buttonOffset > dragViewWidth / 2.0 {
                                            buttonOffset = dragViewWidth - dragButtonSideSize
                                            triggerSleepSessionStart()
                                        } else {
                                            buttonOffset = 0
                                        }
                                    }
                                })
                        )
                        Spacer()
                    } //: HStack
                    .frame(width: dragViewWidth, alignment: .center)

                } //: ZStack
                .frame(height: dragButtonSideSize, alignment: .center)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 40)
                .animation(.easeInOut(duration: Constants.defaultAnimationDuration),
                           value: isAnimating)
            } //: VStack
        }
        .foregroundColor(Color.gray)
        .padding(4)
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear {
            isAnimating = true
        }
    }

}

// MARK: - HELPERS

private extension NotStartedSessionView {

    func triggerSleepSessionStart() {
        if let currentDayWakeUpDate = Calendar.current.date(bySettingHour: selectedHour,
                                                            minute: selectedMinute,
                                                            second: 0,
                                                            of: Date()),
           currentDayWakeUpDate > Date() {
            wakeUpDate = currentDayWakeUpDate
        } else if let nextDayDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                  let nextDayWakeUpDate = Calendar.current.date(bySettingHour: selectedHour,
                                                                minute: selectedMinute,
                                                                second: 0,
                                                                of: Calendar.current.startOfDay(for: nextDayDate)) {
            wakeUpDate = nextDayWakeUpDate
        }
        state = .started
    }

}

// MARK: - Preview

#if DEBUG
struct NotStartedSessionView_Previews: PreviewProvider {

    static var previews: some View {
        NotStartedSessionView()
    }

}
#endif
