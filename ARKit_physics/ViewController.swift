//
//  ViewController.swift
//  ARKit_physics
//
//  Created by 岡田龍太朗 on 2019/08/25.
//  Copyright © 2019 岡田龍太朗. All rights reserved.
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
        
        sceneView.scene = SCNScene()
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.autoenablesDefaultLighting = true;
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
    }
    
    func addSphere(hitResult: ARHitTestResult) {
        let sphereNode = SCNNode()
        
        let sphereGeometry = SCNSphere(radius: 0.03);
        sphereNode.geometry = sphereGeometry
            sphereNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y + 0.05, hitResult.worldTransform.columns.3.z)
        
        sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        sphereNode.physicsBody?.mass = 1.0
        sphereNode.physicsBody?.friction = 1.5
        sphereNode.physicsBody?.rollingFriction = 1.0
        sphereNode.physicsBody?.damping = 0.5
        sphereNode.physicsBody?.angularDamping = 0.5
        sphereNode.physicsBody?.isAffectedByGravity = true
        
        sphereNode.physicsBody?.applyForce(SCNVector3(0, 1.5, 0), asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(sphereNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
        
        let planeNode = SCNNode()
        
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            geometry.materials.first?.diffuse.contents = UIColor.black.withAlphaComponent(0.5)
        
        planeNode.geometry = geometry
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
        guard let geometryPlaneNode = node.childNodes.first,
            let planeGeometry = geometryPlaneNode.geometry as? SCNPlane else {fatalError()}
        
        planeGeometry.width = CGFloat(planeAnchor.extent.x)
        planeGeometry.height = CGFloat(planeAnchor.extent.z)
        geometryPlaneNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        geometryPlaneNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry,options: nil))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        
        let touchPos = touch.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchPos, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            if let hitResult = hitTestResult.first{
                addSphere(hitResult: hitResult)
            }
        }
    }
}
