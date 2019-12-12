//
//  MainViewController.swift
//  Image Stream
//
//  Created by Joshua Grant on 12/11/19.
//  Copyright © 2019 Joshua Grant. All rights reserved.
//

import Cocoa

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
    
    // MARK: Interface outlets
    
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var fpsLabel: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        progressBar.isHidden = true
        fpsLabel.isHidden = !Defaults.showFPS
    }
    
    // MARK: - Functions
    
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
                
                self.progressBar.isHidden = false
                self.progressBar.startAnimation(self)
                self.progressBar.isIndeterminate = true
                
                guard let directory = panel.urls.first else { return }
                
                let contents = MainViewController.contentsOf(directory: directory)
                
                self.progressBar.isIndeterminate = false
                self.progressBar.doubleValue = 0
                self.progressBar.maxValue = Double(contents.count)
                
                MainViewModel.loadImages(from: contents, progress: { current in
                    DispatchQueue.main.async { [weak self] in
                        self?.progressBar.doubleValue = current
                    }
                }, completion: { (images) in
                    DispatchQueue.main.async { [weak self] in
                        self?.progressBar.isHidden = true
                        self?.progressBar.stopAnimation(sender)
                        self?.viewModel.images = images
                        self?.imageView.image = images.first?.image
                    }
                })
            default:
                break
            }
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
}
