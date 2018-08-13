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
    var useFullDegree: Float {
        get{
            return self.stopAngleDegree - self.startAngleDegree
        }
    }
    var startAngleDegree : Float = 135
    var stopAngleDegree : Float = 405
    var isMainCircleFullCircle : Bool = true
    var minShowableValue = 0
    var maxShowableValue = 64
    var steps = 8
    var numberFontSize : CGFloat = 13
    var centerTextFontSize : CGFloat = 17
    var measurementName = "Mbps"
    var showInnerSeprators = false
    var showMainSeprators = false
    var animationDuration : CFTimeInterval = 0.5
    var strocks = Strocks()
    var radiuses = Radiuses()
    var colorsStrocks = ColorsStrocks()
    var colorsFill = ColorsFill()
    public struct Strocks {
        var mainCircle : CGFloat = 2
        var mainSeperator : CGFloat = 2
        var innerSeperator : CGFloat = 2
        var highlighter : CGFloat = 2
    }
    public struct Radiuses {
        var mainCircle : CGFloat = 3
        var mainSeperator : CGFloat = 3
        var highlighter : CGFloat = 3
        var innerSeperator : CGFloat = 3
        var pointer : CGFloat = 15
        var pointerCircle : CGFloat = 8
    }
    public struct ColorsStrocks {
        var mainCircle : UIColor = UIColor.black
        var mainSeperator : UIColor = UIColor.black
        var innerSeperator : UIColor = UIColor.black
        var highlighter : UIColor = UIColor.red.withAlphaComponent(0.3)
        var pointer : UIColor = UIColor.black.withAlphaComponent(0.7)
        var numbers : UIColor = UIColor.black
    }
    public struct ColorsFill {
        var mainCircle : UIColor = UIColor.clear
        var mainSeperator : UIColor = UIColor.clear
        var innerSeperator : UIColor = UIColor.clear
        var highlighter : UIColor = UIColor.clear
        var pointer : UIColor = UIColor.white
        var numbers : UIColor = UIColor.white
    }
}

@IBDesignable
class iGaugeView : UIView {
    private var loaded = false
    override func layoutSubviews() {
        super.layoutSubviews()
        //check space to be square
        let square = min( frame.width, frame.height)
        usefullFrame = CGRect(x: frame.midX - (square / 2) - frame.origin.x, y:   frame.midY - (square / 2) - frame.origin.y , width: square, height: square)
        reload()
    }
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
            return CGPoint(x:usefullFrame.midX, y: usefullFrame.midY)
        }
    }
    fileprivate var useAnimationForDrawing = false
    //on avaliable degress and center of gauge view
    fileprivate func getPointOnCircle(_ radius : CGFloat, _ degree : Float) -> CGPoint{
        return CGPoint(x: cos(CGFloat(GLKMathDegreesToRadians(degree)))*radius + myCenter.x, y: sin(CGFloat(GLKMathDegreesToRadians(degree)))*radius + myCenter.y)
    }
    fileprivate func getPointOnCircleRespectToBounds(_ radius : CGFloat, _ degree : Float) -> CGPoint{
        return CGPoint(x: cos(CGFloat(GLKMathDegreesToRadians(degree)))*radius + (usefullFrame.width / 2), y: sin(CGFloat(GLKMathDegreesToRadians(degree)))*radius + (usefullFrame.height / 2))
    }
    fileprivate func getDegreeOnCircleBaseOn(value : Int) -> Float{
        if value >= self.options.maxShowableValue {
            return  self.options.stopAngleDegree
        }
        if value <= self.options.minShowableValue {
            return  self.options.startAngleDegree
        }
        let percent = (Float(value) * 100) / Float(self.options.maxShowableValue)
        return (percent * self.options.useFullDegree) / 100 + self.options.startAngleDegree
    }
    fileprivate func getDegreeOnCircleBaseOn(value : Float) -> Float{
        if value >= Float(self.options.maxShowableValue) {
            return  Float(self.options.stopAngleDegree)
        }
        if value <= Float(self.options.minShowableValue) {
            return  Float(self.options.startAngleDegree)
        }
        let percent = (value * 100) / Float(self.options.maxShowableValue)
        return (percent * self.options.useFullDegree) / 100 + self.options.startAngleDegree
    }
    override func prepareForInterfaceBuilder() {
        let square = min( frame.width, frame.height)
        usefullFrame = CGRect(x: frame.midX - (square / 2) - frame.origin.x, y:   frame.midY - (square / 2) - frame.origin.y , width: square, height: square)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    fileprivate var options : iGaugeViewOptions = iGaugeViewOptions()
    
    func setup(options : iGaugeViewOptions? = nil, withAnimation : Bool = false){
        self.useAnimationForDrawing = withAnimation
        if let options = options {
            self.options = options
        }else{
            //set default options
            self.options = iGaugeViewOptions()
            self.options.radiuses.mainCircle = usefullFrame.width / 2.5
            self.options.radiuses.mainSeperator = self.options.radiuses.mainCircle
            self.options.radiuses.innerSeperator = self.options.radiuses.mainCircle - 35
            self.options.radiuses.pointer = self.options.radiuses.innerSeperator
            self.options.strocks.highlighter = self.options.strocks.mainCircle
            self.options.radiuses.highlighter = self.options.radiuses.mainCircle
        }
    }
    func reload(){
        
        self.layer.sublayers?.removeAll()
        let mainCircle = MainCircleLayer(v: self)
        self.layer.insertSublayer(mainCircle, at: 0)
        
        let sepText = MainSeperatorTextLayer(v: self)
        self.layer.addSublayer(sepText)
        
        highlighter = HighlighterLayer(v: self)
        self.layer.insertSublayer(highlighter, above: mainCircle)
        if self.options.showMainSeprators{
            let mainSeprator = MainSeperatorPointsLayer(v: self)
            self.layer.addSublayer(mainSeprator)
        }
        if self.options.showInnerSeprators{
            let innerSeprator = InnerSeperatorPointsLayer(v: self)
            self.layer.addSublayer(innerSeprator)
        }
        
        
        pointer = PointerLayer(v: self)
        self.layer.addSublayer(pointer)
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: self.usefullFrame.width , height: self.usefullFrame.height)
        
        gradient.colors = [UIColor.white.cgColor,UIColor.white.cgColor,UIColor.yellow.cgColor,UIColor.yellow.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.mask = highlighter
        
        self.layer.addSublayer(gradient)
        self.set(currentValue: 0)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //check space to be square
        let square = min(frame.width, frame.height)
        usefullFrame = CGRect(x: frame.minX, y: frame.midY, width: square, height: square)
        
    }
}

