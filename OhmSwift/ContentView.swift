//
//  ContentView.swift
//  OhmSwift
//
//  Created by Corné on 2/29/24.
//

import SwiftUI
import CP3_UI

let red = ColorTheme.red.color

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        ZStack {
            Color.black

            VStack(spacing: 20) {
                VStack {
                    Text("frequency")
                        .monospaced()
                        .font(.caption2)
                    Slider(value: $viewModel.frequency, in: 0.0...1.0) {
                        Text("frequency")
                    } minimumValueLabel: {
                        Text("0%")
                            .monospaced()
                            .font(.caption2)
                    } maximumValueLabel: {
                        Text("100%")
                            .monospaced()
                            .font(.caption2)
                    }
                    .padding(.bottom, 20)

                    Text("resonance")
                        .monospaced()
                        .font(.caption2)
                    Slider(value: $viewModel.resonance, in: 0.0...1.0) {
                        Text("resonance")
                            .monospaced()
                            .font(.caption2)
                    } minimumValueLabel: {
                        Text("0%")
                            .monospaced()
                            .font(.caption2)
                    } maximumValueLabel: {
                        Text("100%")
                            .monospaced()
                            .font(.caption2)
                    }
                }
                .padding(.horizontal, 20)

                HStack {
                    Button {
                        viewModel.clear()
                    } label: {
                        Image(systemName: "clear")
                            .frame(width: 44, height: 44)
                    }
                    Button {
                        viewModel.random()
                    } label: {
                        Image(systemName: "dice")
                            .frame(width: 44, height: 44)
                    }
                    Button {
                        viewModel.undo()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .frame(width: 44, height: 44)
                    }
                    Button {
                        viewModel.redo()
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                            .frame(width: 44, height: 44)
                    }
                }

                GridView(
                    sequence: $viewModel.sequence,
                    activeTouches: $viewModel.activeTouches) { viewModel.push($0) }
                .frame(width: 12 * (GridView.cellSize + 1), height: 16 * (GridView.cellSize + 1))
            }
            .tint(ColorTheme.red.color)
        }
        .environment(\.colorScheme, .dark)
        .background(.black)
    }
}

#Preview {
    ContentView()
}
