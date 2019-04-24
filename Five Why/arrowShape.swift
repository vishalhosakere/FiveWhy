//
//  arrowShape.swift
//  Five Why
//
//  Created by Vishal Hosakere on 21/04/19.
//  Copyright © 2019 Vishal Hosakere. All rights reserved.
//

import UIKit

class arrowShape: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var path: UIBezierPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.darkGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func createRectangle() {
        // Initialize the path.
        let _start = CGPoint(x: self.center.x - self.frame.height/2, y: 0)
        let _end = CGPoint(x: self.center.x + self.frame.height/2, y: self.frame.height)
        path = UIBezierPath.arrow(from: _start, to: _end, tailWidth: 5, headWidth: 7, headLength: 4)
    }

    
    override func draw(_ rect: CGRect) {
        self.createRectangle()
        
        // Specify the fill color and apply it to the path.
        UIColor.orange.setFill()
        path.fill()
        
        // Specify a border (stroke) color.
        UIColor.purple.setStroke()
        path.stroke()
    }
}
