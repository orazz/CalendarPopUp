// PopupContainer.swift
//
// Copyright (c) 2015 Technopix ( http://www.technopix.com.ar )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

private let kDialogViewCornerRadius : CGFloat = 3

open class PopupContainer: UIView {
    
    let kMotionEffectExtent : CGFloat = 10

    var dialogView : UIView!
    
    open class func generatePopupWithView(_ view: UIView) -> PopupContainer{
        let popupContainer = PopupContainer()
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(
            popupContainer,
            selector: #selector(PopupContainer.interfaceOrientationChanged(_:)),
            name: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil)
        
        popupContainer.dialogView = view;
        popupContainer.dialogView.layer.cornerRadius = kDialogViewCornerRadius
        
        return popupContainer;
    }
    
    // MARK: - Initialization and deinitialization methods
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    // MARK: Setup UI methods
    
    func applyMotionEffects() {
        let horizontalEfect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalEfect.minimumRelativeValue = -kMotionEffectExtent
        horizontalEfect.maximumRelativeValue = kMotionEffectExtent
        
        let verticalEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalEffect.minimumRelativeValue = -kMotionEffectExtent
        verticalEffect.maximumRelativeValue = kMotionEffectExtent
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalEfect, verticalEffect]
        
        self.dialogView.addMotionEffect(motionEffectGroup)
    }
    
    func interfaceOrientationChanged(_ notification: Notification) {
        var rotationAngle : CGFloat = 0
        
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft: rotationAngle = CGFloat(Double.pi/2) * 3
        case .landscapeRight: rotationAngle = CGFloat(Double.pi/2)
        case .portrait: rotationAngle = 0
        case .portraitUpsideDown: rotationAngle = CGFloat(Double.pi)
        default: rotationAngle = 0
        }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: [],
            animations: { () -> Void in
                let window = UIApplication.shared.delegate!.window!
                self.center = CGPoint(x: window!.frame.size.width / 2, y: window!.frame.size.height / 2)
                if self.isInIOS8() == false {
                    self.transform = CGAffineTransform(rotationAngle: rotationAngle)
                }
            }, completion: nil)
    }

    // MARK: Touch events

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if touchIsOutsideDialogView(touch) {
            //close()
        }
    }
    
    // MARK: - Interaction Methods
    
    open func show() {
        self.applyMotionEffects()
        
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let largerSide = screenWidth > screenHeight ? screenWidth : screenHeight
        
        //For the black background
        self.frame = CGRect(x: 0, y: 0, width: largerSide * 2, height: largerSide * 2)
        
        self.dialogView.layer.opacity = 0.5
        self.dialogView.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.0)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.addSubview(self.dialogView)
        
        self.dialogView.center = self.center
        
        let window = UIApplication.shared.delegate!.window!
        window?.addSubview(self)
        self.center = CGPoint(x: window!.frame.size.width / 2, y: window!.frame.size.height / 2)
        
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        
        switch (interfaceOrientation) {
        case .landscapeLeft: self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2) * 3)
        case .landscapeRight: self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        case .portrait: self.transform = CGAffineTransform(rotationAngle: 0)
        case .portraitUpsideDown: self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        default: break;
        }
        
        // iOS8 Fix: Transformations are applied only in an animation block. Don't know why...
        if self.isInIOS8() {
            UIView.animate(withDuration: 0.001, animations: { () -> Void in
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: UIViewAnimationOptions(),
            animations: { () -> Void in
                self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                self.dialogView.layer.opacity = 1
                self.dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }, completion: nil)
    }
    
    open func close() {
        self.dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1)
        self.dialogView.layer.opacity = 1.0
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: UIViewAnimationOptions(),
            animations: { () -> Void in
                self.backgroundColor = UIColor.black.withAlphaComponent(0)
                self.dialogView.layer.transform = CATransform3DMakeScale(0.6, 0.6, 1)
                self.dialogView.layer.opacity = 0
            }) { (finished: Bool) -> Void in
            self.removeFromSuperview()
        }
    }

    // MARK: - Helper Methods

    func isInIOS8() -> Bool {
        return (UIDevice.current.systemVersion as NSString).floatValue >= 8
    }

    func touchIsOutsideDialogView(_ touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: dialogView)
        return touchPoint.x < 0 || touchPoint.y < 0 || touchPoint.x > dialogView.bounds.width || touchPoint.y > dialogView.bounds.height
    }

}
