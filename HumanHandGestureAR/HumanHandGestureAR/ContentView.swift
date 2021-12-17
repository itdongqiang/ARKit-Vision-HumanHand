//
//  ContentView.swift
//  HumanHandGestureAR
//
//  Created by 唐东强 on 2021/12/15.
//

import SwiftUI
import RealityKit
import Vision
import ARKit

struct ContentView : View {
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

var request: VNDetectHumanHandPoseRequest!
let arView = ARView(frame: .zero)
var usefulData: Bool = false
var count: Int = 0
var shitou: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint] = [:]
var jiandao: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint] = [:]
var bu: [VNHumanHandPoseObservation.JointName : VNRecognizedPoint] = [:]
let clueLabel = UILabel.init(frame: CGRect.init(x: UIScreen.main.bounds.width/2 - 50, y: 100, width: 100, height: 30))

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        request = VNDetectHumanHandPoseRequest(completionHandler: handDetectionCompletionHandler)
        request.maximumHandCount = 1
        
        let config = ARFaceTrackingConfiguration()
        arView.session.delegate = arView
        arView.session.run(config, options: [])
        
        clueLabel.text = "采集  石头"
        clueLabel.textColor = .green
        arView.addSubview(clueLabel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            usefulData = true
        }
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func handDetectionCompletionHandler(request: VNRequest?, error: Error?) {
        guard let observation = request?.results?.first as? VNHumanHandPoseObservation else { return }
        guard let recogData = try? observation.recognizedPoints(.all) else {return}
        var out: Bool = false
        for VNDPoint: VNRecognizedPoint in recogData.values {
            let point = VNImagePointForNormalizedPoint(CGPoint(x: VNDPoint.location.y, y: VNDPoint.location.x), Int(UIScreen.main.bounds.width),  Int(UIScreen.main.bounds.height))
            if point.x<0 || point.y<0 {
                out = true
                break
            }
        }
        if usefulData && !out{
            if count == 0 {
                shitou =  recogData
                DispatchQueue.main.async {
                    clueLabel.text = "采集  剪刀"
                }
            } else if count == 1{
                jiandao =  recogData
                DispatchQueue.main.async {
                    clueLabel.text = "采集  布"
                }
            }   else if count == 2{
                bu =  recogData
                DispatchQueue.main.async {
                    clueLabel.text = "开始游戏"
                }
            } else{
                let kaka = [shitou, jiandao, bu]
                var index = 0
                while index <= 2 {
                    let indexTipx = recogData[.indexTip]!.x / kaka[index][.indexTip]!.x - 1
                    let indexTipy = recogData[.indexTip]!.y / kaka[index][.indexTip]!.y - 1
                    
                    let middleTipx = recogData[.middleTip]!.x / kaka[index][.middleTip]!.x - 1
                    let middleTipy = recogData[.middleTip]!.y / kaka[index][.middleTip]!.y - 1
                    
                    let littleTipx = recogData[.littleTip]!.x / kaka[index][.littleTip]!.x - 1
                    let littleTipy = recogData[.littleTip]!.y / kaka[index][.littleTip]!.y - 1
                    
                    let thumbTipx = recogData[.thumbTip]!.x / kaka[index][.thumbTip]!.x - 1
                    let thumbTipy = recogData[.thumbTip]!.y / kaka[index][.thumbTip]!.y - 1
                    
                    let ringTipx = recogData[.ringTip]!.x / kaka[index][.ringTip]!.x - 1
                    let ringTipy = recogData[.ringTip]!.y / kaka[index][.ringTip]!.y - 1
                    
                    let confidance = 0.2
                    if fabs(indexTipx) < confidance && fabs(indexTipy) < confidance && fabs(littleTipx) < confidance && fabs(littleTipy) < confidance && fabs(middleTipx) < confidance && fabs(middleTipy) < confidance && fabs(ringTipx) < confidance && fabs(ringTipy) < confidance && fabs(thumbTipx) < confidance && fabs(thumbTipy) < confidance
                    {
                        DispatchQueue.main.sync {
                            if index == 0 {
                                clueLabel.text = "你出的 石头"
                            } else if index == 1{
                                clueLabel.text = "你出的 剪刀"
                            } else if index == 2{
                                clueLabel.text = "你出的 布"
                            }
                        }
                        break
                    }
                    index += 1
                }
            }
            count += 1
            if count < 3 {
                usefulData = false
            } else {
                usefulData = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                usefulData = true
            }
        }
        
    }
}

extension ARView: ARSessionDelegate{
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if request == nil {
            return
        }
        let pixelBuffer = frame.capturedImage
        DispatchQueue.global().async {
            let handler = VNImageRequestHandler(cvPixelBuffer:pixelBuffer, orientation: .up, options: [:])
            do {
                try handler.perform([(request)!])
            } catch let error {
                print(error)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
