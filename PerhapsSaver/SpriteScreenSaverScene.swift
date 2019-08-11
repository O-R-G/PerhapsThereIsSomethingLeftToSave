//
//  SpriteScreenSaverScene.swift
//  SwiftScreenSaver
//
//  Created by Eric Li on 10/03/18.
//  Copyright © O-R-G inc. All rights reserved.
//

import SpriteKit
import ScreenSaver
import Cocoa

struct CircleProperties {
    var max = 0.0
    var min = 0.0
    var now = 0.0
    var step = 0.0
    var dir = 0
}


class SpriteScreenSaverScene: SKScene
{
    override var acceptsFirstResponder: Bool { return false }
 
    let numPoints = 10
    var circleCenters = [CGPoint](repeating: CGPoint(), count: 10)
    var circleDirs = [CGPoint](repeating: CGPoint(), count: 10)
    var circleProps = [CircleProperties](repeating: CircleProperties(), count: 10)
    var thisYellow = [NSColor](repeating: NSColor(), count: 10)
    var thisGray = [NSColor](repeating: NSColor(), count: 10)
    
    let minSpeed = 2
    let maxSpeed = 5
    
    var sliceSwitch = 1
    var slicesTotal = Int(SSRandomFloatBetween(200.0, 300.0))
    var waveCounter = 0
    
    let sunriseSunsetObj : SunriseSunset = SunriseSunset()
    
    override func didMove(to view: SKView)
	{
        self.resignFirstResponder()
        self.isUserInteractionEnabled=false
        
        self.setColors()
        self.initValues()
    }
	
	
    override func update(_ currentTime: TimeInterval)
	{
        let sunSwitch = sunriseSunsetObj.checkTime()
        if (sunSwitch == -1) {
            return
        }
        
        waveCounter+=1
        
        if (waveCounter > 2) {
            if (sliceSwitch == 1) {
                slicesTotal += 2
                if (slicesTotal > 320) {
                    sliceSwitch = 2
                }
            }
            if (sliceSwitch == 2) {
                slicesTotal -= 2
                if (slicesTotal < 180) {
                    sliceSwitch = 1
                }
            }
            waveCounter = 0
        }

        //        let size = self.frame
        let DEG2RAD = CGFloat(3.14159 / 180.0)
        var radiusSize = 1.6;
        self.removeAllChildren()
        
        // set background color
        if (sunSwitch == 0) {
            self.backgroundColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1)
            radiusSize = 1.0
        } else {
            self.backgroundColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1)
            radiusSize = 1.6
        }
        
        // draw circles
        for i in 0..<numPoints {
            if (circleProps[i].dir != 0)
            {
                circleProps[i].now = circleProps[i].now + circleProps[i].step
                if (circleProps[i].now > circleProps[i].max) {
                    circleProps[i].dir = 0
                }
            } else {
                circleProps[i].now = circleProps[i].now - circleProps[i].step;
                if (circleProps[i].now < circleProps[i].min) {
                    circleProps[i].dir = 1
                }
            }
            
            let radiusA = circleProps[i].now
            let radiusB = circleProps[i].now / radiusSize
            let sliceSize = 360.0 / CGFloat(slicesTotal)
            let zoom = 1.0
            
            let path = CGMutablePath()
            for slicePoint in 0..<slicesTotal {
                let pointA = (CGFloat(slicePoint) * sliceSize - (sliceSize/2)) * DEG2RAD
                let pointB = (CGFloat(slicePoint) * sliceSize) * DEG2RAD
                let pointC = (CGFloat(slicePoint) * sliceSize + (sliceSize/2)) * DEG2RAD
                
                let p1 = CGPoint(x: circleCenters[i].x + (cos(pointA) * CGFloat(radiusA / zoom)), y: circleCenters[i].y + (sin(pointA) * CGFloat(radiusA / zoom)))
                let p2 = CGPoint(x: circleCenters[i].x + (cos(pointB) * CGFloat(radiusB / zoom)), y: circleCenters[i].y + (sin(pointB) * CGFloat(radiusB / zoom)))
                let p3 = CGPoint(x: circleCenters[i].x + (cos(pointC) * CGFloat(radiusA / zoom)), y: circleCenters[i].y + (sin(pointC) * CGFloat(radiusA / zoom)))
                
                path.move(to: p1)
                path.addLine(to: p2)
                path.addLine(to: p3)
            }
            
            let circle = SKShapeNode(path: path)
            circle.lineWidth = 2.0
            circle.lineJoin = .miter
            if (sunSwitch == 0) {
                circle.strokeColor = thisGray[i]
            } else {
                circle.strokeColor = thisYellow[i]
            }
            self.addChild(circle)
        }
    }
    
    func initValues() {
        sunriseSunsetObj.start()
        for i in 0..<numPoints {
            circleCenters[i].x = self.frame.size.width / 2
            circleCenters[i].y = self.frame.size.height / 2
            
            circleProps[i].max = Double(SSRandomFloatBetween(self.frame.size.height/2, self.frame.size.height))
            circleProps[i].min = Double(SSRandomFloatBetween(0, self.frame.size.height/8))
            circleProps[i].now = Double(SSRandomFloatBetween(CGFloat(circleProps[i].min), CGFloat(circleProps[i].max)))
            circleProps[i].step = Double(SSRandomFloatBetween(0.5, 1.5))
            circleProps[i].dir = 1
            
            circleDirs[i].x = SSRandomFloatBetween(CGFloat(minSpeed),CGFloat(maxSpeed))
            if( SSRandomFloatBetween(2.0,3.0) > 2.5 ) {
                circleDirs[i].x = -circleDirs[i].x
            }
            
            circleDirs[i].y = SSRandomFloatBetween(CGFloat(minSpeed),CGFloat(maxSpeed))
            if( SSRandomFloatBetween(2.0,3.0) > 2.5 ) {
                circleDirs[i].y = -circleDirs[i].y
            }
        }
    }
    
    func setColors() {
        for i in 0..<numPoints {
            let baseYellowColor = SSRandomFloatBetween(0.95, 1.0);
            thisYellow[i] = NSColor.init(red: baseYellowColor, green: baseYellowColor, blue: baseYellowColor - 0.8, alpha: 1)
            
            let baseGrayColor = SSRandomFloatBetween(0.0, 0.3);
            thisGray[i] = NSColor.init(red: baseGrayColor + 0.05, green: baseGrayColor, blue: baseGrayColor, alpha: 1)
        }
    }
}
