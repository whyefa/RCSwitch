//
//  RCSwitch.swift
//  RCSwitch
//
//  Created by Developer on 2016/11/7.
//  Copyright © 2016年 Beijing Haitao International Travel Service Co., Ltd. All rights reserved.
//

import UIKit

class RCSwitch: UIControl, CAAnimationDelegate {

    let duration: CFTimeInterval = 0.2
    let fontSize: CGFloat = 12
    var onText: String!
    private var onTextFrame: CGRect!
    private var onTextLayer: CATextLayer!

    private let maxLength: CGFloat = 60
    private var lightLayer: CAShapeLayer!
    private var whiteLayer: CAShapeLayer!
    private var thumbLayer: CAShapeLayer!
    private let margin: CGFloat = 2


    private var fullPath: CGPath!
    private var thumbRadius: CGFloat! 
    private var leftArcCenter: CGPoint!
    private var rightArcCenter: CGPoint!
    private let minRadius:CGFloat = 3
    private var thumbAnimation: CABasicAnimation!
    private var lightAnimation: CABasicAnimation!
    private var whiteAnimation: CABasicAnimation!

    var shadowLayer: CAShapeLayer!
    // 高亮颜色
    var lightColor: UIColor =  UIColor(red:243/255.0, green: 68/255.0, blue:107/255.0, alpha: 1)


