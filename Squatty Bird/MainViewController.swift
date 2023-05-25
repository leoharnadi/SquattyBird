//
//  MainViewController.swift
//  Testing AR
//
//  Created by Leo Harnadi on 22/05/23.
//

import UIKit
import ARKit
import SceneKit

class MainViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var scoreUI: UILabel!
    @IBOutlet weak var scoreUIBackground: UILabel!
    @IBOutlet weak var tutorialImage: UIImageView!
    @IBOutlet weak var tutorialMessage: UILabel!
    
    weak var delegate: MainViewControllerDelegate?
    
    var scene: SCNScene!
    
    var collisionNode: SCNNode!
    var upperNode: SCNNode!
    var lowerNode: SCNNode!
    var scoringNode: SCNNode!
    var upperHeadNode: SCNNode!
    var lowerHeadNode: SCNNode!
    
    var spawnTimer: Timer?
    var scoreTimer: Timer?
    
    var tutorialClicked: Bool = false
    
    var isLose: Bool!
    
    var scoreLocal: Int = 0 {
        didSet {
            // ensure UI update runs on main thread
            DispatchQueue.main.async {
                self.scoreUI.text = String(self.scoreLocal)
                self.scoreUIBackground.text = String(self.scoreLocal)
            }
        }
    }
    
    var overlayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Scene lighting
        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        scene = SCNScene()
        
        
        // Collision node
        let collision = SCNSphere(radius: 0.0001)
        collision.firstMaterial?.diffuse.contents = UIColor.blue
        collisionNode = SCNNode(geometry: collision)
        collisionNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: collision))
        collisionNode.physicsBody?.isAffectedByGravity = false
        collisionNode.physicsBody?.categoryBitMask = 5
        collisionNode.physicsBody?.contactTestBitMask = 4
        collisionNode.physicsBody?.collisionBitMask = 4
        scene.rootNode.addChildNode(collisionNode)
        
        // Score UI
        scoreUI.font = UIFont(name: foregroundFont, size: 75)
        scoreUI.attributedText = NSAttributedString(string: "0", attributes: [.strokeWidth: 0, .strokeColor: UIColor.white])
        scoreUIBackground.font = UIFont(name: backgroundFont, size: 75)
        scoreUIBackground.textColor = UIColor.white
        scoreUIBackground.attributedText = NSAttributedString(string: "0", attributes: [.strokeWidth: 0, .strokeColor: UIColor.white])
        scoreUI.isHidden = true
        scoreUIBackground.isHidden = true
        
        
        // Scene Physics
        scene.physicsWorld.contactDelegate = self
        
        sceneView.scene = scene
        
        // tutorial overlay
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        tutorialMessage.text = "Squat up and down\nwhile holding your phone.\n\n\n\nTap the screen\n to continue."
        tutorialMessage.font = UIFont(name: foregroundFont, size: 30)
        tutorialMessage.textColor = UIColor.white
        
        view.addSubview(overlayView)
        view.bringSubviewToFront(overlayView)
        view.bringSubviewToFront(tutorialImage)
        view.bringSubviewToFront(tutorialMessage)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        overlayView.addGestureRecognizer(tapGesture)
        
        // for sound
        isLose = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let frame = sceneView.session.currentFrame else {
            return
        }
        
        let cameraTransform = frame.camera.transform
        let cameraPosition = SCNVector3(cameraTransform.columns.3.x,
                                        cameraTransform.columns.3.y,
                                        cameraTransform.columns.3.z)
        
        
        collisionNode.position = SCNVector3(cameraPosition.x, cameraPosition.y, cameraPosition.z)
        
        if tutorialClicked {
            moveAction(node: upperNode, cameraPos: cameraPosition)
            moveAction(node: lowerNode, cameraPos: cameraPosition)
            moveAction(node: scoringNode, cameraPos: cameraPosition)
            moveAction(node: upperHeadNode, cameraPos: cameraPosition)
            moveAction(node: lowerHeadNode, cameraPos: cameraPosition)
        }
    }
    
    func moveAction(node: SCNNode, cameraPos: SCNVector3) {
        let move = SCNAction.move(to: SCNVector3(cameraPos.x, node.position.y, cameraPos.z + 1), duration: 5)
        
        node.runAction(move)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            node.removeFromParentNode()
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
//        print(nodeA)
        
        if ((nodeA == collisionNode && nodeB.physicsBody?.categoryBitMask == 4) || (nodeB == collisionNode && nodeA.physicsBody?.categoryBitMask == 4)) {
            
            audioPlayer.playMenu()
            audioPlayer.playThud()
            
            isLose = true
            
            //haptic
            triggerHapticFeedback(with: createHapticPattern(isLose: isLose))
            
            scoreTimer?.invalidate()
            spawnTimer?.invalidate()
            nodeA.removeFromParentNode()
            nodeB.removeFromParentNode()
            
            score = scoreLocal
            
            if score > highScore {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: "squattyBirdHighScore")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                self.navigationController?.popViewController(animated: false)
                self.delegate?.mainViewControllerDidUpdateScore(score: score, highScore: highScore)
                
            }
        } else if ((nodeA == collisionNode && nodeB.physicsBody?.categoryBitMask == 2) || (nodeB == scoringNode && nodeA.physicsBody?.categoryBitMask == 2)){
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                if !self.isLose {
                    audioPlayer.playScore()
                }
                
            }
            
            triggerHapticFeedback(with: createHapticPattern(isLose: isLose))
            
            scoreLocal += 1
