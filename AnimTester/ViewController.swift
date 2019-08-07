//
//  ViewController.swift
//  AnimTester
//
//  Created by Chris Ross on 8/7/19.
//  Copyright © 2019 Chris Ross. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var animations = [String: CAAnimation]()
    var idle: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        loadAnimations()
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

    func loadAnimations() {
        //Load the character in the idle animation
        let idleScene = SCNScene(named: "art.scnassets/Anthony@IdleFixed.dae")!
        
        //this node will be parent of all animation models
        let node = SCNNode()
        
        //add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        //set up some parameters
        node.position = SCNVector3(0, -1, -2)
        node.scale = SCNVector3(0.2, 0.2, 0.2)
        //node.name = "myNode"
        
        //add the node to the scene
        sceneView.scene.rootNode.addChildNode(node)
        
        //let idleNode = sceneView.scene.rootNode.childNode(withName: "myNode", recursively: true)
        //idleNode?.isPaused = false
        
        //load all the DAE animations
        loadAnimation(withKey: "idle", sceneName: "art.scnassets/Anthony@IdleFixed", animationIdentifier: "Anthony@IdleFixed-1")
        loadAnimation(withKey: "walking", sceneName: "art.scnassets/Anthony@WalkFixed", animationIdentifier: "Anthony@WalkFixed-1")
    }
    
    func loadAnimation(withKey: String, sceneName: String, animationIdentifier: String) {
        let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
            //the animation will play continuously
            //animationObject.repeatCount = -1
            //create smooth transition between animations
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(0.5)
            
            if animationIdentifier == "Anthony@WalkFixed-1" {
                animationObject.duration = 2.083
            }
            
            //Store the animationfor later use
            animations[withKey] = animationObject
        }
        playAnimation(key: "idle")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
        
        //test if the 3d object was touched
        var hitTestOptions = [SCNHitTestOption: Any]()
        
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        let hitResults: [SCNHitTestResult] = sceneView.hitTest(location, options: hitTestOptions)
        
        if hitResults.first != nil {
            if(idle) {
                playAnimation(key: "walking")
                print("Now Playing walking animation")
            }
            else {
                stopAnimation(key: "walking")
                print("Now stoping walking animation")
            }
            
            idle = !idle
            print("Idle is now \(idle)")
            return
        }
    }
    
    func playAnimation(key: String) {
        //add the animation to start playing it right away
        sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
    }
    
    func stopAnimation(key: String) {
        //stop the animation with a smooth transition
        sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
