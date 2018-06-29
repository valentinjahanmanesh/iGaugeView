//
//  iGaugeView.swift
//  iGaugeView
//
//  Created by farshad on 6/17/18.
//  Copyright © 2018 iG. All rights reserved.
//

import UIKit
import  GLKit

public struct iGaugeViewOptions {
    static var useFullDegree: Float {
        get{
            return iGaugeViewOptions.stopAngleDegree - iGaugeViewOptions.startAngleDegree
        }
    }
    static var startAngleDegree : Float = 135
    static var stopAngleDegree : Float = 405
    static var isMainCircleFullCircle : Bool = true
    static var minShowableValue = 0
    static var maxShowableValue = 64
    static var steps = 8
    static var numberFontSize : CGFloat = 13
    static var centerTextFontSize : CGFloat = 17
    static var measurementName = "Mbps"
    static var animationDelegate : CFTimeInterval = 0.5
    
    struct strocks {
        static var mainCircle : CGFloat = 2
        static var mainSeperator : CGFloat = 2
        static var innerSeperator : CGFloat = 2
        static var highlighter : CGFloat = 2
    }
    struct radiuses {
        static var mainCircle : CGFloat = 3
        static var mainSeperator : CGFloat = 3
        static var highlighter : CGFloat = 3
        static var innerSeperator : CGFloat = 3
        static var pointer : CGFloat = 15
        static var pointer_circle : CGFloat = 8
    }
    struct colors_strocks {
        static var mainCircle : UIColor = UIColor.black
        static var mainSeperator : UIColor = UIColor.black
        static var innerSeperator : UIColor = UIColor.black
        static var highlighter : UIColor = UIColor.red.withAlphaComponent(0.3)
        static var pointer : UIColor = UIApplication.settings.neonColor.withAlphaComponent(0.7)
        static var numbers : UIColor = UIColor.black
    }
    struct colors_fill {
        static var mainCircle : UIColor = UIColor.clear
        static var mainSeperator : UIColor = UIColor.clear
        static var innerSeperator : UIColor = UIColor.clear
        static var highlighter : UIColor = UIColor.clear
        static var pointer : UIColor = UIColor.white
        static var numbers : UIColor = UIColor.white
    }
}

@IBDesignable
class iGaugeView : UIView {
    fileprivate var highlighter : HighlighterLayer!
    fileprivate var pointer : PointerLayer!
    var animationDone : ((_ currentValue : CGFloat)->Void)?
    func set(currentValue:CGFloat){
        highlighter.setNeedsLayout()
        highlighter.progress = currentValue
        pointer.progress = currentValue
    }
    var usefullFrame : CGRect! = CGRect(x: 0, y: 0, width: 0, height: 0 )
    var myCenter : CGPoint{
        get {
            return CGPoint(x:(-usefullFrame.origin.x / 2) + self.usefullFrame.width / 2, y: (-usefullFrame.origin.y / 2) + self.usefullFrame.width / 2)
        }
    }
    
