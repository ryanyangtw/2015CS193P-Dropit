//
//  DropitBehavior.swift
//  Dropit
//
//  Created by Ryan on 2015/4/28.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class DropitBehavior: UIDynamicBehavior {
  
  let gravity = UIGravityBehavior()
  
  // I want to initizlize some state, So I use lazy variables
  lazy var collider: UICollisionBehavior = {
    let lazilyCreatedCollider = UICollisionBehavior()
    lazilyCreatedCollider.translatesReferenceBoundsIntoBoundary = true // The edges of my reference view are going to be a boundary
    return lazilyCreatedCollider
  }()
  
  lazy var dropBehavior: UIDynamicItemBehavior = {
    let lazilyCreatedDropBehavior = UIDynamicItemBehavior()
    lazilyCreatedDropBehavior.allowsRotation = true
    lazilyCreatedDropBehavior.elasticity = 0.75 // 1 means perfect elastic
    return lazilyCreatedDropBehavior
  }()
  
  override init() {
    super.init()
    addChildBehavior(gravity)
    addChildBehavior(collider)
    addChildBehavior(dropBehavior)
  }
  
  func addDrop(drop: UIView) {
    dynamicAnimator?.referenceView?.addSubview(drop)
    gravity.addItem(drop)
    collider.addItem(drop)
    dropBehavior.addItem(drop)
  }
  
  func removeDrop(drop: UIView) {
    gravity.removeItem(drop)
    collider.removeItem(drop)
    drop.removeFromSuperview()
  }
  
  
  func addBarrier(path: UIBezierPath, named name: String) {
    collider.removeBoundaryWithIdentifier(name)
    collider.addBoundaryWithIdentifier(name, forPath: path)
  }
  
  
   
}