fileprivate class MainCircleLayer : CAShapeLayer{
    var view : iGaugeView?
    init(v : iGaugeView) {
        super.init()
        self.view = v
        self.contentsScale = UIScreen.main.scale
        self.fillColor = v.options.colorsFill.mainCircle.cgColor
        self.strokeColor = v.options.colorsStrocks.mainCircle.cgColor
        self.lineWidth = v.options.strocks.mainCircle
        if v.options.isMainCircleFullCircle {
            self.path = UIBezierPath(arcCenter: v.myCenter, radius: v.options.radiuses.mainCircle, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true).cgPath
        }else{
            self.path = UIBezierPath(arcCenter: v.center, radius: v.options.radiuses.mainSeperator, startAngle: CGFloat(GLKMathDegreesToRadians(v.options.startAngleDegree)), endAngle:CGFloat(GLKMathDegreesToRadians(v.options.stopAngleDegree)), clockwise: true).cgPath
        }
        if v.useAnimationForDrawing {
            let animate = CABasicAnimation(keyPath: "strokeEnd")
            animate.fromValue = 0.0
            animate.toValue = 1.0
            animate.duration = 0.6
            self.add(animate, forKey: nil)
            
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
        self.fillColor = v.options.colorsFill.mainSeperator.cgColor
        self.strokeColor = v.options.colorsStrocks.mainSeperator.cgColor
        self.lineWidth = v.options.strocks.mainSeperator
        self.path = UIBezierPath(arcCenter: v.myCenter, radius: v.options.radiuses.mainSeperator, startAngle: CGFloat(GLKMathDegreesToRadians(v.options.startAngleDegree)), endAngle:CGFloat(GLKMathDegreesToRadians(v.options.stopAngleDegree)), clockwise: true).cgPath
        let path = UIBezierPath()
        for point in stride(from: v.options.minShowableValue, through: v.options.maxShowableValue, by: v.options.steps){
            let degree  = v.getDegreeOnCircleBaseOn(value: point)
            path.move(to: v.getPointOnCircle(v.options.radiuses.mainSeperator - 12, degree))
            path.addLine(to: v.getPointOnCircle(v.options.radiuses.mainSeperator ,degree ))
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
        
        addText(string: v.options.measurementName, frame: CGRect(x: v.myCenter.x - (100 / 2), y:v.myCenter.y + 60 , width: 100, height: 50),fontSize: v.options.centerTextFontSize)
        for point in stride(from: v.options.minShowableValue, through: v.options.maxShowableValue, by: v.options.steps){
            let degree  = v.getDegreeOnCircleBaseOn(value: point)
            let pointForLabel = v.getPointOnCircle(v.options.radiuses.innerSeperator,degree )
            
            let frame = CGRect(x: pointForLabel.x - (100 / 2), y: pointForLabel.y - 5 , width: 100, height: 50)
            addText(string: "\(point)", frame: frame,fontSize: v.options.numberFontSize)
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
        label.foregroundColor = view!.options.colorsFill.numbers.cgColor
        label.shadowColor = view!.options.colorsStrocks.numbers.cgColor
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
        self.fillColor = v.options.colorsFill.innerSeperator.cgColor
        self.strokeColor = v.options.colorsStrocks.innerSeperator.cgColor
        self.lineWidth = v.options.strocks.innerSeperator
        let path = UIBezierPath(arcCenter: v.myCenter, radius: v.options.radiuses.innerSeperator, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        maxShowableValue = (v.options.maxShowableValue / v.options.steps) * 10
        
        for point in stride(from: 0, through: maxShowableValue, by: 1){
            let degree  = self.getDegreeOnCircleBaseOn(value: point)
            if (point % 10) == 5 {
                path.move(to: v.getPointOnCircle(v.options.radiuses.innerSeperator - ((point % 10) == 5 ? 0 : 3), degree))
                path.addLine(to: v.getPointOnCircle(v.options.radiuses.innerSeperator + ((point % 10) == 5 ? 6 : 0),degree ))
            }
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
            return  view!.options.stopAngleDegree
        }
        if value <= minShowableValue {
            return  view!.options.startAngleDegree
        }
        let percent = (Float(value) * 100) / Float(maxShowableValue)
        return (percent * view!.options.useFullDegree) / 100 + view!.options.startAngleDegree
    }
}

fileprivate class HighlighterLayer : CAShapeLayer,CAAnimationDelegate{
    var view : iGaugeView?
    private var oldProgress : CGFloat = 0{
        didSet{
            self.strokeEnd =  (oldProgress / CGFloat(view!.options.maxShowableValue))
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
            print(oldProgress,progress)
            anim.fromValue = (oldProgress / CGFloat(view!.options.maxShowableValue))
            anim.duration = view!.options.animationDuration
            anim.toValue = (progress / CGFloat(view!.options.maxShowableValue))
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
        fillColor = v.options.colorsFill.highlighter.cgColor
        strokeColor = v.options.colorsStrocks.highlighter.cgColor
        lineWidth = v.options.strocks.highlighter
        let path = UIBezierPath(arcCenter: v.myCenter, radius: v.options.radiuses.highlighter, startAngle: CGFloat(GLKMathDegreesToRadians(v.options.startAngleDegree)), endAngle:CGFloat(GLKMathDegreesToRadians(v.getDegreeOnCircleBaseOn(value: 360))), clockwise: true).cgPath
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
            
            anim.duration = view!.options.animationDuration
            
            anim.fromValue = Float(-GLKMathDegreesToRadians(view!.options.startAngleDegree) + GLKMathDegreesToRadians(view!.getDegreeOnCircleBaseOn(value: (Float(oldProgress)))))
            
            anim.toValue = Float(-GLKMathDegreesToRadians(view!.options.startAngleDegree) + GLKMathDegreesToRadians(view!.getDegreeOnCircleBaseOn(value: (Float(progress)))))
            
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
        self.frame = v.usefullFrame
        fillColor = v.options.colorsFill.pointer.cgColor
        strokeColor = v.options.colorsStrocks.pointer.cgColor
        lineWidth = 2
        self.contentsScale = UIScreen.main.scale
        
        let path = UIBezierPath()
        path.move(to: v.getPointOnCircleRespectToBounds(v.options.radiuses.pointerCircle, v.getDegreeOnCircleBaseOn(value: Int(oldProgress)) + 90))
        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: v.options.radiuses.pointerCircle, startAngle: CGFloat(GLKMathDegreesToRadians(v.getDegreeOnCircleBaseOn(value: Int(oldProgress)) + 90)), endAngle: CGFloat(GLKMathDegreesToRadians(v.getDegreeOnCircleBaseOn(value: Int(oldProgress)) - 90)), clockwise: true)
        path.addLine(to: self.view!.getPointOnCircleRespectToBounds(v.options.radiuses.pointer, self.view!.getDegreeOnCircleBaseOn(value: Int(oldProgress))))
        path.addLine(to: v.getPointOnCircleRespectToBounds(v.options.radiuses.pointerCircle , v.getDegreeOnCircleBaseOn(value: Int(oldProgress)) + 90))
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
