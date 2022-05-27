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

    @State private var dragViewWidth: CGFloat = WKInterfaceDevice.current().screenBounds.size.width - 12
    @State private var buttonOffset: CGFloat = 0
    @State private var isAnimating: Bool = false

    private let dragButtonSideSize: CGFloat = 66.0

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.teal.ignoresSafeArea()
            VStack {
                Spacer()

                HStack {
                    Text("Select")
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(Color.white)
                        .font(.system(size: 30, weight: .bold))
                    Text("duration")
                }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : -20)
                    .animation(.easeInOut(duration: 1), value: isAnimating)
                    .gesture(LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                        isSimulationMode = !isSimulationMode
                    })

                Spacer()

                Text(isSimulationMode ? "1 minute" : "8 hour")
                    .font(.system(size: 30, weight: .bold))
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeInOut(duration: 1), value: isAnimating)

                Spacer()

                // MARK: Drag View

                ZStack {
                    // 1. CAPSULES (STATIC)
                    Capsule()
                        .fill(Color.white.opacity(0.2))

                    Capsule()
                        .fill(Color.white.opacity(0.4))
                        .padding(4)

                    // 2. CALL-TO-ACTION (STATIC)

                    Image(systemName: "bed.double")
                        .foregroundColor(Color.white)
                        .font(.system(size: 24, weight: .bold))
                        .offset(x: 25)

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
                                .fill(Color.teal)
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
            .padding(6)
            .ignoresSafeArea()
            .background(Color.teal)
        }.onAppear {
            isAnimating = true
        }
    }

}

// MARK: - HELPERS

private extension NotStartedSessionView {

    func triggerSleepSessionStart() {
        // NOTE: - 8 hours default duration will be used before real selected time is not implemented
        wakeUpDate = Date().addingTimeInterval(8*60*60)
        state = .started
    }

}

// MARK: - Preview

struct NotStartedSessionView_Previews: PreviewProvider {

    static var previews: some View {
        NotStartedSessionView()
    }

}
