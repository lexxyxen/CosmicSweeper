//
//  Game.swift
//  CosmicSweeper
//
//  Created by Allyx Fusion on 2016-07-26.
//  Copyright © 2016 Aleksandar Lichkov. All rights reserved.
//

import SpriteKit
class Game: SKNode {

    
    var scoreLabel: SKLabelNode
    var timerLabel: SKLabelNode
    var spaceship: SKSpriteNode

    
    // scene variable 
    
    var gameScene: SKScene
    
    var touchInProgress: Bool
    var lastUpdateTime: TimeInterval
    var lastTouch: CGPoint?
    var spaceshipTouch: UITouch
    
    var fireRate: CGFloat
    var lastFireTime: TimeInterval
    
    var playingInProgress: Bool
    
    var spaceshipExplodeTemplate: SKEmitterNode
    var meteoroidExplodeTemplate: SKEmitterNode

    var shotingSound: SKAction
    var exploadeSound: SKAction
    
    var doubleFire: Bool
    var gameOver: Bool
    var gameScore:Int
    
     init (gameScene: SKScene) {
        
        self.scoreLabel = SKLabelNode()
        self.timerLabel = SKLabelNode()
        self.spaceship = SKSpriteNode()

        self.gameScene = gameScene
    
        self.touchInProgress = false
        self.lastFireTime = TimeInterval()
        self.lastUpdateTime = TimeInterval()
        self.spaceshipTouch = UITouch()
        // set the fire rate for the bullet
        self.fireRate = 0.25
        self.lastUpdateTime = TimeInterval()
        
        // set the game playing to true
        self.playingInProgress = true
        self.spaceshipExplodeTemplate = SKEmitterNode()
        self.meteoroidExplodeTemplate = SKEmitterNode()
        self.shotingSound = SKAction()
        self.exploadeSound = SKAction()
        self.gameOver = false
        self.doubleFire = false
        self.gameScore = 0
        super.init()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Class methods
    
    
    
    // ===================== Check for Coalitions ===========================================
    func checkForCoalisions() {
        
        
        self.gameScene.enumerateChildNodes(withName: "meteoride") { (meteoride: SKNode, stop: UnsafeMutablePointer<ObjCBool>) -> () in
            
            if self.spaceship.intersects(meteoride) {
                
                let explosion: SKEmitterNode = self.spaceshipExplodeTemplate.copy() as! SKEmitterNode
                explosion.position = self.spaceship.position
                
                self.gameScene.addChild(explosion)
                
                
                self.spaceship.removeFromParent()
                self.playingInProgress = false
                
                let firstWait = SKAction.wait(forDuration: 0.1)
                let stop = SKAction.run({ () -> () in
                    explosion.particleBirthRate = 0
                })
                
                let secondWait = SKAction.wait(forDuration: TimeInterval(explosion.particleLifetime))
                let remove = SKAction.removeFromParent()
                let die = SKAction.sequence([firstWait, stop, secondWait, remove])
                explosion.run(die)
                
                self.gameScene.run(self.exploadeSound)
                
                self.exitGame()
            }
            self.gameScene.enumerateChildNodes(withName: "bullet", using: { (bullet: SKNode, stop: UnsafeMutablePointer<ObjCBool>) -> () in
                
                if bullet.intersects(meteoride) {
                    
                    let explosion: SKEmitterNode = self.meteoroidExplodeTemplate.copy() as! SKEmitterNode
                    explosion.position = meteoride.position
                    
                    self.gameScene.addChild(explosion)
                    
                    bullet.removeFromParent()
                    meteoride.removeFromParent()
                    
                    let firstWait = SKAction.wait(forDuration: 0.1)
                    let stop = SKAction.run({ () -> () in
                        explosion.particleBirthRate = 0
                    })
                    
                    let secondWait = SKAction.wait(forDuration: TimeInterval(explosion.particleLifetime))
                    let remove = SKAction.removeFromParent()
                    let die = SKAction.sequence([firstWait, stop, secondWait, remove])
                    explosion.run(die)
                    
                    self.gameScene.run(self.exploadeSound)
                    
                    self.gameScore += 10
                    self.scoreLabel.text = "Score: \(self.gameScore)"
                    
                    
                }
                
            })
            
            self.gameScene.enumerateChildNodes(withName: "star_white") { (star: SKNode, stop: UnsafeMutablePointer<ObjCBool>) -> () in
                
                if self.spaceship.intersects(star) {
                    
                                  //   self.showDoubleFireTimer(5)
                                        self.doubleFire = true
                    star.removeFromParent()
                    let remove = SKAction.run({ () -> () in
                        self.doubleFire = false
                  star.removeFromParent()
                    
                    })
                    let delay = SKAction.wait(forDuration: 6)
                                       // let delayAndRemoveDoubleFire = SKAction.sequence([delay, remove])
                    
                    //let removeSecond = SKAction.removeFromParent()
                    
                    let delayAndRemoveDoubleFire = SKAction.sequence([delay, remove])
                    self.spaceship.run(delayAndRemoveDoubleFire)
//                     self.spaceship.removeActionForKey("delayAndRemoveDoubleFire")
//                    self.spaceship.runAction(delayAndRemoveDoubleFire, withKey: "delayAndRemoveDoubleFire")
                    
                                        
                                        
                    }
     
                }
        }
    }
    
    
    // ===========   ends the game ====================
    func exitGame() {
        self.gameOver = true
        
        self.createGameSceneLabels()
        self.saveUserScore()
        
    }
    // =================== Creates the labels for the game scene ===========
    
    func createGameSceneLabels () {
        let labelGameOver = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        labelGameOver.fontSize = 30
        labelGameOver.fontColor = SKColor.white
        labelGameOver.text = "Game Over"
        labelGameOver.position = CGPoint(x: self.gameScene.frame.midX, y: self.gameScene.frame.midY)
        
        self.gameScene.addChild(labelGameOver)
        
        let labelInstruction = SKLabelNode(fontNamed: "AvenirNext-Medium")
        labelInstruction.fontSize = 15
        labelInstruction.fontColor = SKColor.gray
        labelInstruction.text = "Tap to begin the game again!"
        labelInstruction.position = CGPoint(x: self.gameScene.frame.midX, y: self.gameScene.frame.midY - 100 )
        self.gameScene.addChild(labelInstruction)
        
        let animation = SKAction(named: "fadeAnimation")!
        labelInstruction.run(SKAction.repeatForever(animation))
    }
    
    // ===================== Save user score ===============================
    
    func saveUserScore () {
        if UserDefaults.standard.object(forKey: "CosmicSweeperHighScore") == nil {
            UserDefaults.standard.set("\(self.gameScore)", forKey: "CosmicSweeperHighScore")
            UserDefaults.standard.synchronize()
        }
        else {
            let getPlayerHighScore: String = UserDefaults.standard.value(forKey: "CosmicSweeperHighScore")! as! String
            let highScore: Int? = Int (getPlayerHighScore)
            
            if self.gameScore > highScore! {
                UserDefaults.standard.setValue("\(self.gameScore)", forKey: "CosmicSweeperHighScore")
                UserDefaults.standard.synchronize()
                
            }
        }

    }
    
    //===================== fire from spaceship ===========================
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet.png")
        
        bullet.name = "bullet"
        bullet.size = CGSize(width: 6, height: 13)
        bullet.position = CGPoint(x: self.spaceship.position.x, y: self.spaceship.position.y
            + self.spaceship.frame.size.height / 2)
        
        self.gameScene.addChild(bullet)
        
        let move = SKAction.moveBy(x: 0, y: self.gameScene.size.height + bullet.size.height, duration: 0.5)
        
        let remove = SKAction.removeFromParent()
        
        let fireAndRemove = SKAction.sequence([move, remove])
        
        bullet.run(fireAndRemove)
        self.gameScene.run(self.shotingSound)
        
    }
    
