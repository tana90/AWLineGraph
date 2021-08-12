//
//  AWLineGraph.swift
//  AWLineGraphDemo
//
//  Created by Tudor Octavian Ana on 11.08.2021.
//

import UIKit

// MARK: Data structure

public struct AWLineGraphData {
    var xValue: String
    var yValue: Double
    
    public init(xValue: String, yValue: Double) {
        self.xValue = xValue
        self.yValue = yValue
    }
}

// MARK: - UIView

public class AWLineGraph: UIView {

    @IBInspectable var maxNumberOfEntries: Int = 10
    @IBInspectable var showVerticalGrid: Bool = true
    @IBInspectable var showHorizontalGrid: Bool = true
    @IBInspectable var showTopLabels: Bool = true
    @IBInspectable var showBottomLabels: Bool = true
    @IBInspectable var labelsColor: UIColor = .black
    @IBInspectable var lineWidth: CGFloat = 2.0
    @IBInspectable var circleRadius: CGFloat = 4.0
    
    public var data: [AWLineGraphData] = [] {
        didSet {
            render()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if data.count > 0 {
            render()
        }
    }
}

// MARK: Helpers

extension AWLineGraph {
    
    func removeLayers() {
        layer.sublayers?.forEach({ layer in
            layer.removeFromSuperlayer()
        })
    }
    
    func render() {
        
        removeLayers()
        
        // Prepare data
        let maxNumberOfElements = min(maxNumberOfEntries, data.count)
        let elements = data.suffix(maxNumberOfElements)
        
        // Calculate max value
        let maxValue: Double = elements.map { $0.yValue }
            .max { $0 < $1 } ?? 0.0
        
        // Calculate min value
        let minValue: Double = elements.map { $0.yValue }
            .min { $0 < $1 } ?? 0.0
        
        let bottomBase = frame.size.height - 22
        let graphHeight = bottomBase
        var verticalSpacing = frame.size.width / CGFloat(maxNumberOfElements)
        verticalSpacing += verticalSpacing / CGFloat(maxNumberOfElements - 1)
        var horizontalSpacing = bottomBase / 3
        horizontalSpacing += horizontalSpacing / 2

        elements.enumerated().forEach { iterator, element in
            
            // Draw vertical grid
            
            if showVerticalGrid {
                line(from: CGPoint(x: verticalSpacing * CGFloat(iterator), y: 0),
                     to: CGPoint(x: verticalSpacing * CGFloat(iterator), y: bottomBase),
                     color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5),
                     width: 0.3)
            }
            
            // Draw horizontal grid
            
            if showHorizontalGrid {
                if iterator < 3 {
                    line(from: CGPoint(x: 0, y: bottomBase - (horizontalSpacing * CGFloat(iterator))),
                         to: CGPoint(x: frame.size.width, y: bottomBase - (horizontalSpacing * CGFloat(iterator))),
                         color: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5),
                         width: 0.3)
                }
            }

            // Draw top labels

            if showTopLabels {
                let label = CATextLayer()
                label.frame = CGRect(x: 0, y: 0, width: horizontalSpacing * 2, height: 22)
                label.position = CGPoint(x: verticalSpacing * CGFloat(iterator),
                                         y: bottomBase - (CGFloat(element.yValue - minValue) *
                                                            graphHeight) / CGFloat(maxValue - minValue) - 10)
                label.alignmentMode = .center
                label.string = element.yValue.compact()
                let font = UIFont.systemFont(ofSize: 7.0)
                let fontName = font.fontName as NSString
                label.font = CGFont(fontName)
                label.fontSize = 10
                label.foregroundColor = labelsColor.cgColor
                layer.addSublayer(label)
            }
            
            // Draw bottom labels
            
            if showBottomLabels {
                let label = CATextLayer()
                label.frame = CGRect(x: 0, y: 0, width: horizontalSpacing * 2, height: 30)
                label.position = CGPoint(x: verticalSpacing * CGFloat(iterator),
                                         y: bottomBase + 22)
                label.alignmentMode = .center
                label.string = element.xValue
                let font = UIFont.systemFont(ofSize: 7.0)
                let fontName = font.fontName as NSString
                label.font = CGFont(fontName)
                label.fontSize = 10
                label.foregroundColor = labelsColor.cgColor
                layer.addSublayer(label)
            }
            
            // Draw cicles
            
            circle(from: CGPoint(x: verticalSpacing * CGFloat(iterator),
                                 y: bottomBase - (CGFloat(element.yValue - minValue)
                                                    * graphHeight) / CGFloat(maxValue - minValue)),
                   radius: circleRadius,
                   color: tintColor)
            
            // Draw lines
            
            if iterator < maxNumberOfElements - 1 {
                let nextElement = elements[iterator + 1]
                line(from: CGPoint(x: verticalSpacing * CGFloat(iterator),
                                   y: bottomBase - ((CGFloat(element.yValue - minValue) *
                                                        graphHeight) / CGFloat(maxValue - minValue))),
                     to: CGPoint(x: verticalSpacing * CGFloat(iterator + 1),
                                 y: bottomBase - ((CGFloat(nextElement.yValue - minValue) *
                                                    graphHeight) / CGFloat(maxValue - minValue))),
                     color: tintColor,
                     width: lineWidth)
            }
        }
    }
    
    func line(from startPoint: CGPoint,
              to endPoint: CGPoint,
              color: UIColor = .black,
              width: CGFloat = 1.0) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        line.path = linePath.cgPath
        line.strokeColor = color.cgColor
        line.lineWidth = width
        layer.addSublayer(line)
    }
    
    func circle(from startPoint: CGPoint,
                radius: CGFloat = 5,
                color: UIColor = .black,
                width: CGFloat = 3.0) {
        let circlePath = UIBezierPath(arcCenter: startPoint,
                                      radius: radius,
                                      startAngle: CGFloat(0),
                                      endAngle: CGFloat(Double.pi * 2),
                                      clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = color.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        layer.addSublayer(shapeLayer)
    }
}

extension Double {
    
    func compact() -> String {
        if self >= 1000000 {
            return String(format: "%.1fm", Double(self) / 1000000)
        } else if self >= 1000 {
            return String(format: "%.1fk", Double(self) / 1000)
        } else {
            return String(format: "%.0f", self)
        }
    }
}
