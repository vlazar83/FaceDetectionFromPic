//
//  ViewController.swift
//  FaceDetectionFromPic
//
//  Created by admin on 2020. 07. 03..
//  Copyright © 2020. admin. All rights reserved.
//

import UIKit
import MLKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    /// An overlay view that displays detection annotations.
    private lazy var annotationOverlayView: UIView = {
      precondition(isViewLoaded)
      let annotationOverlayView = UIView(frame: .zero)
      annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
      return annotationOverlayView
    }()
    
    @IBAction func takePhoto(_ sender: Any) {
        removeDetectionAnnotations()
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.cameraDevice = .front
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imageView.addSubview(annotationOverlayView)
        NSLayoutConstraint.activate([
          annotationOverlayView.topAnchor.constraint(equalTo: imageView.topAnchor),
          annotationOverlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
          annotationOverlayView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
          annotationOverlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
        ])
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        imageView.image = info[.editedImage] as? UIImage

        guard let imageTaken = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // High-accuracy landmark detection and face classification
        let options = FaceDetectorOptions()
        options.performanceMode = .accurate
        options.landmarkMode = .all
        options.classificationMode = .all
        options.contourMode = .all
        
        let faceDetector = FaceDetector.faceDetector(options: options)
        
        // Initialize a VisionImage object with the given UIImage.
        let visionImage = VisionImage(image: imageTaken)
        visionImage.orientation = imageTaken.imageOrientation
        
        faceDetector.process(visionImage) { faces, error in
          guard error == nil, let faces = faces, !faces.isEmpty else {
            // ...
            return
          }

          // Faces detected
          // ...
            
            for face in faces {
                
                
                
                let transform = self.transformMatrix()
                let transformedRect = face.frame.applying(transform)
                UIUtilities.addRectangle(
                  transformedRect,
                  to: self.annotationOverlayView,
                  color: UIColor.green
                )
                
                
              /*let frame = face.frame
              if face.hasHeadEulerAngleX {
                let rotX = face.headEulerAngleX  // Head is rotated to the uptoward rotX degrees
                print("rotX: ", rotX)
              }
              if face.hasHeadEulerAngleY {
                let rotY = face.headEulerAngleY  // Head is rotated to the right rotY degrees
                print("rotY: ", rotY)
              }
              if face.hasHeadEulerAngleZ {
                let rotZ = face.headEulerAngleZ  // Head is tilted sideways rotZ degrees
                print("rotZ: ", rotZ)
              }

              // If landmark detection was enabled (mouth, ears, eyes, cheeks, and
              // nose available):
              if let leftEye = face.landmark(ofType: .leftEye) {
                let leftEyePosition = leftEye.position
                print("leftEyePosition: ", leftEyePosition)
              }

              // If contour detection was enabled:
              if let leftEyeContour = face.contour(ofType: .leftEye) {
                let leftEyePoints = leftEyeContour.points
                print("leftEyePoints: ", leftEyePoints)
              }
              if let upperLipBottomContour = face.contour(ofType: .upperLipBottom) {
                let upperLipBottomPoints = upperLipBottomContour.points
                print("upperLipBottomPoints: ", upperLipBottomPoints)
              }

              // If classification was enabled:
              if face.hasSmilingProbability {
                let smileProb = face.smilingProbability
                print("smileProb: ", smileProb)
              }
              if face.hasRightEyeOpenProbability {
                let rightEyeOpenProb = face.rightEyeOpenProbability
                print("rightEyeOpenProb: ", rightEyeOpenProb)
              }

              // If face tracking was enabled:
              if face.hasTrackingID {
                let trackingId = face.trackingID
                print("trackingId: ", trackingId)
              }
  */
            }

        }
        
        
        

    }

    private func transformMatrix() -> CGAffineTransform {
      guard let image = imageView.image else { return CGAffineTransform() }
      let imageViewWidth = imageView.frame.size.width
      let imageViewHeight = imageView.frame.size.height
      let imageWidth = image.size.width
      let imageHeight = image.size.height

      let imageViewAspectRatio = imageViewWidth / imageViewHeight
      let imageAspectRatio = imageWidth / imageHeight
      let scale =
        (imageViewAspectRatio > imageAspectRatio)
        ? imageViewHeight / imageHeight : imageViewWidth / imageWidth

      // Image view's `contentMode` is `scaleAspectFit`, which scales the image to fit the size of the
      // image view by maintaining the aspect ratio. Multiple by `scale` to get image's original size.
      let scaledImageWidth = imageWidth * scale
      let scaledImageHeight = imageHeight * scale
      let xValue = (imageViewWidth - scaledImageWidth) / CGFloat(2.0)
      let yValue = (imageViewHeight - scaledImageHeight) / CGFloat(2.0)

      var transform = CGAffineTransform.identity.translatedBy(x: xValue, y: yValue)
      transform = transform.scaledBy(x: scale, y: scale)
      return transform
    }
    
    /// Removes the detection annotations from the annotation overlay view.
    private func removeDetectionAnnotations() {
      for annotationView in annotationOverlayView.subviews {
        annotationView.removeFromSuperview()
      }
    }
    
}

