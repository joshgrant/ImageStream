//
//  MainViewController.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/11/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa
import Photos

enum ProgressBarState
{
    case hidden
    case indeterminate
    case empty
    case updating(value: Double, max: Double)
}

extension NSViewController
{
    static func loadFromNib() -> Self
    {
        var objects: NSArray? = nil
        let nibName = String(describing: self)
        
        Bundle.main.loadNibNamed(nibName, owner: nil, topLevelObjects: &objects)
        
        let content = objects?.first {
            return $0 is Self
        }
        
        return content as! Self
    }
}

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
            
            guard let (origin, size) = self.imageConstraints(for: image, in: self.view.frame) else {
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
    
    func imageConstraints(for image: Image, in rect: CGRect) -> (CGPoint, CGSize)?
    {
        if Defaults.centerOnImage
        {
            let imageSize = image.image.size
            let imageAspectRatio = imageSize.width / imageSize.height
            let rectAspectRatio = rect.width / rect.height
            
            var scaleFactor: CGFloat = 1
            
            // Should we scale down?
            if imageSize.width > rect.width || imageSize.height > rect.height
            {
                if imageAspectRatio < rectAspectRatio
                {
                    scaleFactor = rect.height / imageSize.height
                }
                else
                {
                    scaleFactor = rect.width / imageSize.width
                }
            }
            
            let scaledImageSize = CGSize(width: imageSize.width * scaleFactor, height: imageSize.height * scaleFactor)
            
            let offset = CGPoint(x: rect.center.x - scaledImageSize.width / 2,
                                 y: rect.center.y - scaledImageSize.height / 2)
            
            return (offset, scaledImageSize)
        }
        else if Defaults.centerOnFace
        {
            let imageSize = image.size
            let boundingBox = image.boundingBox
            
            let fullBoundingBox = CGRect(x: boundingBox.origin.x * imageSize.width,
                                         y: boundingBox.origin.y * imageSize.height,
                                         width: boundingBox.width * imageSize.width,
                                         height: boundingBox.height * imageSize.height)
            
            let scaleFactor = idealSize / fullBoundingBox.width
            
            let scaledImageCenter = CGPoint(x: (imageSize.width / 2) * scaleFactor,
                                            y: (imageSize.height / 2) * scaleFactor)
            let scaledBoxCenter = CGPoint(x: (fullBoundingBox.origin.x + fullBoundingBox.width / 2) * scaleFactor,
                                          y: (fullBoundingBox.origin.y + fullBoundingBox.height / 2) * scaleFactor)
            
            let newSize = CGSize(width: imageSize.width * scaleFactor,
                                 height: imageSize.height * scaleFactor)
            
            // LERP between 0 and (rect.height / 6)
            // The value is based on the scrollDelta.
            // When the scroll delta is 0 (ideal size), the value should be 0
            // When the scroll delta is < 0, the value should be closer to rect.height / 6
            // We set scroll delta max to 100, it's arbitrary
            let maxOffset = (rect.height / 6)
            let percent: CGFloat = (scrollDelta / 500)
            let newVerticalOffset = min(max(maxOffset - percent * maxOffset, 0), maxOffset)
            
            // Why not multiply by greater than 1????
            let offset = CGPoint(x: (image.size.width / 2 - (fullBoundingBox.origin.x + fullBoundingBox.width / 2)) * scaleFactor,
                                 y: -(image.size.height / 2 - (fullBoundingBox.origin.y + fullBoundingBox.height / 2)) * scaleFactor - newVerticalOffset)
            
            return (offset, newSize)
        }
        
        // TODO: We should handle this case...
        return nil
    }
    
    // MARK: - Functions
    
    override func scrollWheel(with event: NSEvent) {
        idealSize += event.scrollingDeltaY
        scrollDelta += event.scrollingDeltaY
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
        print("CHOOSE")
        
        PHPhotoLibrary.shared().register(self)
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status
            {
            case .authorized:
                print("AUTHORIZED")
                
                let allPhotosOptions = PHFetchOptions()
                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                // Probably create a strong reference to these...
                let allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
                let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
                let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
                
            case .denied:
                print("DENIED")
            case .notDetermined:
                print("NOT DETERMINED")
            case .restricted:
                print("RESTRICTED")
            }
        }
        
//        imageManager.requestImage(for: <#T##PHAsset#>, targetSize: <#T##CGSize#>, contentMode: <#T##PHImageContentMode#>, options: <#T##PHImageRequestOptions?#>, resultHandler: <#T##(NSImage?, [AnyHashable : Any]?) -> Void#>)
//        PHPhotoLibrary
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
                
                let contents = MainViewController.contentsOf(directory: directory)
                
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
    
    static func contentsOf(directory: URL) -> [URL]
    {
        let contents = try? FileManager.default.contentsOfDirectory(atPath: directory.path)
        
        let urls = contents?.compactMap({ component -> URL? in
            if component.contains(".jpg") || component.contains(".png") || component.contains(".jpeg")
            {
                return directory.appendingPathComponent(component)
            }
            else
            {
                return nil
            }
        })
        
        return urls ?? []
    }
}

extension MainViewController: PHPhotoLibraryAvailabilityObserver
{
    func photoLibraryDidBecomeUnavailable(_ photoLibrary: PHPhotoLibrary) {
        print("Photos is unavailable")
    }
}
