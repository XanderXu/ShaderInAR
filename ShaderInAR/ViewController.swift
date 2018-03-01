//
//  ViewController.swift
//  ShaderInAR
//
//  Created by CoderXu on 2018/3/1.
//  Copyright © 2018年 XanderXu. All rights reserved.
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
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        setupShader()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    @IBAction func switchChange(_ sender: UISwitch) {
        let shipNode = sceneView.scene.rootNode.childNode(withName: "shipMesh", recursively: true)
        let skin = shipNode?.geometry?.firstMaterial;
        let factor = sender.isOn ? 1.0 : 0.0
        switch sender.tag {
        case 10:
            skin?.setValue(Double(factor), forKey: "GeometryFactor")
        case 11:
            skin?.setValue(Double(factor), forKey: "SurfaceFactor")
        case 12:
            skin?.setValue(Double(factor), forKey: "LightFactor")
        case 13:
            skin?.setValue(Double(factor), forKey: "FragmentFactor")
        default:
            print("switch")
        }
    }
    
    private func setupShader() {
        
        let shipNode = sceneView.scene.rootNode.childNode(withName: "shipMesh", recursively: true)
        let skin = shipNode?.geometry?.firstMaterial;
        // 为了方便观察混合效果,我在各个示例shader中添加了一个因子factor,分别设置为0.0和1.0可以控制效果的开启和关闭;默认为0.0--关闭;
        let geometryShader = """
        uniform float Amplitude = 0.1;
        uniform float GeometryFactor = 0.0;

        _geometry.position.xyz += _geometry.normal * (Amplitude * _geometry.position.y * _geometry.position.x) * sin(u_time) * GeometryFactor;
        """
        
        let surfaceShader = """
        uniform float Scale = 12.0;
        uniform float Width = 0.25;
        uniform float Blend = 0.3;
        uniform float SurfaceFactor = 0.0;

        vec2 position = fract(_surface.diffuseTexcoord * Scale);
        float f1 = clamp(position.y / Blend, 0.0, 1.0);
        float f2 = clamp((position.y - Width) / Blend, 0.0, 1.0);
        f1 = f1 * (1.0 - f2);
        f1 = f1 * f1 * 2.0 * (3. * 2. * f1);
        _surface.diffuse = _surface.diffuse * (1-SurfaceFactor) + mix(vec4(1.0), vec4(vec3(0.0),1.0), f1) * SurfaceFactor;
        """
        
        let lightShader = """
        uniform float WrapFactor = 0.5;
        uniform float LightFactor = 0.0;

        float dotProduct = (WrapFactor + max(0.0, dot(_surface.normal,_light.direction))) / (1 + WrapFactor);
        _lightingContribution.diffuse += (dotProduct * _light.intensity.rgb) * LightFactor;

        vec3 halfVector = normalize(_light.direction + _surface.view);
        dotProduct = max(0.0, pow(max(0.0, dot(_surface.normal, halfVector)), _surface.shininess));
        _lightingContribution.specular += (dotProduct * _light.intensity.rgb) * LightFactor;
        """
        
        let fragmentShader = """
        uniform float FragmentFactor = 0.0;

        _output.color.rgb = (vec3(1.0) - _output.color.rgb) * FragmentFactor + (1-FragmentFactor) * _output.color.rgb;
        """
        
        skin?.shaderModifiers = [SCNShaderModifierEntryPoint.geometry: geometryShader,
                                 SCNShaderModifierEntryPoint.surface: surfaceShader,
                                 SCNShaderModifierEntryPoint.lightingModel: lightShader,
                                 SCNShaderModifierEntryPoint.fragment: fragmentShader
        ]

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
}
