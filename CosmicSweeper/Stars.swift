//
//  Stars.swift
//  CosmicSweeper
//
//  Created by A.Lichkov on 2016-07-04.
//  Copyright © 2016 A.Lichkov. All rights reserved.
//

import UIKit
import SpriteKit

class Stars: SKNode {
    override init() {
       super.init()
        let update = SKAction.run { () -> () in
            if arc4random_uniform(10) < 3 {
                self.createStars()
            }
        }
        
        let delay = SKAction.wait(forDuration: 0.05)
        let updateLoop = SKAction.sequence([delay, update])
        self.run(SKAction.repeatForever(updateLoop))
    }
    
    func createStars() {
        let randomX: CGFloat = CGFloat(arc4random_uniform(UInt32((self.scene?.size.width)!)))
        let randomY: CGFloat = (self.scene?.size.height)!
        
        let randomStart:CGPoint = CGPoint(x: randomX, y: randomY)
        
        let star = SKSpriteNode(imageNamed: "star.png")
        star.position = randomStart
        star.size = CGSize(width: 8, height: 16)
        star.alpha = 0.1 + CGFloat(arc4random_uniform(10)) / 10.0
        self.addChild(star)
        
        let destinationY: CGFloat = -(self.scene?.size.height)! - (self.scene?.size.height)!
        
        let duration: TimeInterval = TimeInterval (0.1 + CGFloat(arc4random_uniform(10)) / 2.0)
        
        let move = SKAction.moveBy(x: 0, y: destinationY, duration: duration)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move, remove])
        
        star.run(sequence)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    
    }

}