    //===================== double fire from spaceship ===========================
    func doubleFireBullet() {
        //left fire
        let leftFire = SKSpriteNode(imageNamed: "bullet.png")
        leftFire.name = "bullet"
        leftFire.size = CGSize(width: 6, height: 13)
        leftFire.position = CGPoint(x: self.spaceship.position.x - 20, y: self.spaceship.position.y
            + self.spaceship.frame.size.height / 2 - 35)
        self.gameScene.addChild(leftFire)
        
        let move = SKAction.moveBy(x: 0, y: self.gameScene.size.height + leftFire.size.height, duration: 0.5)
        
        let remove = SKAction.removeFromParent()
        
        let fireAndRemove = SKAction.sequence([move, remove])
        
        leftFire.run(fireAndRemove)

        //right fire
        let rightFire = SKSpriteNode(imageNamed: "bullet.png")
        rightFire.name = "bullet"
        rightFire.size = CGSize(width: 6, height: 13)
        rightFire.position = CGPoint(x: self.spaceship.position.x + 20, y: self.spaceship.position.y
            + self.spaceship.frame.size.height / 2 - 35)
        self.gameScene.addChild(rightFire)
        
        
        rightFire.run(fireAndRemove)


    
    }
    //================== Show Double Fire Timer ===================================

//    func showDoubleFireTimer(duration: NSTimeInterval) {
//        let formatter = NSNumberFormatter()
//        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
//        formatter.minimumFractionDigits = 1
//        formatter.minimumFractionDigits = 1
//        
//        let begin: NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
//        
//        let timeCalc = SKAction.runBlock { () -> () in
//            let timeElapsed: NSTimeInterval = NSDate.timeIntervalSinceReferenceDate() - begin
//            var leftTime: NSTimeInterval = duration - timeElapsed
//            
//            if leftTime < 0 {
//                leftTime = 0
//            }
//            self.timerLabel.hidden = false
//
//            self.timerLabel.text = "\(formatter.stringFromNumber(leftTime)!)s"
//        
//        }
//        let pause = SKAction.waitForDuration(0.05)
//        let sequence = SKAction.sequence([timeCalc, pause])
//        let beginCountDown = SKAction.repeatActionForever(sequence)
//        
//        let stopCalc = SKAction.runBlock { () -> () in
//            self.timerLabel.hidden = true
//        }
//        
//        let wait = SKAction.waitForDuration(duration)
//        
//        let display = SKAction.sequence([wait, stopCalc])
//        self.timerLabel.runAction(SKAction.group([beginCountDown, display]))
//    }
    
