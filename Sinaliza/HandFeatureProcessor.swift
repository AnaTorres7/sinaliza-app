//
//  HandFeatureProcess.swift
//  Sinaliza
//
//  Created by Ana Flávia Torres do Carmo on 29/06/25.
//

import UIKit
import Vision
import CoreML

class HandFeatureProcessor {
    func extractAttributes(from image: UIImage) -> MLMultiArray? {
        guard let cgImage = image.cgImage else { return nil }

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .right, options: [:])
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 1
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
        
        do {
            try handler.perform([handPoseRequest])
        } catch {
            assertionFailure("Human Pose Request failed: \(error.localizedDescription)")
        }
        
        guard let handPoses = handPoseRequest.results, !handPoses.isEmpty else {
            print("Nenhuma mão")
            return nil
        }
        
        let handObservation = handPoses.first

        do {
            guard let landmarks = try? handObservation!.recognizedPoints(.all) else {
                return nil
            }

            let keys: [VNHumanHandPoseObservation.JointName] = [
                .wrist,
                .thumbTip, .indexTip, .middleTip, .ringTip, .littleTip,
                .thumbIP, .indexDIP, .middleDIP, .ringDIP, .littleDIP
            ]

            var points: [VNRecognizedPoint] = []
            for key in keys {
                if let point = landmarks[key], point.confidence > 0.5 {
                    points.append(point)
                } else {
                    return nil
                }
            }

            let wrist = points[0]
            let tipPoints = Array(points[1...5])

            let distances = tipPoints.map { hypot($0.x - wrist.x, $0.y - wrist.y) }

            func angleBetween(_ a: VNRecognizedPoint, _ b: VNRecognizedPoint) -> Double {
                let v1 = CGVector(dx: a.x - wrist.x, dy: a.y - wrist.y)
                let v2 = CGVector(dx: b.x - wrist.x, dy: b.y - wrist.y)
                let dot = v1.dx * v2.dx + v1.dy * v2.dy
                let mag1 = sqrt(v1.dx * v1.dx + v1.dy * v1.dy)
                let mag2 = sqrt(v2.dx * v2.dx + v2.dy * v2.dy)
                let cosTheta = dot / (mag1 * mag2)
                return acos(min(max(cosTheta, -1.0), 1.0))
            }

            let angleIndexMiddle = angleBetween(points[2], points[3])
            let angleMiddleRing = angleBetween(points[3], points[4])
            let angleThumbIndex = angleBetween(points[1], points[2])

            let dyThumb = points[1].y - wrist.y
            let dyIndex = points[2].y - wrist.y

            let attributes = distances + [angleIndexMiddle, angleMiddleRing, angleThumbIndex, dyThumb, dyIndex]

            guard let mlArray = try? MLMultiArray(shape: [NSNumber(value: attributes.count)], dataType: .double) else {
                return nil
            }

            for (index, value) in attributes.enumerated() {
                mlArray[index] = NSNumber(value: value)
            }

            return mlArray

        }
    }
}
