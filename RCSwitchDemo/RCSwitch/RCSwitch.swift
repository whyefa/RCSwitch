//
//  RCSwitch.swift
//  RCSwitch
//
//  Created by Developer on 2016/11/7.
//  Copyright © 2016年 Beijing Haitao International Travel Service Co., Ltd. All rights reserved.
//  a swich for  password security enter

import UIKit

let rcSwitchFontSize: CGFloat = 12

public class RCSwitch: UIControl, CAAnimationDelegate {

    // the text showing when isOn == true
    var onText: String = "" {
        didSet {
            setNeedsLayout()
        }
    }

    // the text showing when isOn == false, default show ...
    var offText: String = "" {
        didSet {
            setNeedsLayout()
        }
    }

    //  shadowLayer show on superview  or not, default is false
    var isShadowShowing: Bool = false

    //  onText background color
    var onColor: UIColor =  UIColor(red:243/255.0, green: 68/255.0, blue:107/255.0, alpha: 1) {
        didSet {
            setNeedsLayout()
        }
    }

    //  offText background color
    var offColor: UIColor = UIColor.white {
        didSet {
            setNeedsLayout()
        }
    }
    // textlayer show onText string
    private var onTextLayer: CATextLayer!
    // textlayer show offText string
    private var offTextLayer: CATextLayer?
    // switch max length
    private let maxLength: CGFloat = 60
    // thumb offset the border
    private let margin: CGFloat = 2
    // leftcorner / right corner radius
    private let minRadius:CGFloat = 3
    // thumb radius  #
    private var thumbRadius: CGFloat = 0
    // animation duration
    private let rcswitchAnimationDuration: CFTimeInterval = 0.2
    // on  backgound layer fill with onColor
    private var onLayer: CAShapeLayer!
    // off background layer fill with offColor
    private var offLayer: CAShapeLayer!
    // round thumb layer
    private var thumbLayer: CAShapeLayer!
    // switch shadow color
    private var shadowLayer: CAShapeLayer!
    // if offText is not nil, offLayer show three dot
    private var dots = [CAShapeLayer]()
    // path of whole bounds
    private var fullPath: CGPath!
    // left thumb center when isOn == true
    private var leftArcCenter: CGPoint!
    // right thumb center when isOn == false
    private var rightArcCenter: CGPoint!

