//
//  File.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 11/02/2022.
//

import RealityKit
import ARKit

/**
        View controller of the **Reconstruction** storyboard, it handle event handlers and interface rendering,
        It inherits from **UIViewController** to act as a View Controller, and to be recognize by the storyboard once we connect to it.
         As the **Reconstruction** story board use the AR technology to scan and load a 3D object, to interact with the recognized element, this class also inherits from **ARSesssionDelegate**.
 
        **Properties:**
        - arView: rendered AR view in the controlled story board
    
 *@IBOutlet is a present component in the story board like **UIButton** for instance*
 */

class ReconstructionViewController: UIViewController, ARSessionDelegate {
  
  @IBOutlet var arView: ARView!
  
  var orientation: UIInterfaceOrientation {
    guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
      fatalError()
    }
    return orientation
  }
  @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
  lazy var imageViewSize: CGSize = {
    CGSize(width: view.bounds.size.width, height: imageViewHeight.constant)
  }()
  
    /**
            Once this class has loaded its view (storyBoard), the ARScene needs to be set up
     
     */
    
  override func viewDidLoad() {
    func setARViewOptions() {
      arView.debugOptions.insert(.showSceneUnderstanding)
    }
    func buildConfigure() -> ARWorldTrackingConfiguration {
      let configuration = ARWorldTrackingConfiguration()
      
      configuration.environmentTexturing = .automatic
      configuration.sceneReconstruction = .mesh
      if type(of: configuration).supportsFrameSemantics(.sceneDepth) {
        configuration.frameSemantics = .sceneDepth
      }
      
      return configuration
    }
    func initARView() {
      setARViewOptions()
      let configuration = buildConfigure()
      arView.session.run(configuration)
    }
    arView.session.delegate = self
    super.viewDidLoad()
    initARView()
  }
  
    /**
            Event handler for the Reconstruction View, when we click on the export button, have to link the UIButton with the Reconstruction storyboard
    */
    
  @IBAction func tappedExportButton(_ sender: UIButton) {
    guard let camera = arView.session.currentFrame?.camera else {return}
    
    func convertToAsset(meshAnchors: [ARMeshAnchor]) -> MDLAsset? {
      guard let device = MTLCreateSystemDefaultDevice() else {return nil}
      
      let asset = MDLAsset()
      
      for anchor in meshAnchors {
        let mdlMesh = anchor.geometry.toMDLMesh(device: device, camera: camera, modelMatrix: anchor.transform)
        asset.add(mdlMesh)
      }
      
      return asset
    }
    func export(asset: MDLAsset) throws -> URL {
      let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
      let url = directory.appendingPathComponent("scaned.obj")
      
      try asset.export(to: url)
      
      return url
    }
    func share(url: URL) {
      let vc = UIActivityViewController(activityItems: [url],applicationActivities: nil)
      vc.popoverPresentationController?.sourceView = sender
      self.present(vc, animated: true, completion: nil)
    }
    if let meshAnchors = arView.session.currentFrame?.anchors.compactMap({ $0 as? ARMeshAnchor }),
       let asset = convertToAsset(meshAnchors: meshAnchors) {
      do {
        let url = try export(asset: asset)
        share(url: url)
      } catch {
        print("export error")
      }
    }
  }
}
