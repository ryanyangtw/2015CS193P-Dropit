//
//  DropitViewController.swift
//  Dropit
//
//  Created by Ryan on 2015/4/28.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit

class DropitViewController: UIViewController, UIDynamicAnimatorDelegate {

  @IBOutlet weak var gameView: BezierPathsView!
  
  
  
  // You cannot access your own properties and method until you're fully initialized
  // 1. make it optional and initialize in viewDidLoad
  // 2. lazy variable
  lazy var animator: UIDynamicAnimator = {
    let lazilyCreatedDynamicAnimator =  UIDynamicAnimator(referenceView: self.gameView)
    lazilyCreatedDynamicAnimator.delegate = self
    return lazilyCreatedDynamicAnimator
  }()
  
  var dropitBehavior = DropitBehavior()
  var attachment: UIAttachmentBehavior? {
    willSet {
      animator.removeBehavior(attachment)
      gameView.setPath(nil, named: PathNames.Attachment)
    }
    didSet {
      if attachment != nil {
        animator.addBehavior(attachment)
        attachment?.action = { [unowned self] in
          if let attachedView = self.attachment?.items.first as? UIView {
            let path = UIBezierPath()
            path.moveToPoint(self.attachment!.anchorPoint)
            path.addLineToPoint(attachedView.center)
            self.gameView.setPath(path, named: PathNames.Attachment)
          }
        }
      }
    }
  }

  
  var dropsPerRow = 10
  
  var dropSize: CGSize {
    let size = gameView.bounds.size.width / CGFloat(dropsPerRow)
    return CGSize(width: size, height: size)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    animator.addBehavior(dropitBehavior)
  }
  
  struct PathNames {
    static let MiddleBarrier = "Middle Barrier"
    static let Attachment = "Attachment"
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let barrierSize = dropSize
    let barrierOrigin = CGPoint(x: gameView.bounds.midX - barrierSize.width/2, y: gameView.bounds.midY - barrierSize.height/2)
    let path = UIBezierPath(ovalInRect: CGRect(origin: barrierOrigin, size: barrierSize))
    dropitBehavior.addBarrier(path, named: PathNames.MiddleBarrier)
    
    // Every time when viewDidLayoutSubViews called, gameView will redraw the path
    gameView.setPath(path, named: PathNames.MiddleBarrier)
  }

  @IBAction func drop(sender: UITapGestureRecognizer) {
    drop()
  }

  @IBAction func grapDrop(sender: UIPanGestureRecognizer) {
    let gesturePoint = sender.locationInView(gameView)
    
    switch sender.state {
    case .Began:
      if let viewToAttachTo = lastDroppedView {
        attachment = UIAttachmentBehavior(item: viewToAttachTo, attachedToAnchor: gesturePoint)
        
        lastDroppedView = nil
      }
    case .Changed:
      attachment?.anchorPoint = gesturePoint
    case .Ended:
      attachment = nil
    default: break

    }
  }
  
  
  var lastDroppedView: UIView?
  
  func drop() {
    var frame = CGRect(origin: CGPointZero, size: dropSize)
    frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
    
    let dropView = UIView(frame: frame)
    dropView.backgroundColor = UIColor.random
    
    gameView.addSubview(dropView)
    
    lastDroppedView = dropView
    
    dropitBehavior.addDrop(dropView)
  }
  
  // removes a single, completed row
  // allows for a little "wiggle room" for mostly complete rows
  // in the end, does nothing more than call removeDrop in DropitBehavior
  func removeCompletedRow() {
    var dropsToRemove = [UIView]()
    var dropFrame = CGRect(x: 0, y: gameView.frame.maxY, width: dropSize.width, height: dropSize.height)
    
    do {
      dropFrame.origin.y -= dropSize.height
      dropFrame.origin.x = 0
      var dropsFound = [UIView]()
      var rowIsComplete = true
      for _ in 0 ..< dropsPerRow {
        if let hitView = gameView.hitTest(CGPoint(x: dropFrame.midX, y: dropFrame.midY), withEvent: nil) {
          if hitView.superview == gameView {
            dropsFound.append(hitView)
          } else {
            rowIsComplete = false
          }
        }
        dropFrame.origin.x += dropSize.width
      }
      if rowIsComplete {
        dropsToRemove += dropsFound
      }
    } while dropsToRemove.count == 0 && dropFrame.origin.y > 0
    
    for drop in dropsToRemove {
      dropitBehavior.removeDrop(drop)
    }
  }

  //MARK: - UIDynamicAnimator Dlegate
  
  // This mehod will be called when the animation stop
  func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
    removeCompletedRow()
  }
  
  
  
}


private extension CGFloat {
  static func random(max: Int) -> CGFloat {
    return CGFloat(arc4random() % UInt32(max))
  }

}

private extension UIColor {
  class var random: UIColor {
    switch arc4random()%5 {
    case 0: return UIColor.greenColor()
    case 1: return UIColor.blueColor()
    case 2: return UIColor.orangeColor()
    case 3: return UIColor.redColor()
    case 4: return UIColor.purpleColor()
    case 5: return UIColor.purpleColor()
    default: return UIColor.blackColor()
    }
  }
}