//            print("Score: \(score)")
            if nodeA == collisionNode {
                nodeB.removeFromParentNode()
            } else {
                nodeA.removeFromParentNode()
            }
            
        }
    }
    
    func spawnObjects(gapHeight: Float, verticalOffset: Float) {
        let wallHeight: Float = 2
        let wallWidth: CGFloat = 0.5
        let wallLength: CGFloat = 0.1
        let headHeight: CGFloat = 0.2
        let headWidth: CGFloat = 0.7
        let headLength: CGFloat = 0.3
        
        ///borders
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor(named: "lightGreen")
        let borderMaterial = SCNMaterial()
        borderMaterial.diffuse.contents = UIColor.black
        let borderThickness = 0.02
        
        // front box
        let frontBorderGeometry = SCNPlane(width: wallWidth + borderThickness * 2, height: CGFloat(wallHeight) + borderThickness * 2 - 0.02)
        frontBorderGeometry.firstMaterial = borderMaterial

        let frontBorderNode = SCNNode(geometry: frontBorderGeometry)
        let frontBorderNode2 = SCNNode(geometry: frontBorderGeometry)

        frontBorderNode.position.z = Float(wallLength / 2) - 0.01
        frontBorderNode.position.y = 0.02
        frontBorderNode2.position.z = Float(wallLength / 2) - 0.01
        frontBorderNode2.position.y = -0.02
        
        // front head
        let frontBorderHeadGeometry = SCNPlane(width: headWidth + borderThickness * 2, height: CGFloat(headHeight) + borderThickness * 2)
        frontBorderHeadGeometry.firstMaterial = borderMaterial

        let frontBorderHeadNode = SCNNode(geometry: frontBorderHeadGeometry)
        let frontBorderHeadNode2 = SCNNode(geometry: frontBorderHeadGeometry)

        frontBorderHeadNode.position.z = Float(headLength / 2) - 0.01
        frontBorderHeadNode2.position.z = Float(headLength / 2) - 0.01
        
        
        // Create upper object
        let upperObject = SCNBox(width: wallWidth, height: CGFloat(wallHeight), length: wallLength, chamferRadius: 0)
        upperObject.firstMaterial = boxMaterial
        
        upperNode = SCNNode(geometry: upperObject)
        upperNode.position = SCNVector3(0, wallHeight / 2 + gapHeight / 2 + verticalOffset, -4)
        upperNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry:
                                                                                        SCNBox(width: 15, height: CGFloat(wallHeight), length: wallLength, chamferRadius: 0)))
        upperNode.physicsBody?.isAffectedByGravity = false
        upperNode.physicsBody?.categoryBitMask = 4
        upperNode.physicsBody?.contactTestBitMask = 5
        upperNode.physicsBody?.collisionBitMask = 0
        
        upperNode.addChildNode(frontBorderNode)
        scene.rootNode.addChildNode(upperNode)
        
        let upperHead = SCNBox(width: headWidth, height: headHeight, length: headLength, chamferRadius: 0)
        upperHead.firstMaterial?.diffuse.contents = UIColor(named: "lightGreen")
        upperHeadNode = SCNNode(geometry: upperHead)
        upperHeadNode.position = SCNVector3(0, Float(headHeight)/2 + gapHeight/2 + verticalOffset, -4 )
        
        upperHeadNode.addChildNode(frontBorderHeadNode)
        scene.rootNode.addChildNode(upperHeadNode)
        
        // Create lower object
        let lowerObject = SCNBox(width: wallWidth, height: CGFloat(wallHeight), length: wallLength, chamferRadius: 0)
        lowerObject.firstMaterial?.diffuse.contents = UIColor(named: "lightGreen")
        lowerNode = SCNNode(geometry: lowerObject)
        lowerNode.position = SCNVector3(0, -wallHeight / 2 - gapHeight / 2 + verticalOffset, -4)
        lowerNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry:
                                                                                        SCNBox(width: 15, height: CGFloat(wallHeight), length: wallLength, chamferRadius: 0)))
        lowerNode.physicsBody?.isAffectedByGravity = false
        lowerNode.physicsBody?.categoryBitMask = 4
        lowerNode.physicsBody?.contactTestBitMask = 5
        lowerNode.physicsBody?.collisionBitMask = 0
        
        lowerNode.addChildNode(frontBorderNode2)
        scene.rootNode.addChildNode(lowerNode)
        
        let lowerHead = SCNBox(width: headWidth, height: headHeight, length: headLength, chamferRadius: 0)
        lowerHead.firstMaterial?.diffuse.contents = UIColor(named: "lightGreen")
        lowerHeadNode = SCNNode(geometry: lowerHead)
        lowerHeadNode.position = SCNVector3(0, -Float(headHeight)/2 - gapHeight/2 + verticalOffset, -4 )
        
        lowerHeadNode.addChildNode(frontBorderHeadNode2)
        scene.rootNode.addChildNode(lowerHeadNode)
        
        let scoringObject = SCNBox(width: 0.5, height: 0.5, length: wallLength, chamferRadius: 0)
        scoringObject.firstMaterial?.diffuse.contents = UIColor.clear
        scoringNode = SCNNode(geometry: scoringObject)
        let scoringPositionY = (upperNode.position.y + lowerNode.position.y) / 2
        scoringNode.position = SCNVector3(0, scoringPositionY, -4)
        scoringNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry:
                                                                                            SCNBox(width: 15, height: CGFloat(0.5), length: wallLength, chamferRadius: 0)))
        scoringNode.physicsBody?.isAffectedByGravity = false
        scoringNode.physicsBody?.categoryBitMask = 2
        scoringNode.physicsBody?.contactTestBitMask = 5
        scoringNode.physicsBody?.collisionBitMask = 0 // No collision with other nodes
        scene.rootNode.addChildNode(scoringNode)
    }
    
    func startSpawningObjects() {
        var timerInterval: Double = 3
        var gapHeightRange: ClosedRange<Float> = 0.3...0.5
        var verticalOffsetRange: ClosedRange<Float> = -0.25...0.25
        
        
        spawnTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] timer in
            let verticalOffset = Float.random(in: verticalOffsetRange)
            
            let gapHeight = Float.random(in: gapHeightRange)
            
            self?.spawnObjects(gapHeight: gapHeight, verticalOffset: verticalOffset)
            
            if timerInterval >= 1.5 {
                timerInterval -= 0.2
            }
            
            if timerInterval <= 0 {
                timer.invalidate()
            }
            
            timerInterval = max(timerInterval, 0.1)
            timer.fireDate = timer.fireDate.addingTimeInterval(timerInterval)
            
            if gapHeightRange.lowerBound >= 0.15 {
                gapHeightRange = (gapHeightRange.lowerBound - 0.05)...(gapHeightRange.upperBound - 0.05)
            }
            
            if verticalOffsetRange.lowerBound >= -0.35 {
                verticalOffsetRange = (verticalOffsetRange.lowerBound - 0.05)...(verticalOffsetRange.upperBound + 0.05)
            }
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        overlayView.removeFromSuperview()
        
        scoreUI.isHidden = false
        scoreUIBackground.isHidden = false
        tutorialImage.isHidden = true
        tutorialMessage.isHidden = true
        
        //spawn first object
        spawnObjects(gapHeight: 0.3, verticalOffset: 0)
        
        tutorialClicked = true
        
        audioPlayer.playBGM()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.startSpawningObjects()
        }
    }
    
    
    
}

protocol MainViewControllerDelegate: AnyObject {
    func mainViewControllerDidUpdateScore(score: Int, highScore: Int)
}
