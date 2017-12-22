//
//  IntroScene.swift
//  CosmicSweeper
//
//  Created by Allyx Fusion on 2016-07-04.
//  Copyright © 2016 Allyx Fusion. All rights reserved.
//

import UIKit
import SpriteKit

class IntroScene: SKScene {
    
    var playScene: GameScene?
    
   override func didMove(to view: SKView) {

        let starsBackground: Stars = Stars()
        starsBackground.zPosition = -1
        self.addChild(starsBackground)
    
        getHighscore()
    


    }
    
    func getHighscore() {
        let hScore = childNode(withName: "highestScoreLabel") as! SKLabelNode
        
        if UserDefaults.standard.object(forKey: "CosmicSweeperHighScore") == nil {
            hScore.text = "Highest score: 0"
        }
        else {
            let userScore = UserDefaults.standard.object(forKey: "CosmicSweeperHighScore")! as! String
            hScore.text = "Highest score: \(userScore)"
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         playScene = GameScene(fileNamed: "GameScene")
        let transition = SKTransition.doorsOpenHorizontal(withDuration: 1.0)
        
        
        self.view!.ignoresSiblingOrder = true
        playScene!.scaleMode = .aspectFill
        
        self.view?.presentScene(playScene!, transition: transition)
        playScene = nil

    }
    
}