    //on avaliable degress and center of gauge view
    fileprivate func getPointOnCircle(_ radius : CGFloat, _ degree : Float) -> CGPoint{
        return CGPoint(x: cos(CGFloat(GLKMathDegreesToRadians(degree)))*radius + myCenter.x, y: sin(CGFloat(GLKMathDegreesToRadians(degree)))*radius + myCenter.y)
    }
    fileprivate func getDegreeOnCircleBaseOn(value : Int) -> Float{
        if value >= iGaugeViewOptions.maxShowableValue {
            return  iGaugeViewOptions.stopAngleDegree
        }
        if value <= iGaugeViewOptions.minShowableValue {
            return  iGaugeViewOptions.startAngleDegree
        }
        let percent = (Float(value) * 100) / Float(iGaugeViewOptions.maxShowableValue)
        return (percent * iGaugeViewOptions.useFullDegree) / 100 + iGaugeViewOptions.startAngleDegree
    }
    fileprivate func getDegreeOnCircleBaseOn(value : Float) -> Float{
        if value >= Float(iGaugeViewOptions.maxShowableValue) {
            return  Float(iGaugeViewOptions.stopAngleDegree)
        }
        if value <= Float(iGaugeViewOptions.minShowableValue) {
            return  Float(iGaugeViewOptions.startAngleDegree)
        }
        let percent = (value * 100) / Float(iGaugeViewOptions.maxShowableValue)
        return (percent * iGaugeViewOptions.useFullDegree) / 100 + iGaugeViewOptions.startAngleDegree
    }
    override func prepareForInterfaceBuilder() {
        let square = min(frame.width, frame.height)
        usefullFrame = CGRect(x: self.center.x - (square / 2), y: self.center.y - (square / 2), width: square, height: square)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //check space to be square
        let square = min(-frame.origin.x + frame.width, -frame.origin.y + frame.height)
        usefullFrame = CGRect(x: frame.midX - (square / 2), y: frame.midY - (square / 2), width: square, height: square)
        setup()
    }
    func setup(){
        //set default options
        iGaugeViewOptions.radiuses.mainCircle = usefullFrame.width / 2.5
        iGaugeViewOptions.radiuses.mainSeperator = iGaugeViewOptions.radiuses.mainCircle
        iGaugeViewOptions.radiuses.innerSeperator = iGaugeViewOptions.radiuses.mainCircle - 25
        iGaugeViewOptions.radiuses.pointer = iGaugeViewOptions.radiuses.innerSeperator

        iGaugeViewOptions.strocks.highlighter = iGaugeViewOptions.radiuses.mainCircle - iGaugeViewOptions.radiuses.highlighter + 10
        iGaugeViewOptions.radiuses.highlighter = iGaugeViewOptions.radiuses.innerSeperator + 10 +  iGaugeViewOptions.strocks.innerSeperator
        self.layer.sublayers?.removeAll()
        let mainCircle = MainCircleLayer(v: self)
        self.layer.addSublayer(mainCircle)
        
        let sepText = MainSeperatorTextLayer(v: self)
        self.layer.addSublayer(sepText)
        
        highlighter = HighlighterLayer(v: self)
        self.layer.addSublayer(highlighter)
        
        let mainSeprator = MainSeperatorPointsLayer(v: self)
        self.layer.addSublayer(mainSeprator)
        
        let innerSeprator = InnerSeperatorPointsLayer(v: self)
        self.layer.addSublayer(innerSeprator)
        
        
        
        pointer = PointerLayer(v: self)
        self.layer.addSublayer(pointer)
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: self.usefullFrame.width , height: self.usefullFrame.height)
        
