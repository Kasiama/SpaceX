//
//  GameScene.swift
//  spaceX
//
//  Created by Иван on 07.09.2018.
//  Copyright © 2018 Иван. All rights reserved.
//
import UIKit
import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var sceneScreener: SKScene!
    var sceneSound: SKScene!
    var sceneLevel: SKSpriteNode!
    var score: Int = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
            scoreLabel.zPosition = 0;
        }
    }
    var gameTimer: Timer!
    var aliens = ["alien","alien2","alien3"]
    let alienCategory : UInt32 = 0x1 << 1
     let bulletCategory : UInt32 = 0x1 << 0
    let playerCategory : UInt32 = 0x1<<1
    var hiScore: Int = 0
    
    
    let motionManager = CMMotionManager()
    var xAccelerate : CGFloat = 0
    
    
    
    override func didMove(to view: SKView) {
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 350, y: 1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1;
        
        
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x:350 , y: 100)
        player.setScale(1.5)
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector( dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self;
        
        scoreLabel = SKLabelNode(text: "Score 0")
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 56
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint (x: 150, y: 1200)
        score = 0;
        self.addChild(scoreLabel)
        
        gameTimer=Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector (addAllien), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
        
    }
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 50
        
        if player.position.x < 0{
            player.position = CGPoint(x:  700, y: player.position.y)
        }
        else if player.position.x > 700{
            player.position = CGPoint(x:  0, y: player.position.y)
    }
    }
    
    
     func didBegin( _ contact: SKPhysicsContact) {
        print("contact")
        var alienBody: SKPhysicsBody
        var bulletBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bulletBody = contact.bodyA
            alienBody = contact.bodyB
        }
        else {
            bulletBody = contact.bodyB
            alienBody = contact.bodyA
        }
        
        if (alienBody.categoryBitMask & alienCategory) != 0 && (bulletBody.categoryBitMask & bulletCategory) != 0 {
            collisionElements(bulletNode: bulletBody.node as! SKSpriteNode, alienNode: alienBody.node as! SKSpriteNode)
        }
    }
    
    func collisionElements(bulletNode: SKSpriteNode, alienNode:SKSpriteNode){
        let explotion =  SKEmitterNode(fileNamed: "Vzriv")
        explotion?.position = alienNode.position
        self.addChild(explotion!)
        
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        bulletNode.removeFromParent()
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)){
            explotion?.removeFromParent()
        }
        score += 5
    }
    
    
    
    
    @objc func addAllien(){
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: aliens[0])
        let randomPos = GKRandomDistribution(lowestValue: 0, highestValue: 750)
        let pos = CGFloat(randomPos.nextInt())
        alien.position = CGPoint(x: pos, y: 1300)
        alien.setScale(2)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = bulletCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animDuration :TimeInterval = 6
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: pos, y: -800 ), duration: animDuration) )
        actions.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actions))
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
          fireBullet()
    }
    
    
    func fireBullet() {
        self.run(SKAction.playSoundFileNamed("bullet.mp3", waitForCompletion: false))
         let bullet  = SKSpriteNode(imageNamed:"torpedo" )
        bullet.position = player.position
        bullet.position.y += 5
      //  print("fire")
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width/2 )
        bullet.physicsBody?.isDynamic = true
        
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = alienCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
       // bullet.blendMode.rawValue = 10;
        
        
        self.addChild(bullet)
        
        let animDuration :TimeInterval = 0.3
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: 900 ), duration: animDuration) )
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))
        
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
