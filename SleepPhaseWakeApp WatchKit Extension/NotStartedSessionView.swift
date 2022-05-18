//
//  NotStartedSessionView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 06.05.2022.
//

import SwiftUI
import CoreMotion

struct NotStartedSessionView: View {

    // MARK: - Property

    @AppStorage("measureState") private var state: MeasureState = .noStarted
    @AppStorage("lastSessionStart") private var lastSessionStart: Date?

    @State private var dragViewWidth: CGFloat = WKInterfaceDevice.current().screenBounds.size.width - 12
    @State private var buttonOffset: CGFloat = 0
    @State private var isAnimating: Bool = false

    private let recorder = CMSensorRecorder()
    private let defaultTimeInterval = TimeInterval(8*60) // 1 minute
    private let dragButtonSideSize: CGFloat = 50.0

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.teal.ignoresSafeArea()
            VStack {
                Spacer()

                Text("Select Wake Up time:")
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : -20)
                    .animation(.easeInOut(duration: 1), value: isAnimating)

                Spacer()

                Text("8 hour")
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

                    Text("Sleep")
                        .fontWeight(.bold)
                        .offset(x: 18.0)

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
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        if buttonOffset > dragViewWidth / 2.0 {
                                            buttonOffset = dragViewWidth - dragButtonSideSize
                                            state = .started
                                        } else {
                                            buttonOffset = 0
                                        }
                                    }
                                    startRecording()
                                })
                        )

                        Spacer()
                    } //: HStack
                    .frame(width: dragViewWidth, alignment: .center)

                } //: ZStack
                .frame(height: dragButtonSideSize, alignment: .center)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 40)
                .animation(.easeInOut(duration: 0.3), value: isAnimating)

                Spacer()
            } //: VStack
            .padding(6)
            .ignoresSafeArea()
            .background(Color.teal)
        }.onAppear {
            isAnimating = true
        }
    }

}

// MARK: - Helpers

private extension NotStartedSessionView {

    func startRecording() {
        lastSessionStart = Date()

        if CMSensorRecorder.isAccelerometerRecordingAvailable() {
            DispatchQueue.global(qos: .background).async {
                self.recorder.recordAccelerometer(forDuration: defaultTimeInterval)
            }
        }
    }
    
}

// MARK: - Preview

struct NotStartedSessionView_Previews: PreviewProvider {

    static var previews: some View {
        NotStartedSessionView()
    }

}
