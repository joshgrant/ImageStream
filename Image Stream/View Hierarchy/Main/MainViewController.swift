//
//  MainViewController.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/11/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa
import Photos

class MainViewController: NSViewController
{
    // MARK: - Variables
    
    var viewModel: MainViewModel = MainViewModel()
    var readyForUpdate: Bool = true
    var playing: Bool = false
    
    var idealFPS: Int = 15
    var frames: Int = 0
    var startTime: Date?
    var idealSize: CGFloat = 450
    var verticalOffset: CGFloat = 0
    var scrollDelta: CGFloat = 0
    
    lazy var imageManager: PHImageManager = {
       return PHImageManager()
    }()
    
    lazy var displayLinkCallback: CVDisplayLinkOutputCallback? = {
        let callback: CVDisplayLinkOutputCallback = { displayLink, inNow, inOutputTime, flagsIn, flagsOut, context -> CVReturn in
            
            let controller: MainViewController = unsafeBitCast(context, to: MainViewController.self)
            let seconds = controller.startTime?.distance(to: Date()) ?? 0
            
            let frames = Double(controller.frames)
            let idealFPS = Double(controller.idealFPS)
            let fps = frames / seconds
            
            if fps > idealFPS
            {
                return kCVReturnSuccess
            }
            else
            {
                if controller.readyForUpdate
                {
                    controller.readyForUpdate = false
                    controller.updateImage()
                }
            }
            
            if seconds > 1
            {
                controller.frames = 0
                controller.updateLabel(fps: fps)
                controller.startTime = Date()
            }
            
            return kCVReturnSuccess
        }
        return callback
    }()
    
    lazy var displayLink: CVDisplayLink = {
        var link: CVDisplayLink? = nil
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        CVDisplayLinkSetOutputCallback(link!, self.displayLinkCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        return link!
    }()
    
    // MARK: Interface outlets
    
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var fpsLabel: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var idealFPSSlider: NSSlider!
    @IBOutlet weak var backButton: NSButton!
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var forwardButton: NSButton!
    
    @IBOutlet weak var imageXConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageYConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        progressBar.isHidden = true
        fpsLabel.isHidden = !Defaults.showFPS
    }
    
    override var acceptsFirstResponder: Bool { return true }
    
    override func viewDidDisappear()
    {
        super.viewDidDisappear()
        
        self.playing = false
        CVDisplayLinkStop(displayLink)
    }
    
    // TODO: Clean up
    func updateLabel(fps: Double)
    {
        DispatchQueue.main.async {
            self.fpsLabel.stringValue = "\(Int(fps))"
        }
    }
    
    // TODO: Clean up
    func updateImage(forward: Bool = true)
    {
        // This crashes when sync
        DispatchQueue.main.async {
            guard self.viewModel.images.count > 0 else { return }
            
            let image = self.viewModel.image(forward: forward)
            
			guard let (origin, size) = image.imageConstraints(in: self.view.frame, idealSize: self.idealSize, verticalOffset: self.verticalOffset) else {
                self.readyForUpdate = true
                return
            }
            
            self.imageView.image = image.image
            
            self.imageWidthConstraint.constant = size.width
            self.imageHeightConstraint.constant = size.height
            self.imageXConstraint.constant = origin.x
            self.imageYConstraint.constant = origin.y
            self.view.layoutSubtreeIfNeeded()
            
            self.frames += 1
            self.readyForUpdate = true
        }
    }
    
    // MARK: - Functions
    
    override func scrollWheel(with event: NSEvent)
    {
        idealSize += event.scrollingDeltaY
        scrollDelta += event.scrollingDeltaY
    }
    
    override func keyDown(with event: NSEvent)
    {
        if event.characters == "-" {
            verticalOffset += 1
        } else if event.characters == "=" {
            verticalOffset -= 1
        }
    }
    
