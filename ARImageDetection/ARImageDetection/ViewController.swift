//
//  ViewController.swift
//  ARImageDetection
//
//  Created by Sylvain Guillier on 17/01/2019.
//  Copyright © 2019 Sylvain Guillier. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else { return }
        
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1

        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        configuration.isLightEstimationEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        let animator = SCNAction.scale(by: 10, duration: 3)
        
        if anchor is ARImageAnchor {
            let plane = SCNPlane(width: 0.7, height: 0.35)
            let blankScene = SKScene(fileNamed: "BlankScene")
            
            plane.firstMaterial?.diffuse.contents = blankScene
            plane.firstMaterial?.isDoubleSided = true
            plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)

            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            
            var figuresNode = SCNNode()
            let figure = anchor.name 
            let figuresScene = SCNScene(named: "art.scnassets/\(figure!)/\(figure!).scn")
            figuresNode = figuresScene!.rootNode.childNodes.first!
            
            let min = figuresNode.boundingBox.min
            let max = figuresNode.boundingBox.max
            figuresNode.pivot = SCNMatrix4MakeTranslation(min.x + (max.x-min.x)/2,min.y + (max.y-min.y)/2, min.z + (max.z-min.z)/2)
        

            node.addChildNode(planeNode)
            planeNode.addChildNode(figuresNode)
             figuresNode.runAction(rotateObject())
            figuresNode.runAction(animator)

        }
     
        return node
    }

    
    func rotateObject() -> SCNAction {
        let action = SCNAction.rotateBy(x: 0, y: 0, z: .pi*2, duration: 5)
        let repeatAction = SCNAction.repeatForever(action)
        return repeatAction
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
