//
//  AreaViewController.swift
//  O-NormesV2
//
//  Created by Toufik Belgacemi on 11/02/2022.
//

import UIKit
import ARKit

/**
 
This class inherits from **MeasureViewController**
This class is directly connected to the **Measure** storyboard.

**Properties**:
- areaLabel: debugging property to calculate the area beteen two in x and y axis
- breadthLabel: length between two points
- lengthLabel: equivalent to **breadthLabel**

 */

class AreaViewController: MeasureViewController {
  
  enum MeasureState {
    case lengthCalc
    case breadthCalc
  }
  
  struct FloorRect {
    var length: CGFloat
    var breadth: CGFloat
    var area: CGFloat {
      get {
        return length * breadth
      }
    }
  }
  
  var floorRect = FloorRect(length: 0, breadth: 0)
  var lengthNodes = NSMutableArray()
  var breadthNodes = NSMutableArray()
  var lineNodes = NSMutableArray()
  var currentState: MeasureState = MeasureState.lengthCalc
  
  var allPointNodes: [Any] {
    get {
      return lengthNodes as! [Any] + breadthNodes
    }
  }
  var nodeColor: UIColor {
    get {
      return nodeColor(forState: currentState, alphaComponent: 0.7)
    }
  }
  
  
  @IBOutlet weak var areaLabel: UILabel!
  @IBOutlet weak var breadthLabel: UILabel!
  @IBOutlet weak var lengthLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    sceneView.delegate = self
    lengthLabel.textColor = nodeColor(forState: .lengthCalc, alphaComponent: 1)
    breadthLabel.textColor = nodeColor(forState: .breadthCalc, alphaComponent: 1)
  }
  
  private func nodeColor(forState state: MeasureState, alphaComponent: CGFloat) -> UIColor {
    switch state {
      case .lengthCalc:
        return UIColor.white.withAlphaComponent(alphaComponent)
      case .breadthCalc:
        return UIColor.white.withAlphaComponent(alphaComponent)
    }
  }
  
  /**
        Private method to get all the nodes created by the user.
   
        - Parameters:
            - state: useless paramters as **breadthCalc** and **lengthCalc** get us the same distance
   
        - Returns: nodes array
   
   */
    
  private func nodesList(forState state: MeasureState) -> NSMutableArray {
    switch state {
      case .lengthCalc:
        return lengthNodes
      case .breadthCalc:
        return breadthNodes
    }
  }
    
    /**
            Method to remove all the existing component in the AR scene.
     
     */
  
  func clearScene() {
    removeNodes(fromNodeList: nodesList(forState: .lengthCalc))
    removeNodes(fromNodeList: nodesList(forState: .breadthCalc))
    removeNodes(fromNodeList: lineNodes)
  }
  
/**
    Clearout all the measurement once we reach two line measurements

 */
    
  private func resetMeasurement() {
    clearScene()
    floorRect = FloorRect(length: 0, breadth: 0)
    currentState = .lengthCalc
    lengthLabel.text = "--"
    breadthLabel.text = "--"
    areaLabel.text = "--"
  }
  
  
  //MARK: - IBActions
  
    /**
    IBAction to build a point object in the scene.
     
     - Parameters:
        - sender: bound button component for this action
    */
    
  @IBAction func addPoint(_ sender: UIButton) {
    
    let pointLocation = view.convert(screenCenterPoint, to: sceneView)
    guard let hitResultPosition = sceneView.hitResult(forPoint: pointLocation) else {
      return
    }
    
    //To prevent multiple taps
    sender.isUserInteractionEnabled = false
    defer {
      sender.isUserInteractionEnabled = true
    }
    
    if allPointNodes.count >= 4 {
      resetMeasurement()
    }
    let nodes = nodesList(forState: currentState)
    
    let sphere = SCNSphere(color: nodeColor, radius: nodeRadius)
    let node = SCNNode(geometry: sphere)
    node.position = hitResultPosition
    sceneView.scene.rootNode.addChildNode(node)
    
    // Add the Sphere to the list.
    nodes.add(node)
    
    if nodes.count == 1 {
      
      //Add a realtime line
      let realTimeLine = LineNode(from: hitResultPosition,
                                  to: hitResultPosition,
                                  lineColor: nodeColor,
                                  lineWidth: lineWidth)
      realTimeLine.name = realTimeLineName
      realTimeLineNode = realTimeLine
      sceneView.scene.rootNode.addChildNode(realTimeLine)
      
    } else if nodes.count == 2 {
      let startNode = nodes[0] as! SCNNode
      let endNode = nodes[1]  as! SCNNode
      
      // Create a node line between the nodes
      let measureLine = LineNode(from: startNode.position,
                                 to: endNode.position,
                                 lineColor: nodeColor,
                                 lineWidth: lineWidth)
      sceneView.scene.rootNode.addChildNode(measureLine)
      lineNodes.add(measureLine)
      
      //calc distance
      let distance = sceneView.distance(betweenPoints: startNode.position, point2: endNode.position)
      
      //Remove realtime line node
      realTimeLineNode?.removeFromParentNode()
      realTimeLineNode = nil
      
      //Change state
      switch currentState {
        case .lengthCalc:
          floorRect.length = distance
          currentState = .breadthCalc
          lengthLabel.text = String(format: "%.2fm", distance)
        case .breadthCalc:
          floorRect.breadth = distance
          breadthLabel.text = String(format: "%.2fm", distance)
          areaLabel.text = String(format: "%.2fm", floorRect.area)
      }
    }
  }
  
}

extension AreaViewController: ARSCNViewDelegate {
  
/**
    Method to update the display measurements event
    - Parameters:
        - renderer: **SCNSceneRenderer** not used for this function
        - updateAtTime: time to save, to define the next updating measure
 
 */
    
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    let dotNodes = allPointNodes as! [SCNNode]
    if dotNodes.count > 0, let currentCameraPosition = self.sceneView.pointOfView {
      updateScaleFromCameraForNodes(dotNodes, fromPointOfView: currentCameraPosition)
    }
    //Update realtime line node
    if let realTimeLineNode = self.realTimeLineNode,
       let hitResultPosition = sceneView.hitResult(forPoint: screenCenterPoint),
       let startNode = self.nodesList(forState: self.currentState).firstObject as? SCNNode {
      realTimeLineNode.updateNode(vectorA: startNode.position, vectorB: hitResultPosition, color: nil)

      let distance = sceneView.distance(betweenPoints: startNode.position, point2: hitResultPosition)
      let label = currentState == .lengthCalc ? lengthLabel : breadthLabel
      DispatchQueue.main.async { [unowned self] in
        label?.text = String(format: "%.2fm", distance)
        label?.textColor = self.nodeColor
      }
    }
  }
    
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
      case .normal:
        break
      default:
        break
    }
  }
  
}
