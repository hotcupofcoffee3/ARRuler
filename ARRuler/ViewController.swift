//
//  ViewController.swift
//  ARRuler
//
//  Created by Adam Moore on 5/22/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // Keeps track of the new 'dotNode's that we add to the screen.
    var dotNodes = [SCNNode]()
    
    // Creates a 'node' from the 'geometry' that we created as the 'textGeometry'
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Shows feature points on a surface for measurements.
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
       
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
    
    
    
    // When the user touched the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count < 2 {
            
            // Grabs the location of the touch
            // 'touches' is the set of [UITouch] that the 'touchesBegan' function does.
            // 'location(in: sceneView)' checks to see if the location corresponds to somewhere in the 'sceneView' that our camera can see.
            if let touchLocation = touches.first?.location(in: sceneView) {
                
                // This is a point automatically identified as a point on the object that has been detected by the camera in the 'sceneView'.
                let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint)
                
                // The first result in the 'hitTestResult' array.
                if let hitResult = hitTestResult.first {
                    
                    addDot(at: hitResult)
                    
                }
                
            }
            
        } else {
            
            for dot in dotNodes {
                
                dot.removeFromParentNode()
                textNode.removeFromParentNode()
                
            }
            
            dotNodes = []
            
        }
        
    }
    
    
    // This is our created function that will add a dot to the 'ARHitTestResult' that we put in here.
    func addDot(at hitResult: ARHitTestResult) {
        
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3Make(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            
            calculate()
            
        }
        
    }
    
    func calculate() {
        
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        
        updateText(text: "\(distance)", atPosition: end.position)
        
    }
    
    // Adding text geometry, with position being at the 'end' position, which is the second place we touch.
    func updateText(text: String, atPosition position: SCNVector3) {
        
        // Creates a text geometry
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        // Sets the first material for the 'textGeometry' to a particular material, instead of adding the material into an array of multiple materials, as we typically have done.
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        // Sets 'textNode' to the 'geometry' that we created as the 'textGeometry'
        textNode = SCNNode(geometry: textGeometry)
        
        // Sets the position in real space.
        // Adds about 1cm above the 'y' position, so it's not exactly on top of the 'end' point.
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        
        // Scales down the size of the text, to 1% of its original size.
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        // Add 'node' into scene
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
    
    
    
    
}













