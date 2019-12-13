//
//  MainViewController.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/11/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa

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
    
    var idealFPS: Int = 100
    var frames: Int = 0
    var startTime: Date?
    
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        progressBar.isHidden = true
        fpsLabel.isHidden = !Defaults.showFPS
    }
    
    // TODO: Clean up
    func updateLabel(fps: Double)
    {
        DispatchQueue.main.async {
            self.fpsLabel.stringValue = "\(Int(fps))"
        }
    }
    
    // TODO: Clean up
    func updateImage()
    {
        DispatchQueue.main.async {
            self.imageView.image = self.viewModel.images[self.viewModel.currentImage].image
            
            self.viewModel.currentImage += 1
            
            if self.viewModel.currentImage >= self.viewModel.images.count // Maybe make this a constant
            {
                self.viewModel.currentImage = 0
            }
            
            self.frames += 1
            self.readyForUpdate = true
        }
    }
    
    // MARK: - Functions
    
    @IBAction func idealFPSSliderValueChanged(_ sender: NSSlider)
    {
        self.idealFPS = Int(sender.doubleValue)
    }
    
    @IBAction func open(_ sender: NSMenuItem)
    {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        guard let window = view.window else { return }
        
        panel.beginSheetModal(for: window) { result in
            switch result {
            case .OK:
                panel.orderOut(self)
                
                self.updateProgressBar(with: .indeterminate)
                
                guard let directory = panel.urls.first else { return }
                
                let contents = MainViewController.contentsOf(directory: directory)
                
                self.updateProgressBar(with: .empty)
                
                let max = Double(contents.count)
                
                MainViewModel.loadImages(from: contents, progress: { current in
                    DispatchQueue.main.async { [weak self] in
                        self?.updateProgressBar(with: .updating(value: current, max: max))
                        self?.progressBar.doubleValue = current
                    }
                }, completion: { (images) in
                    DispatchQueue.main.async { [weak self] in
                        self?.updateProgressBar(with: .hidden)
                        self?.viewModel.images = images
                        
                        // Start the timer
                        self?.startTime = Date()
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
            if component.contains(".jpg") || component.contains(".png") {
                return directory.appendingPathComponent(component)
            } else {
                return nil
            }
        })
        
        return urls ?? []
    }
    
    deinit {
        CVDisplayLinkStop(displayLink)
    }
}