    var isOn: Bool = false {
        didSet {
            self.isUserInteractionEnabled = false
            let leftPath = UIBezierPath(arcCenter: leftArcCenter, radius: thumbRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            let rightPath = UIBezierPath(arcCenter: rightArcCenter, radius: thumbRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            let lightMinPath = UIBezierPath(arcCenter: leftArcCenter, radius: minRadius , startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            let rightMinPath = UIBezierPath(arcCenter: rightArcCenter, radius: minRadius , startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            if self.isOn {
                thumbAnimation = nil
                thumbAnimation = pathAnimation(from: leftPath, to: rightPath)
                thumbAnimation!.delegate = self
                thumbLayer.add(thumbAnimation!, forKey: "thumb")
                lightAnimation = pathAnimation(from: lightMinPath, to: fullPath)
                lightLayer.add(lightAnimation!, forKey: "light")
                whiteAnimation = pathAnimation(from: fullPath, to: rightMinPath)
                whiteLayer.add(whiteAnimation!, forKey: "white")

            } else {

                thumbAnimation = pathAnimation(from: rightPath, to: leftPath)
                thumbAnimation!.delegate = self
                thumbLayer.add(thumbAnimation!, forKey: "thumb")
                lightAnimation = pathAnimation(from: fullPath, to: lightMinPath)
                lightLayer.add(lightAnimation!, forKey: "light")
                whiteAnimation =  pathAnimation(from: rightMinPath, to: fullPath)
                whiteLayer.add(whiteAnimation!, forKey: "white")
            }

        }
    }

    func animationDidStart(_ anim: CAAnimation) {
        if self.isOn {
            thumbLayer.path = UIBezierPath(arcCenter: rightArcCenter, radius: thumbRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            lightLayer.path = fullPath
            whiteLayer.path = UIBezierPath(arcCenter: rightArcCenter, radius: minRadius , startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath

        } else {
            thumbLayer.path = UIBezierPath(arcCenter: leftArcCenter, radius: thumbRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            lightLayer.path = UIBezierPath(arcCenter: leftArcCenter, radius: minRadius , startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            whiteLayer.path = fullPath
        }
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.isUserInteractionEnabled = true
    }

    // MARK: - init
    convenience init(frame: CGRect, text:String) {
        self.init(frame: frame)
        thumbRadius = frame.height/2-margin
        onText = text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let size = onText.size(attributes: [NSFontAttributeName: UIFont(name: "STHeitiSC-Light", size: fontSize)!, NSForegroundColorAttributeName: UIColor.black, NSParagraphStyleAttributeName: paragraphStyle])
        onTextFrame = CGRect(x: thumbRadius, y: self.frame.height/2 - size.height/2, width: size.width, height: size.height)
        fullPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: frame.height/2).cgPath
        //阴影
        shadowLayer = CAShapeLayer()
        shadowLayer.path = fullPath
        shadowLayer.fillColor = UIColor.lightGray.cgColor
        shadowLayer.frame = self.frame
        shadowLayer.shadowRadius = 1.5
        shadowLayer.shadowColor = UIColor.lightGray.cgColor
        shadowLayer.shadowOffset = .zero
        shadowLayer.shadowOpacity = 1

        // 点击事件
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        self.isOn = !isOn
    }

    // MARK: - override

    // MARK: - draw
    override func draw(_ rect: CGRect) {
        let height: CGFloat = rect.height
        let width: CGFloat = rect.width
        leftArcCenter = CGPoint(x: height/2, y: height/2)
        rightArcCenter = CGPoint(x: width-height/2, y: height/2)


        // thumbLayer
        thumbLayer = CAShapeLayer()
        thumbLayer.fillColor = UIColor.white.cgColor
        thumbLayer.shadowOffset = .zero
        thumbLayer.shadowRadius = 1
        thumbLayer.shadowColor = UIColor.lightGray.cgColor
        thumbLayer.shadowOpacity = 0.9
        thumbLayer.path = UIBezierPath(arcCenter: leftArcCenter, radius: thumbRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
        self.layer.addSublayer(thumbLayer)
        // lightLayer
        lightLayer = CAShapeLayer()
        lightLayer.fillColor = lightColor.cgColor
        lightLayer.path = UIBezierPath(arcCenter: leftArcCenter, radius: minRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
        self.layer.insertSublayer(lightLayer, below: thumbLayer)
        onTextLayer = CATextLayer()
        onTextLayer.string = onText
        onTextLayer.foregroundColor = UIColor.white.cgColor
        onTextLayer.frame = onTextFrame
        onTextLayer.fontSize = 12
        onTextLayer.contentsScale = 2
        self.layer.insertSublayer(onTextLayer, above: lightLayer)
        // whiteLayer
        whiteLayer = CAShapeLayer()
        whiteLayer.fillColor = UIColor.white.cgColor
        whiteLayer.path = UIBezierPath(arcCenter: rightArcCenter, radius: minRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
        self.layer.insertSublayer(whiteLayer, below: thumbLayer)


        // ...
        var dotStartX = width/2 + width/2/3
        let radius: CGFloat = 2
        let dot1 = CAShapeLayer()
        dot1.fillColor = UIColor.lightGray.cgColor
        let dot1Path = UIBezierPath(arcCenter: CGPoint(x: dotStartX, y: height/2), radius: radius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
        dot1.path = dot1Path.cgPath
        whiteLayer.addSublayer(dot1)

        dotStartX += radius*2 + 1
        let dot2 = CAShapeLayer()
        dot2.fillColor = UIColor.lightGray.cgColor
        let dot2Path = UIBezierPath(arcCenter: CGPoint(x: dotStartX, y: height/2), radius: radius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
        dot2.path = dot2Path.cgPath
        whiteLayer.addSublayer(dot2)

        dotStartX += radius*2 + 1
        let dot3 = CAShapeLayer()
        dot3.fillColor = UIColor.lightGray.cgColor
        let dot3Path = UIBezierPath(arcCenter: CGPoint(x: dotStartX, y: height/2), radius: radius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
        dot3.path = dot3Path.cgPath
        whiteLayer.addSublayer(dot3)

    }

    func pathAnimation(from: CGPath, to: CGPath) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        animation.fromValue = from
        animation.toValue = to
        return animation
    }

    override init(frame: CGRect) {
        var rect = frame
        rect.size.width = min(frame.width, maxLength)
        super.init(frame: rect)
        self.frame = rect
        self.backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius  = frame.height/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