    //================== Move Spaceship =====================================
    func moveSpaceship(_ point: CGPoint, delta: TimeInterval){
        let movingSpeed:CGFloat = 180
        let distanceLeft:CGFloat = sqrt(pow(self.spaceship.position.x - point.x, 2) +
            pow(self.spaceship.position.y - point.y, 2))
        
        if distanceLeft > 4 {
            // Getting the needed distance to where the spaceship needs to be moved
            let travelingDistance: CGFloat = CGFloat(delta) * movingSpeed
            let angle = atan2(point.y - self.spaceship.position.y, point.x - self.spaceship.position.x)
            
            let yOffset = travelingDistance * sin(angle)
            let xOffset = travelingDistance * cos(angle)
            
            self.spaceship.position = CGPoint(x: self.spaceship.position.x + xOffset, y: self.spaceship.position.y + yOffset)
            
        }
        
        
    }
    
    //================= Spawn Objects =======================================
    
    func moveGameObjects () {
        let randNum: UInt32 = arc4random_uniform(100)
        
        if randNum < 3 {
            moveMeteorides(3)
        }
        else if randNum < 10 {
            moveFiringPowerObjects()

        }
        else if randNum < 15 {
            moveMeteorides(1)
        }
        else if randNum < 25{
            moveMeteorides(2)
        }
        else {
            moveMeteorides(3)

        }
        
    }
    
    //================= Spawn Meteorides =====================================
    func moveMeteorides(_ meteorideType: Int) {
        
        var imageDesc: String = ""
       
       
        // let meteorideSize: CGFloat = 15 + CGFloat(arc4random_uniform(50))
        if meteorideType == 1 {
            imageDesc = "meteoride1.png"

        }
        else if meteorideType == 2 {
            imageDesc = "meteoride2.png"

        }
        else {
            imageDesc = "meteoride.png"

        }
        
        
         let meteoride = SKSpriteNode(imageNamed: imageDesc)
              let startX: CGFloat = CGFloat (arc4random_uniform(UInt32(self.gameScene.size.width) - 40)) + 20
        let startY: CGFloat = self.gameScene.size.height + meteoride.size.height
        meteoride.position = CGPoint(x: startX, y: startY)
        
        meteoride.name="meteoride"
        
        if meteorideType == 1 {
            meteoride.size = CGSize(width: 60, height: 60)
            
        }
        else if meteorideType == 2 {
            meteoride.size = CGSize(width: 30, height: 40)
            
        }
        else {
            meteoride.size = CGSize(width: 70, height: 80)
            
        }
        
        

        
        self.gameScene.addChild(meteoride)
        
        let endX: CGFloat = CGFloat (arc4random_uniform(UInt32(self.gameScene.size.width) - 40)) + 20
        
        let endY: CGFloat = -meteoride.size.height
        
        let flyingDrutation = TimeInterval(arc4random_uniform(1) + 5)
        let fly = SKAction.move(to: CGPoint(x: endX, y: endY), duration: flyingDrutation)
        let remove = SKAction.removeFromParent()
        let flyThenRemove = SKAction.sequence([fly, remove])
        
        meteoride.run(flyThenRemove)
    }

    //================= Spawn FirringPowerObjects =====================================
    func moveFiringPowerObjects () {
        let starSize: CGFloat = 30
        let startX: CGFloat = CGFloat (arc4random_uniform(UInt32(self.gameScene.size.width) - 60)) + starSize
        let startY: CGFloat = self.gameScene.size.height + starSize
        let endY: CGFloat = -starSize
        
        let star: SKSpriteNode = SKSpriteNode(imageNamed: "star_white.png")
        star.name = "star_white"
        star.size = CGSize(width: starSize, height: starSize)
        star.position = CGPoint(x: startX, y: startY)
    
        self.gameScene.addChild(star)
        
        let move = SKAction.move(to: CGPoint(x: startX, y: endY), duration: 6)
        let spin = SKAction.rotate(byAngle: -1, duration: 1)
        let remove = SKAction.removeFromParent()
        
        
        let spinContinous = SKAction.repeatForever(spin)
        let moveAndRemove = SKAction.sequence([move, remove])
        let allAtOnce = SKAction.group([spinContinous, moveAndRemove])
        star.run(allAtOnce)
        
    }

}