        gradient.colors = [UIColor(hexString: "#3023AE").cgColor,
                           UIColor(hexString: "#C86DD7").cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.mask = mainCircle
        self.layer.addSublayer(gradient)
        self.set(currentValue: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //check space to be square
        let square = min(frame.width, frame.height)
        usefullFrame = CGRect(x: frame.minX, y: frame.midY, width: square, height: square)
        
        setup()
    }
}

fileprivate class MainCircleLayer : CAShapeLayer{
    var view : iGaugeView?
    init(v : iGaugeView) {
        super.init()
        self.view = v
        self.contentsScale = UIScreen.main.scale
        self.fillColor = iGaugeViewOptions.colors_fill.mainCircle.cgColor
        self.strokeColor = iGaugeViewOptions.colors_strocks.mainCircle.cgColor
        self.lineWidth = iGaugeViewOptions.strocks.mainCircle
        if iGaugeViewOptions.isMainCircleFullCircle {
            self.path = UIBezierPath(arcCenter: v.myCenter, radius: iGaugeViewOptions.radiuses.mainCircle, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true).cgPath
        }else{
            self.path = UIBezierPath(arcCenter: v.center, radius: iGaugeViewOptions.radiuses.mainSeperator, startAngle: CGFloat(GLKMathDegreesToRadians(iGaugeViewOptions.startAngleDegree)), endAngle:CGFloat(GLKMathDegreesToRadians(iGaugeViewOptions.stopAngleDegree)), clockwise: true).cgPath
        }
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}

fileprivate class MainSeperatorPointsLayer : CAShapeLayer{
    var view : iGaugeView?
    init(v : iGaugeView) {
        super.init()
        self.view = v
        self.contentsScale = UIScreen.main.scale
        self.fillColor = iGaugeViewOptions.colors_fill.mainSeperator.cgColor
        self.strokeColor = iGaugeViewOptions.colors_strocks.mainSeperator.cgColor
        self.lineWidth = iGaugeViewOptions.strocks.mainSeperator
        self.path = UIBezierPath(arcCenter: v.myCenter, radius: iGaugeViewOptions.radiuses.mainSeperator, startAngle: CGFloat(GLKMathDegreesToRadians(iGaugeViewOptions.startAngleDegree)), endAngle:CGFloat(GLKMathDegreesToRadians(iGaugeViewOptions.stopAngleDegree)), clockwise: true).cgPath
        let path = UIBezierPath()
        for point in stride(from: iGaugeViewOptions.minShowableValue, through: iGaugeViewOptions.maxShowableValue, by: iGaugeViewOptions.steps){
            let degree  = v.getDegreeOnCircleBaseOn(value: point)
            path.move(to: v.getPointOnCircle(iGaugeViewOptions.radiuses.mainSeperator - 12, degree))
            path.addLine(to: v.getPointOnCircle(iGaugeViewOptions.radiuses.mainSeperator ,degree ))
        }
        self.path = path.cgPath
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}
fileprivate class MainSeperatorTextLayer : CAShapeLayer{
    var view : iGaugeView?
    init(v : iGaugeView) {
        super.init()
        self.view = v
        //self.frame =  CGRect(x: 0, y: 0, width: v.usefullFrame.size.width, height: v.usefullFrame.size.width)
        
        addText(string: iGaugeViewOptions.measurementName, frame: CGRect(x: v.myCenter.x - (100 / 2), y:v.myCenter.y + 60 , width: 100, height: 50),fontSize: iGaugeViewOptions.centerTextFontSize)
        for point in stride(from: iGaugeViewOptions.minShowableValue, through: iGaugeViewOptions.maxShowableValue, by: iGaugeViewOptions.steps){
            let degree  = v.getDegreeOnCircleBaseOn(value: point)
            let pointForLabel = v.getPointOnCircle(iGaugeViewOptions.radiuses.mainSeperator + 20,degree )
            
            let frame = CGRect(x: pointForLabel.x - (100 / 2), y: pointForLabel.y - 5 , width: 100, height: 50)
            addText(string: "\(point)", frame: frame,fontSize: iGaugeViewOptions.numberFontSize)
        }
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    func addText(string:String,frame:CGRect, fontSize : CGFloat = 15){
        let label = CATextLayer()
        label.contentsScale = UIScreen.main.scale

        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.fontSize = fontSize
        label.frame = frame
        label.string = string
        label.foregroundColor = iGaugeViewOptions.colors_fill.numbers.cgColor
        label.shadowColor = iGaugeViewOptions.colors_strocks.numbers.cgColor
        label.shadowRadius = 4;
        label.shadowOpacity = 1;
        label.shadowOffset = .zero;
        label.masksToBounds = false;
        label.isHidden = false
        label.alignmentMode = kCAAlignmentCenter
        self.addSublayer(label)
    }
}

fileprivate class InnerSeperatorPointsLayer : CAShapeLayer{
    private var minShowableValue = 0
    private var maxShowableValue = 240
    
    var view : iGaugeView?
    init(v : iGaugeView) {
        super.init()
        self.view = v
        self.contentsScale = UIScreen.main.scale
        self.fillColor = iGaugeViewOptions.colors_fill.innerSeperator.cgColor
        self.strokeColor = iGaugeViewOptions.colors_strocks.innerSeperator.cgColor
        self.lineWidth = iGaugeViewOptions.strocks.innerSeperator
        self.path = UIBezierPath(arcCenter: v.myCenter, radius: iGaugeViewOptions.radiuses.innerSeperator, startAngle: CGFloat(GLKMathDegreesToRadians(iGaugeViewOptions.startAngleDegree)), endAngle:CGFloat(GLKMathDegreesToRadians(iGaugeViewOptions.stopAngleDegree)), clockwise: true).cgPath
        let path = UIBezierPath()
        maxShowableValue = (iGaugeViewOptions.maxShowableValue / iGaugeViewOptions.steps) * 10
        
        for point in stride(from: 0, through: maxShowableValue, by: 1){
            let degree  = self.getDegreeOnCircleBaseOn(value: point)
            path.move(to: v.getPointOnCircle(iGaugeViewOptions.radiuses.innerSeperator - ((point % 10) == 5 ? 9 : 3), degree))
            path.addLine(to: v.getPointOnCircle(iGaugeViewOptions.radiuses.innerSeperator + ((point % 10) == 5 ? 6 : 0),degree ))
        }
        self.path = path.cgPath
    }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    private func getDegreeOnCircleBaseOn(value : Int) -> Float{
        if value >= maxShowableValue {
            return  iGaugeViewOptions.stopAngleDegree
        }
        if value <= minShowableValue {
            return  iGaugeViewOptions.startAngleDegree
        }
        let percent = (Float(value) * 100) / Float(maxShowableValue)
        return (percent * iGaugeViewOptions.useFullDegree) / 100 + iGaugeViewOptions.startAngleDegree
    }
}

fileprivate class HighlighterLayer : CAShapeLayer,CAAnimationDelegate{
    var view : iGaugeView?
    private var oldProgress : CGFloat = 0{
        didSet{
            self.strokeEnd =  (oldProgress / CGFloat(iGaugeViewOptions.maxShowableValue))
            setNeedsLayout()
        }
    }
    var progress : CGFloat = 0 {
        didSet{
            let action = self.action(forKey: "progress")
            action?.run(forKey: "progress", object: self, arguments: nil)
        }
    }
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "progress" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    func createAnimation(){
        
    }
    override func action(forKey key: String) -> CAAction? {
        if (key == "progress") {
            let anim: CABasicAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
            anim.fromValue = (oldProgress / CGFloat(iGaugeViewOptions.maxShowableValue))
            anim.duration = iGaugeViewOptions.animationDelegate
            
//            if let pres = self.presentation() {
//                oldProgress = pres.progress
//            }
            anim.toValue = (progress / CGFloat(iGaugeViewOptions.maxShowableValue))
            oldProgress = progress
            return anim
        } else {
            return super.action(forKey: key)
        }
    }
    init(v : iGaugeView) {
        super.init()
        self.view = v
        self.contentsScale = UIScreen.main.scale
        fillColor = iGaugeViewOptions.colors_fill.highlighter.cgColor
        strokeColor = iGaugeViewOptions.colors_strocks.highlighter.cgColor
        lineWidth = iGaugeViewOptions.strocks.highlighter
        let path = UIBezierPath(arcCenter: v.myCenter, radius: iGaugeViewOptions.radiuses.highlighter, startAngle: CGFloat(GLKMathDegreesToRadians(iGaugeViewOptions.startAngleDegree)), endAngle:CGFloat(GLKMathDegreesToRadians(v.getDegreeOnCircleBaseOn(value: 360))), clockwise: true).cgPath
        self.path = path
        self.strokeEnd = 0.0
        setNeedsDisplay()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
}


fileprivate class PointerLayer : CAShapeLayer{
    var view : iGaugeView?
    private var oldProgress : CGFloat = 0{
        
        didSet{
            
        }
        
    }
    var progress : CGFloat = 0 {
        
        didSet {
            
            let m =  self.action(forKey: "progress")
            
            m?.run(forKey: "progress", object: self, arguments: nil)
        }
        
    }
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "progress" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override func action(forKey key: String) -> CAAction? {
        if (key == "progress") {
            
            let anim: CABasicAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
            
            anim.fillMode = kCAFillModeForwards
            
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            
            anim.fillMode = kCAFillModeForwards;
            
            anim.isRemovedOnCompletion = false;
            
            anim.duration = iGaugeViewOptions.animationDelegate
            
            anim.fromValue = Float(-GLKMathDegreesToRadians(iGaugeViewOptions.startAngleDegree) + GLKMathDegreesToRadians(view!.getDegreeOnCircleBaseOn(value: (Float(oldProgress)))))
            
            anim.toValue = Float(-GLKMathDegreesToRadians(iGaugeViewOptions.startAngleDegree) + GLKMathDegreesToRadians(view!.getDegreeOnCircleBaseOn(value: (Float(progress)))))
            
            oldProgress = progress
            
            return anim
            
        } else {
            
            return super.action(forKey: key)
            
        }
        
    }
    init(v : iGaugeView) {
        super.init()
        self.view = v
        //self.strokeEnd = 0.0
        self.frame = CGRect(x: 0 , y: 0, width: v.usefullFrame.size.width, height: v.usefullFrame.size.width)
        //self.backgroundColor = UIColor.white.cgColor
        fillColor = iGaugeViewOptions.colors_fill.pointer.cgColor
        strokeColor = iGaugeViewOptions.colors_strocks.pointer.cgColor
        lineWidth = 2
        self.contentsScale = UIScreen.main.scale

        let path = UIBezierPath()
        path.move(to: v.getPointOnCircle(iGaugeViewOptions.radiuses.pointer_circle, v.getDegreeOnCircleBaseOn(value: Int(oldProgress)) + 90))
        path.addArc(withCenter: v.myCenter, radius: iGaugeViewOptions.radiuses.pointer_circle, startAngle: CGFloat(GLKMathDegreesToRadians(v.getDegreeOnCircleBaseOn(value: Int(oldProgress)) + 90)), endAngle: CGFloat(GLKMathDegreesToRadians(v.getDegreeOnCircleBaseOn(value: Int(oldProgress)) - 90)), clockwise: true)
        path.addLine(to: self.view!.getPointOnCircle(iGaugeViewOptions.radiuses.pointer, self.view!.getDegreeOnCircleBaseOn(value: Int(oldProgress))))
        path.addLine(to: v.getPointOnCircle(iGaugeViewOptions.radiuses.pointer_circle , v.getDegreeOnCircleBaseOn(value: Int(oldProgress)) + 90))
        self.path = path.cgPath
        //setNeedsDisplay()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
}
