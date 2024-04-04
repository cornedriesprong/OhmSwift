//
//  GridView.swift
//  OhmSwift
//
//  Created by Corné on 2/29/24.
//

import CP3_UI
import SwiftUI
import UIKit

final class InternalGridView: UIView {
    // MARK: Private properties
    
    private var cells = [UIView]()
    private var selection = [Bool]()
    private var activeTouches = [UITouch: Int]() {
        didSet {
            touchesHandler(activeTouches.map { getStepAndPitch(at: $0.value) })
        }
    }

    private var prevSelection: Int?
    private var selectionHandler: GridView.SelectionHandler
    private var touchesHandler: GridView.TouchesHandler
    
    // MARK: Initialization
    
    init(
        selectionHandler: @escaping GridView.SelectionHandler,
        touchesHandler: @escaping GridView.TouchesHandler
    ) {
        self.selectionHandler = selectionHandler
        self.touchesHandler = touchesHandler
        
        super.init(frame: .zero)
        
        configure()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configuration
    
    private func configure() {
        for _ in 0..<16 {
            for _ in 0..<12 {
                let rectangle = UIView()
                rectangle.backgroundColor = ColorTheme.red.uiColor.dark()
                addSubview(rectangle)
                cells.append(rectangle)
                selection.append(false)
            }
        }
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = GridView.cellSize
        for row in 0..<16 {
            for column in 0..<12 {
                let margin: CGFloat = 1
                let rectangle = cells[row * 12 + column]
                rectangle.frame = CGRect(
                    x: CGFloat(column) * (size + margin),
                    y: CGFloat(row) * (size + margin),
                    width: size,
                    height: size
                )
            }
        }
    }
    
    // MARK: Public methods
    
    func update(sequence: Sequence) {
        for (index, _) in cells.enumerated() {
            selection[index] = false
            cells[index].backgroundColor = ColorTheme.red.uiColor.dark()
        }
        
        for event in sequence.events {
            let index = (Int(event.step) * 12) + (event.pitch - 48)
            selection[index] = true
            cells[index].backgroundColor = ColorTheme.red.uiColor
        }
        
        setNeedsLayout()
    }
    
    // MARK: Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            for (index, cell) in cells.enumerated() {
                if cell.frame.contains(location) {
                    let (step, pitch) = getStepAndPitch(at: index)
                    activeTouches[touch] = index
                    
                    if selection[index] {
                        selectionHandler(.deselect(step: step, pitch: pitch))
                        
                    } else {
                        selectionHandler(.select(step: step, pitch: pitch))
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            for (index, cell) in cells.enumerated() {
                if cell.frame.contains(location) {
                    let (step, pitch) = getStepAndPitch(at: index)
                    let isOn = selection[index]
                    if index != prevSelection {
                        if isOn {
                            selectionHandler(.deselect(step: step, pitch: pitch))
                            
                        } else {
                            selectionHandler(.select(step: step, pitch: pitch))
                            activeTouches[touch] = index
                        }
                        prevSelection = index
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            activeTouches[touch] = nil
        }
    }
    
    // MARK: Private methods
    
    private func getStepAndPitch(at index: Int) -> (x: Int, y: Int) {
        let div = Double(index) / 12.0
        let x = Int(floor(div))
        let y = Int(round(div.truncatingRemainder(dividingBy: 1) * 12.0))
        return (x: x, y: y + 48)
    }
}

struct GridView: UIViewRepresentable {
    static let cellSize: CGFloat = 30
    
    typealias SelectionHandler = (Command) -> Void
    typealias TouchesHandler = ([(x: Int, y: Int)]) -> Void
    
    @Binding var sequence: Sequence
    @Binding var activeTouches: [Touch]
    
    var selectionHandler: SelectionHandler
    
    func makeUIView(context: Context) -> InternalGridView {
        return InternalGridView(selectionHandler: selectionHandler) {
            activeTouches = $0
        }
    }

    func updateUIView(_ uiView: InternalGridView, context: Context) {
        uiView.update(sequence: sequence)
    }
}
