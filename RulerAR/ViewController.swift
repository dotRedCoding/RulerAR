//
//  ViewController.swift
//  RulerAR
//
//  Created by Jared on 2023-02-16.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotArray = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotArray.count >= 2 {
            for dot in dotArray {
                dot.removeFromParentNode()
            }
            dotArray = [SCNNode]()
        }
        
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) {
                
                let hitTestResults = sceneView.session.raycast(query)
                
                if let hitResult = hitTestResults.first {
                    addDot(at: hitResult)
                }
            }
        }
    }
    
    func addDot(at hitResult: ARRaycastResult) {
        
        let dot = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemYellow
        dot.materials = [material]
        
        let textNode = SCNNode(geometry: dot)
        textNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(textNode)
        dotArray.append(textNode)
        
        if dotArray.count >= 2 {
            calculate()
        }
    }
    
    
    func calculate() {
        let firstDot = dotArray[0]
        let secondDot = dotArray[1]
        
        let a = secondDot.position.x - firstDot.position.x
        let b = secondDot.position.y - firstDot.position.y
        let c = secondDot.position.z - firstDot.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        
        updateText(text: "\(abs(distance))", at: firstDot.position)
    }
    
    func updateText(text: String, at position: SCNVector3) {
        
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.systemYellow
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(x: position.x, y: position.y + 0.01, z: position.z)
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
}