    @IBAction func idealFPSSliderValueChanged(_ sender: NSSlider)
    {
        self.idealFPS = Int(sender.doubleValue)
    }
    
    @IBAction func playPauseButtonDidTouchUpInside(_ sender: NSButton)
    {
        if playing
        {
            playing = false
            CVDisplayLinkStop(self.displayLink)
        }
        else
        {    
            // TODO: Reuse this
            self.startTime = Date()
            playing = true
            CVDisplayLinkStart(self.displayLink)
        }
        
        self.backButton.isEnabled = !playing
        self.forwardButton.isEnabled = !playing
    }
    
    @IBAction func backButtonDidTouchUpInside(_ sender: NSButton)
    {
        updateImage(forward: false)
    }
    
    @IBAction func forwardButtonDidTouchUpInside(_ sender: NSButton)
    {
        updateImage()
    }
    
    @IBAction func chooseFromPhotos(_ sender: NSMenuItem)
    {
//        print("CHOOSE")
//        
//        PHPhotoLibrary.shared().register(self)
//        PHPhotoLibrary.requestAuthorization { (status) in
//            switch status
//            {
//            case .authorized:
//                print("AUTHORIZED")
//                
//                let allPhotosOptions = PHFetchOptions()
//                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//                // Probably create a strong reference to these...
//                let allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
//				let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
//                let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
//                
////                print(allPhotos)
////                print(smartAlbums.firstObject)
//                
//                smartAlbums.enumerateObjects { (collection, index, pointer) in
//                    print(collection)
//                    print(index)
//                    // Set this to true when we are done processing
//                    print(pointer)
//                }
//                
////                for album in smartAlbums {
////                    print(album)
////                }
//                
//                print(userCollections)
//                
//                
//
//            case .denied:
//                print("DENIED")
//            case .notDetermined:
//                print("NOT DETERMINED")
//            case .restricted:
//                print("RESTRICTED")
//            default:
//                break
//            }
//        }
    }
    
    @IBAction func open(_ sender: NSMenuItem)
    {
        print("OPEN")
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        guard let window = view.window else { return }
        
        panel.beginSheetModal(for: window) { result in
            switch result {
            case .OK:
                panel.orderOut(self)
                
                DispatchQueue.main.async { [weak self] in
                    self?.updateProgressBar(with: .indeterminate)
                }
                
                guard let directory = panel.urls.first else { return }
                
				let contents = FileManager.default.imagesIn(directory: directory)
                
                DispatchQueue.main.async { [weak self] in
                    self?.updateProgressBar(with: .empty)
                }
                
                let max = Double(contents.count)
                
                MainViewModel.loadImages(from: contents, progress: { current in
                    DispatchQueue.main.async { [weak self] in
                        self?.updateProgressBar(with: .updating(value: current, max: max))
                    }
                }, completion: { (images) in
                    DispatchQueue.main.async { [weak self] in
                        self?.updateProgressBar(with: .hidden)
                        self?.viewModel.images = images
                        
                        // Start the timer
                        self?.startTime = Date()
                        self?.playing = true
                        CVDisplayLinkStart(self!.displayLink)
                    }
                })
            default:
                break
            }
        }
    }
    
    func updateProgressBar(with state: ProgressBarState)
    {
        switch state
        {
        case .hidden:
            progressBar.isHidden = true
            progressBar.stopAnimation(nil)
        case .empty:
            progressBar.isIndeterminate = false
            progressBar.doubleValue = 0
        case .indeterminate:
            progressBar.isHidden = false
            progressBar.startAnimation(self)
            progressBar.isIndeterminate = true
        case .updating(let value, let max):
            progressBar.maxValue = max
            progressBar.doubleValue = value
        }
    }
}

extension MainViewController: PHPhotoLibraryAvailabilityObserver
{
    func photoLibraryDidBecomeUnavailable(_ photoLibrary: PHPhotoLibrary) {
        print("Photos is unavailable")
    }
}
