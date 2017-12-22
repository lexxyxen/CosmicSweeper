//
//  GameScene.swift
//  CosmicSweeper
//
//  Created by A.Lichkov on 2016-07-04.
//  Copyright (c) 2016 A.Lichkov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
 
    var game: Game?
    var introScene: IntroScene?

    
    override func didMove(to view: SKView) {
        // instantiating the game class
        game = Game(gameScene: self)

        let starsBackground: Stars = Stars()
        starsBackground.zPosition = -1
        self.addChild(starsBackground)
        
        // hide double fire timer label
        
        game!.timerLabel = childNode(withName: "labelDoublePower") as! SKLabelNode
        game!.timerLabel.isHidden = true
        
       // spaceship node
        game!.spaceship = childNode(withName: "mainship") as! SKSpriteNode
        
        // assigning explosions
        game!.meteoroidExplodeTemplate = SKEmitterNode(fileNamed: "Explode.sks")!
        game!.spaceshipExplodeTemplate = SKEmitterNode(fileNamed: "SpaceshipExplode.sks")!
        
        // assigning score label
        game!.scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        
      
        // Assigning sound variables
        game!.shotingSound = SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false)
        game!.exploadeSound = SKAction.playSoundFileNamed("boom.wav", waitForCompletion: false)
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        game!.touchInProgress = true
        game!.spaceshipTouch = touches.first!
        
        // if the game is over trasition back to the intro scene when user taps the screen
        if game!.gameOver == true {
             introScene = IntroScene(fileNamed: "IntroScene")
            let transition = SKTransition.doorsCloseHorizontal(withDuration: 1.0)
            self.view!.ignoresSiblingOrder = true
            introScene!.scaleMode = .aspectFill
            
            self.view?.presentScene(introScene!, transition: transition)
            
            introScene = nil

        }
    }
    
   
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        game!.touchInProgress = false
    }
    
    let xPlayerForce = 20
    let yPlayerForce = 30

    
    override func update(_ currentTime: TimeInterval) {
       
        
        if game!.lastUpdateTime == 0 {
            game!.lastUpdateTime = currentTime
        }
        let delta: TimeInterval = currentTime - game!.lastUpdateTime
        
        if game!.touchInProgress == true {
            var touchedLocation: CGPoint = game!.spaceshipTouch.location(in: self)
            touchedLocation.y = touchedLocation.y + 30
            game!.moveSpaceship(touchedLocation, delta: delta)
            if game!.playingInProgress == true && CGFloat(currentTime - game!.lastFireTime) > game!.fireRate {
                
                game!.fireBullet()
                
                if game!.doubleFire == true {
                    game!.doubleFireBullet()
                }
                
                game!.lastFireTime = currentTime
            }
            
            if game!.playingInProgress == true {
                let spawnFrequency: UInt32 = 20
                if arc4random_uniform(1000) <= spawnFrequency {
                    game!.moveGameObjects()
                }
            }
            

        }
        
              game!.checkForCoalisions()
        
        game!.lastUpdateTime = currentTime
    }

        
}