    var isOn: Bool = false {
        didSet {
            self.isUserInteractionEnabled = false
            let leftPath = UIBezierPath(arcCenter: leftArcCenter, radius: thumbRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            let rightPath = UIBezierPath(arcCenter: rightArcCenter, radius: thumbRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            let lightMinPath = UIBezierPath(arcCenter: leftArcCenter, radius: minRadius , startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            let rightMinPath = UIBezierPath(arcCenter: rightArcCenter, radius: minRadius , startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            if self.isOn {
                let thumbAnimation = pathAnimation(from: leftPath, to: rightPath)
                thumbAnimation.delegate = self
                thumbLayer.add(thumbAnimation, forKey: "thumb")
                let onAnimation = pathAnimation(from: lightMinPath, to: fullPath)
                onLayer.add(onAnimation, forKey: "light")
                let offAnimation = pathAnimation(from: fullPath, to: rightMinPath)
                offLayer.add(offAnimation, forKey: "white")
                onTextLayer.isHidden = false
                offTextLayer?.isHidden = true
            } else {
                let thumbAnimation = pathAnimation(from: rightPath, to: leftPath)
                thumbAnimation.delegate = self
                thumbLayer.add(thumbAnimation, forKey: "thumb")
                let onAnimation = pathAnimation(from: fullPath, to: lightMinPath)
                onLayer.add(onAnimation, forKey: "light")
                let offAnimation =  pathAnimation(from: rightMinPath, to: fullPath)
                offLayer.add(offAnimation, forKey: "white")
                onTextLayer.isHidden = true
                offTextLayer?.isHidden = false
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let height: CGFloat = self.frame.height
        let width: CGFloat = self.frame.width
        leftArcCenter = CGPoint(x: height/2, y: height/2)
        rightArcCenter = CGPoint(x: width-height/2, y: height/2)
        thumbRadius = frame.height/2-margin


        onTextLayer.frame = onTextFrame()
        onTextLayer.string = onText

        fullPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: frame.height/2).cgPath

        thumbLayer.path = UIBezierPath(arcCenter: leftArcCenter, radius: thumbRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath

        onLayer.path = UIBezierPath(arcCenter: leftArcCenter, radius: minRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath

        offLayer.path = UIBezierPath(arcCenter: rightArcCenter, radius: minRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath

        if offText != "" {
            if offTextLayer == nil {
                offTextLayer = textLayer()
                offTextLayer!.foregroundColor = UIColor.lightGray.cgColor
                offTextLayer!.isHidden = isOn
                offLayer.addSublayer(offTextLayer!)
            }
            offTextLayer?.frame = offTextFrame()
            offTextLayer?.string = offText
            removeDots()
        } else {
            offTextLayer?.removeFromSuperlayer()
            setDots()
        }

        shadowLayer.frame = self.frame
        shadowLayer.path = fullPath
        self.superview!.layer.insertSublayer(shadowLayer, below: layer)
    }

    // MARK: - init
    override init(frame: CGRect) {
        var rect = frame
        rect.size.width = min(frame.width, maxLength)
        super.init(frame: rect)
        self.frame = rect
        self.backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius  = frame.height/2


        thumbLayer = CAShapeLayer()
        thumbLayer.fillColor = UIColor.white.cgColor
        thumbLayer.shadowOffset = .zero
        thumbLayer.shadowRadius = 1
        thumbLayer.shadowColor = UIColor.lightGray.cgColor
        thumbLayer.shadowOpacity = 0.9
        layer.addSublayer(thumbLayer)

        onLayer = CAShapeLayer()
        onLayer.fillColor = onColor.cgColor
        layer.insertSublayer(onLayer, below: thumbLayer)

        onTextLayer = textLayer()
        onTextLayer.isHidden = true
        layer.insertSublayer(onTextLayer, above: offLayer)


        offLayer = CAShapeLayer()
        offLayer.fillColor = UIColor.white.cgColor
        self.layer.insertSublayer(offLayer, below: thumbLayer)


        shadowLayer = CAShapeLayer()
        shadowLayer.fillColor = UIColor.lightGray.cgColor
        shadowLayer.frame = self.frame
        shadowLayer.shadowRadius = 1.5
        shadowLayer.shadowColor = UIColor.lightGray.cgColor
        shadowLayer.shadowOffset = .zero
        shadowLayer.shadowOpacity = 1


        // tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }


    private func setDots() {
        let width = self.frame.width
        let height = self.frame.height
        var dotStartX = width/2 + width/2/3
        let radius: CGFloat = 2
        let dot1 = CAShapeLayer()
        dot1.fillColor = UIColor.lightGray.cgColor
        let dot1Path = UIBezierPath(arcCenter: CGPoint(x: dotStartX, y: height/2), radius: radius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
        dot1.path = dot1Path.cgPath
        offLayer.addSublayer(dot1)

        dotStartX += radius*2 + 1
        let dot2 = CAShapeLayer()
        dot2.fillColor = UIColor.lightGray.cgColor
        let dot2Path = UIBezierPath(arcCenter: CGPoint(x: dotStartX, y: height/2), radius: radius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
        dot2.path = dot2Path.cgPath
        offLayer.addSublayer(dot2)

        dotStartX += radius*2 + 1
        let dot3 = CAShapeLayer()
        dot3.fillColor = UIColor.lightGray.cgColor
        let dot3Path = UIBezierPath(arcCenter: CGPoint(x: dotStartX, y: height/2), radius: radius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
        dot3.path = dot3Path.cgPath
        offLayer.addSublayer(dot3)
        dots.append(dot1)
        dots.append(dot2)
        dots.append(dot3)
    }

    private func removeDots() {
        for dot in dots {
            dot.removeFromSuperlayer()
        }
        dots.removeAll()
    }



    // MARK: - animate
    private func pathAnimation(from: CGPath, to: CGPath) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = rcswitchAnimationDuration
        animation.fromValue = from
        animation.toValue = to
        return animation
    }

    func animationDidStart(_ anim: CAAnimation) {
        if self.isOn {
            thumbLayer.path = UIBezierPath(arcCenter: rightArcCenter, radius: thumbRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            onLayer.path = fullPath
            offLayer.path = UIBezierPath(arcCenter: rightArcCenter, radius: minRadius , startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath

        } else {
            thumbLayer.path = UIBezierPath(arcCenter: leftArcCenter, radius: thumbRadius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            onLayer.path = UIBezierPath(arcCenter: leftArcCenter, radius: minRadius , startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true).cgPath
            offLayer.path = fullPath
        }
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.isUserInteractionEnabled = true
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    // MARK: - private
    @objc private func handleTap() {
        self.isOn = !isOn
    }


    // MARK: - text layer 
    private func textLayer() -> CATextLayer {
        let textlayer = CATextLayer()
        textlayer.foregroundColor = UIColor.white.cgColor
        textlayer.fontSize = rcSwitchFontSize
        textlayer.font = "PingFangSC-Light" as CFTypeRef?
        textlayer.contentsScale = 2
        return textlayer
    }

    private func onTextFrame() -> CGRect {
        let size = textSize(str: onText)
        return CGRect(origin: CGPoint(x: thumbRadius, y: (self.frame.height-size.height)/2), size: size)
    }

    private func offTextFrame() -> CGRect{
        let size = textSize(str: offText)
        let x:CGFloat = self.frame.width - CGFloat(10) - size.width
        return CGRect(origin: CGPoint(x: x, y: (self.frame.height-size.height)/2), size: size)
    }

    private func textSize(str: String) -> CGSize {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let size = str.size(attributes: [NSFontAttributeName: UIFont(name: "PingFangSC-Light", size: rcSwitchFontSize)!, NSForegroundColorAttributeName: UIColor.black, NSParagraphStyleAttributeName: paragraphStyle])
        return size
    }

}
