//
//  NotStartedSessionView.swift
//  SleepPhaseWakeApp WatchKit Extension
//
//  Created by Ruslan Popesku on 06.05.2022.
//

import SwiftUI

struct NotStartedSessionView: View {

    // MARK: - PROPERTIES

    @State private var buttonOffset: CGFloat = 0
    @State private var dragViewWidth: CGFloat = WKInterfaceDevice.current().screenBounds.size.width - 8
    
    private let dragButtonSideSize: CGFloat = 55.0

    @ObservedObject private var viewModel: NotStartedSessionViewModel = NotStartedSessionViewModel()
    
    // MARK: - BODY

    var body: some View {
        ZStack {
            VStack {
                Text("Select wake up time:")
                    .opacity(viewModel.isAnimating ? 1 : 0)
                    .offset(y: viewModel.isAnimating ? 0 : -20)
                    .animation(.easeInOut(duration: 1), value: viewModel.isAnimating)
                    .frame(alignment: .center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .gesture(LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                        viewModel.longTapDetected()
                    })

                Spacer(minLength: 10)

                HStack(alignment: .center) {
                    Picker(selection: $viewModel.selectedHour) {
                        ForEach(0 ..< viewModel.hours.count, id: \.self) { index in
                            Text(viewModel.hours[index])
                        }
                    } label: { }

                    Text (" : ")
                        .frame(alignment: .center)
                        .offset(y: -2)

                    Picker(selection: $viewModel.selectedMinute) {
                        ForEach(0 ..< viewModel.minutes.count, id: \.self) { index in
                            Text(viewModel.minutes[index])
                        }
                    } label: { }
                }
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))
                .opacity(viewModel.isAnimating ? 1 : 0)
                .animation(.easeInOut(duration: 1), value: viewModel.isAnimating)

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

                    Image(systemName: viewModel.isSimulationMode ? "testtube.2" : "bed.double.fill")
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
                                            viewModel.startDidSelected()
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
                .opacity(viewModel.isAnimating ? 1 : 0)
                .offset(y: viewModel.isAnimating ? 0 : 40)
                .animation(.easeInOut(duration: Constants.defaultAnimationDuration),
                           value: viewModel.isAnimating)
            } //: VStack
        }
        .foregroundColor(Color.gray)
        .padding(4)
        .ignoresSafeArea(.container, edges: .bottom)
    }

}

// MARK: - PREVIEW

struct NotStartedSessionView_Previews: PreviewProvider {

    static var previews: some View {
        NotStartedSessionView()
    }

}
