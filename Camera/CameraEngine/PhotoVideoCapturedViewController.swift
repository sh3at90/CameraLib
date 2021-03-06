//
//  PhotoVideoCapturedViewController.swift
//  Camera
//
//  Created by Mohamed Shaat on 1/24/19.
//  Copyright © 2019 Mohamed Shaat. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

struct Filter {
    var name = ""
    var value = ""
}

class PhotoVideoCapturedViewController: UIViewController {
  var filters =  [Filter(name: "Normal", value: ""),
                  Filter(name: "Blur", value: "CIBoxBlur"),
                  Filter(name: "Mono", value: "CIPhotoEffectMono"),
                  Filter(name: "Tonal", value: "CIPhotoEffectTonal"),
                  Filter(name: "Noir", value: "CIPhotoEffectNoir"),
                  Filter(name: "Fade", value: "CIPhotoEffectFade"),
                  Filter(name: "Chrome", value: "CIPhotoEffectChrome"),
                  Filter(name: "Process", value: "CIPhotoEffectProcess"),
                  Filter(name: "Transfer", value: "CIPhotoEffectTransfer"),
                  Filter(name: "Instant", value: "CIPhotoEffectInstant"),
                  Filter(name: "Sepia", value: "CISepiaTone")
                  ]
    @IBOutlet weak var imageToPreview: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var videoview: UIView!
    var previewType:cameraType = .photo
    var delegate: cameraEngineDelegate?
    var selectedFilter:Filter?
    var videoURl:URL?
    var image:UIImage?
    var player:AVPlayer?
    var avPlayer:AVPlayerLayer?
    let avPlayerController = AVPlayerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        registerCellForCollectionView()
        addDoneBarButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
        setupNavigationBarColor()
    }
 
    func addDoneBarButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image:#imageLiteral(resourceName: "ic_done_shot"), style: .plain, target: self, action: #selector(done))
    }
    
    func setupNavigationBarColor() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    @objc func done(sender: AnyObject) {
        if previewType == .photo {
          self.delegate?.didSelect(originalImage:self.image!, filteredImage: applyFilter(filterName:(selectedFilter?.value)!))
        } else {
          self.delegate?.didSelect(videoUrl: videoURl!)
        }
      
    }
    
    func setupView() {
     if let image = image , previewType == .photo {
        imageToPreview.image = image
        videoview.isHidden = true
        selectedFilter = filters[0]
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.reloadData()
        } else {
        imageToPreview.isHidden = true
        playVideo()
        collectionView.isHidden = true
        }
    }
    
    func registerCellForCollectionView() {
        let bundle = Bundle(for: CameraEngineViewController.classForCoder())
        self.collectionView.register(UINib(nibName:"ImageCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: "ImageCollectionViewCell")
    }
    
    func applyFilter(filterName:String)->UIImage {
        if filterName == "" {
            return image!
        }
         let context = CIContext()
        let filter = CIFilter(name: filterName)!
        let beginImage = CIImage(image: image!)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        let result = filter.outputImage!
        let cgImage = context.createCGImage(result, from: result.extent)
        let resultImage = UIImage(cgImage: cgImage!, scale: (self.image?.scale)!, orientation: (self.image?.imageOrientation)!)
        return resultImage
        
    }
    
    func playVideo(){
        if let videoURL = videoURl  {
        player = AVPlayer(url:videoURL)
        avPlayerController.player = player;
        avPlayerController.videoGravity =  AVLayerVideoGravity.resizeAspectFill.rawValue
        avPlayerController.view.frame = videoview.frame
        avPlayerController.showsPlaybackControls = true
        self.addChildViewController(avPlayerController)
        self.view.addSubview(avPlayerController.view);
        avPlayerController.view.bringSubview(toFront:self.view)
        avPlayerController.didMove(toParentViewController:self)
        player?.play()
        }
    }
}

extension PhotoVideoCapturedViewController : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        let filter  = filters[indexPath.row]
        cell.imageView.image = applyFilter(filterName: filter.value)
        cell.imageView.layer.cornerRadius = 6.0
        cell.imageView.layer.borderColor = UIColor.white.cgColor
        cell.imageView.layer.borderWidth = 2.0
        cell.filterName.text = filter.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:114, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFilter = filters[indexPath.row]
        self.imageToPreview.image = applyFilter(filterName: (selectedFilter?.value)!)
    }
}
