// The MIT License (MIT)
//
// Copyright (c) 2016 Joe Christopher Paul Amanse
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

// swiftlint:disable missing_docs

@IBDesignable
class CheckboxButton: UIButton {
    // MARK: Inspectable properties
    
    /// Line width for the check mark. Default value is 2.
    @IBInspectable dynamic var checkLineWidth: CGFloat = 2.0 {
        didSet {
            layoutLayers()
        }
    }
    
    /// Color for the check mark (unselected). Default color is `UIColor.gray`.
    @IBInspectable dynamic var checkColor: UIColor = UIColor.gray {
        didSet {
            colorLayers()
        }
    }
    
    /// Line width for the bounding container of the check mark.
    /// Default value is 2.
    @IBInspectable dynamic var containerLineWidth: CGFloat = 2.0 {
        didSet {
            layoutLayers()
        }
    }
    
    /// Color for the bounding container of the check mark (unselected).
    /// Default color is `UIColor.gray`.
    @IBInspectable dynamic var containerColor: UIColor = UIColor.gray {
        didSet {
            colorLayers()
        }
    }

    
    /// If set to `true`, the bounding container of the check mark will be a circle rather than a box.
    /// Default value is false
    @IBInspectable dynamic var circular: Bool = false {
        didSet {
            layoutLayers()
        }
    }

    
    // MARK: Box and check properties
    let containerLayer = CAShapeLayer()
    let checkLayer = CAShapeLayer()
    
    var containerFrame: CGRect {
        let padding: CGFloat = 12.0
        let width = bounds.width - 2*padding
        let height = bounds.height - 2*padding
        
        let sideLength = height
        let _: CGFloat = (width - sideLength) / 2
        let y: CGFloat = padding
        
        let halfLineWidth = containerLineWidth / 2
        return CGRect(x: halfLineWidth, y: y + halfLineWidth, width: sideLength - containerLineWidth, height: sideLength - containerLineWidth)
    }
    
    var containerPath: UIBezierPath {
        if circular {
            return UIBezierPath(ovalIn: containerFrame)
        } else {
            return UIBezierPath(rect: containerFrame)
        }
    }
    var checkPath: UIBezierPath {
        let containerFrame = self.containerFrame
        
        // Add an offset for circular checkbox
        let offset = circular ? CGFloat(1.0 / 12) * containerFrame.width : 0
        let inset = ((containerLineWidth + checkLineWidth) / 2) + offset
        var innerRect = containerFrame.insetBy(dx: inset, dy: inset)
        innerRect.origin = CGPoint(x: innerRect.origin.x, y: innerRect.origin.y + (offset / 6))
        
        // Create check path
        let path = UIBezierPath()
        
        let unit = innerRect.width / 8
        let origin = innerRect.origin
        let x = origin.x
        let y = origin.y
        
        path.move(to: CGPoint(x: x + unit, y: y + unit * 5))
        path.addLine(to: CGPoint(x: x + unit * 3, y: y + unit * 7))
        path.addLine(to: CGPoint(x: x + unit * 7, y: y + unit))
        
        return path
    }
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        customInitialization()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInitialization()
    }
    
    /**
     Initializes a new `CheckboxButton` with a selected state.
     
     - Parameters:
     - frame: Frame of the receiver
     - selected: Selected state of the receiver
     */
    convenience init(frame: CGRect, selected: Bool) {
        self.init(frame: frame)
        self.isSelected = selected
    }
    
    func customInitialization() {
        contentHorizontalAlignment = .left
        titleEdgeInsets = UIEdgeInsets(top: 0, left: containerFrame.width * 1.35, bottom: 0, right: 0)
        
        // Initial colors
        checkLayer.fillColor = UIColor.clear.cgColor
        
        // Color and layout layers
        colorLayers()
        layoutLayers()
        
        // Add layers
        layer.addSublayer(containerLayer)
        layer.addSublayer(checkLayer)
    }
    
    // MARK: Layout
    override func layoutSubviews() {
        // Update edge insets if necessary
        let newTitleEdgeInsets = UIEdgeInsets(top: 0, left: containerFrame.width * 1.35, bottom: 0, right: 0)
        if titleEdgeInsets != newTitleEdgeInsets {
            titleEdgeInsets = newTitleEdgeInsets
        }
        
        super.layoutSubviews()
        
        // Also layout the layers when laying out subviews
        layoutLayers()
    }
    
    // MARK: Layout layers
    fileprivate func layoutLayers() {
        // Set frames, line widths and paths for layers
        containerLayer.frame = bounds
        containerLayer.lineWidth = containerLineWidth
        containerLayer.path = containerPath.cgPath
        
        checkLayer.frame = bounds
        checkLayer.lineWidth = checkLineWidth
        checkLayer.path = checkPath.cgPath
    }
    
    // MARK: Color layers
    fileprivate func colorLayers() {
        containerLayer.fillColor = UIColor.clear.cgColor
        
        // Set colors based on selection
        if isSelected {
            containerLayer.strokeColor = checkColor.cgColor
            checkLayer.strokeColor = checkColor.cgColor
        } else {
            containerLayer.strokeColor = containerColor.cgColor
            checkLayer.strokeColor = UIColor.clear.cgColor
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + containerFrame.maxX * 1.35, height: size.height)
    }
    
    // MARK: Selection
    override var isSelected: Bool {
        didSet {
            colorLayers()
        }
    }
    
    // MARK: Interface builder
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        customInitialization()
    }
}
