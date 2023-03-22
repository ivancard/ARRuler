//
//  ViewController.swift
//  ARRuler
//
//  Created by ivan cardenas on 21/03/2023.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    var dotNodes = [SCNNode]()
    var textNode = SCNNode()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            dotNodes.forEach { $0.removeFromParentNode() }
            dotNodes = [SCNNode]()
        }
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitResults = sceneView.hitTest(touchLocation, types: .featurePoint)

            if let hitResult = hitResults.first {
                addDot(at: hitResult)
            }
        }
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

    func addDot(at hitResult: ARHitTestResult) {
        let sphere = SCNSphere(radius: 0.005)
        let sphereNode = SCNNode()
        sphereNode.position = SCNVector3(x:hitResult.worldTransform.columns.3.x , y: hitResult.worldTransform.columns.3.y, z: hitResult.worldTransform.columns.3.z)
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor.purple
        sphere.materials = [sphereMaterial]

        sphereNode.geometry = sphere

        sceneView.scene.rootNode.addChildNode(sphereNode)

        dotNodes.append(sphereNode)

        if dotNodes.count >= 2 {

            calculate()
        }
    }

    func calculate() {
        let startDot = dotNodes[0]
        let endDot = dotNodes[1]

        let x = startDot.position.x - endDot.position.x
        let y = startDot.position.y - endDot.position.y
        let z = startDot.position.z - endDot.position.z

        let distance = abs(sqrt(( pow(x, 2) + pow(y, 2) + pow(z, 2) ) )) * 100

        let midPoint = SCNVector3(
            x: ((startDot.position.x + endDot.position.x) / 2),
            y: ((startDot.position.y + endDot.position.y) / 2),
            z: ((startDot.position.z + endDot.position.z) / 2)
        )

        updateText(text: (String(format: "%.1f", distance)), at:  midPoint)
    }

    func updateText(text distance: String, at position: SCNVector3) {

        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: distance, extrusionDepth: 1.0)
        textGeometry.chamferRadius = 0.1
        textGeometry.firstMaterial?.diffuse.contents = UIColor.purple
        textNode = SCNNode(geometry: textGeometry)

        textNode.position = SCNVector3(
            x: position.x,
            y: position.y,
            z: position.z
        )

        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)

        sceneView.scene.rootNode.addChildNode(textNode )
    }
}
