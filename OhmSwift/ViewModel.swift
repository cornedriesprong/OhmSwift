//
//  ViewModel.swift
//  OhmSwift
//
//  Created by Corné on 2/29/24.
//

import Foundation
import Combine

typealias Touch = (x: Int, y: Int)

final class ViewModel: ObservableObject {
    @Published var sequence = Sequence(events: [], length: 16)
    @Published var activeTouches = [Touch]()
    @Published var frequency = 0.5
    @Published var resonance = 0.5
    @Published private var history = [Command]()
    @Published private var position = -1

    private var oscManager = OscManager()
    private var cancellables = Set<AnyCancellable>()

    init() {
        do {
            try oscManager.start()
        } catch {
            print(error)
        }
        
        $sequence.sink { sequence in
            let url = URL(string: "http://192.168.2.6:8000")!
//            let url = URL(string: "http://localhost:8000")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let body = try! JSONEncoder().encode(sequence)
            print(String(data: body, encoding: .utf8)!)
            request.httpBody = body

            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        }
        .store(in: &cancellables)
        
        $frequency.sink { [weak self] frequency in
            guard let self else { return }
            oscManager.set(frequency: frequency)
            for touch in activeTouches {
                for (index, event) in sequence.events.enumerated() where event.step == Double(touch.x) {
                    sequence.events[index].freq = frequency
                }
            }
        }
        .store(in: &cancellables)
        
        $resonance.sink { [weak self] q in
            guard let self else { return }
            oscManager.set(resonance: q)
            for touch in activeTouches {
                for (index, event) in sequence.events.enumerated() where event.step == Double(touch.x) {
                    sequence.events[index].freq = frequency
                }
            }
        }
        .store(in: &cancellables)
    }

    func push(_ command: Command) {
        history.removeSubrange((position + 1)...)
        history.append(command)
        position += 1
        apply(command)
    }

    func undo() {
        if position >= 0 {
            let command = history[position]
            applyReversed(command)
            position -= 1
        }
    }

    func redo() {
        if position < history.count - 1 {
            position += 1
            let command = history[position]
            apply(command)
        }
    }
    
    func random() {
        var commands = [Command]()
        
        // delete existing events
        for event in sequence.events {
            commands.append(.deselect(step: Int(event.step), pitch: event.pitch))
        }
        
        for step in 0..<16 {
            if Bool.random() {
                let pitch = Int.random(in: 48..<60)
                commands.append(.select(step: step, pitch: pitch))
            }
        }
        push(.transaction(commands))
    }
    
    func clear() {
        var commands = [Command]()
        for event in sequence.events {
            commands.append(.deselect(step: Int(event.step), pitch: event.pitch))
        }
        push(.transaction(commands))
    }

    // MARK: - Private methods

    private func apply(_ command: Command) {
        switch command {
        case .select(let step, let pitch):
            let event = Event(
                step: Double(step),
                pitch: pitch)
//                freq: Double.random(in: 0..<1),
//                q: Double.random(in: 0..<1))
            sequence.events.append(event)

        case .deselect(let step, let pitch):
            for (index, event) in sequence.events.enumerated() where Int(event.step) == step && event.pitch == pitch {
                sequence.events.remove(at: index)
            }

        case .transaction(let commands):
            for command in commands {
                apply(command)
            }
        }
    }
    
    private func applyReversed(_ cmd: Command) {
        switch cmd {
        case .select(let step, let pitch):
            for (index, event) in sequence.events.enumerated() where Int(event.step) == step && event.pitch == pitch {
                sequence.events.remove(at: index)
            }
            
        case .deselect(let step, let pitch):
            let event = Event(
                step: Double(step),
                pitch: pitch,
                freq: 0.5,
                q: 0.5)
            sequence.events.append(event)
            
        case .transaction(let commands):
            for command in commands.reversed() {
                applyReversed(command)
            }
        }
    }
}

