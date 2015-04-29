//
//  BazierPathsView.swift
//  Dropit
//
//  Created by Ryan on 2015/4/29.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class BezierPathsView: UIView {

  private var bezierPaths = [String: UIBezierPath]()
  
  func setPath(path: UIBezierPath?, named name: String) {
    bezierPaths[name] = path
    setNeedsDisplay()
  }
  
  override func drawRect(rect: CGRect) {
    for (_, path) in bezierPaths {
      path.stroke()
    }
  }

}
