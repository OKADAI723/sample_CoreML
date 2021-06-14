//
//  ViewController.swift
//  sample_CoreML
//
//  Created by Yudai Fujioka on 2021/06/14.
//

import UIKit
import Vision
import CoreML

final class ViewController: UIViewController {
    
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var cameraButton: UIButton!
    
    private let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        cameraButton.addTarget(self, action: #selector(tappedCameraButton), for: .touchUpInside)
    }
}

@objc private extension ViewController  {
    func tappedCameraButton() {
        present(imagePicker, animated: true, completion: nil)
    }
}

extension ViewController :UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userSelectedImage = info[.originalImage] as? UIImage {
            imageView.image = userSelectedImage
            
            // 画像からオブジェクトを検出し、出力する
            detectImageObject(image: userSelectedImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    /// 画像からオブジェクトを検出・結果を出力
    func detectImageObject(image: UIImage) {
        // VNCoreMLModel(for: xx.modle): xxは使用するCore MLモデルによって変わります
        guard let ciImage = CIImage(image: image), let model = try? VNCoreMLModel(for: MobileNetV2().model) else {
            return
        }
        // Core MLモデルを使用して画像を処理する画像解析リクエスト
        let request = VNCoreMLRequest(model: model) { (request, error) in
            // 解析結果を分類情報として保存
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            
            // 画像内の一番割合が大きいオブジェクトを出力する
            if let firstResult = results.first {
                let objectArray = firstResult.identifier.components(separatedBy: ",")
                if objectArray.count == 1 {
                    self.navigationItem.title = firstResult.identifier
                } else {
                    self.navigationItem.title = objectArray.first
                }
            }
        }
        
        // 画像解析をリクエスト
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        // リクエストを実行
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
}

