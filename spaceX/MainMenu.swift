//
//  MainMenu.swift
//  spaceX
//
//  Created by Иван on 10.09.2018.
//  Copyright © 2018 Иван. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    var starfield: SKEmitterNode!
    
    var newGameBtnNode : SKSpriteNode!
    var levelBtnNode : SKSpriteNode!
    var labelLevelNode : SKLabelNode!
    
    override func didMove(to view: SKView) {
        starfield = self.childNode(withName: "starfieldAnim") as! SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        
        newGameBtnNode = self.childNode(withName: "newGameBtn") as! SKSpriteNode
        newGameBtnNode.texture = SKTexture(imageNamed: "swift_newGameBtn")
        
        levelBtnNode = self.childNode(withName: "newLevelBtn") as? SKSpriteNode
        levelBtnNode.texture = SKTexture(imageNamed: "swift_levelBtn")
        
        labelLevelNode = self.childNode(withName: "labelLevelBtn") as? SKLabelNode
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "newGameBtn"{
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene,transition: transition)
            }
        }
        
    }

}
