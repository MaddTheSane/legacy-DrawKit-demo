//
//  GCSExportOptionsController.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 1/2/18.
//  Copyright © 2018 DrawKit. All rights reserved.
//

import Cocoa


@objc protocol GCSExportControllerDelegate: NSObjectProtocol {
	@objc(performExportType:withOptions:)
	func performExport(type: GCSExportFileTypes, withOptions options: [NSBitmapImageRep.PropertyKey: Any])
}

final class GCSExportOptionsController: NSObject {
	@IBOutlet var exportAccessoryView: NSView!
	@IBOutlet weak var exportFormatPopUpButton: NSPopUpButton!
	@IBOutlet weak var exportResolutionPopUpButton: NSPopUpButton!
	@IBOutlet weak var exportIncludeGridCheckbox: NSButton!
	@IBOutlet weak var exportOptionsTabView: NSTabView!
	@IBOutlet weak var jpegQualitySlider: NSSlider!
	@IBOutlet weak var jpegProgressiveCheckbox: NSButton!
	@IBOutlet weak var pngInterlaceCheckbox: NSButton!
	@IBOutlet weak var tiffCompressionTypePopUpButton: NSPopUpButton!
	@IBOutlet weak var tiffAlphaCheckbox: NSButton!
	
	private weak var mSavePanel: NSSavePanel?
	private var optionsDict: [NSBitmapImageRep.PropertyKey: Any] = [:]
	private var mFileType: GCSExportFileTypes = .PDF

	/// allows export of the drawing as PDF, etc.
	func beginExportDialog(withParentWindow parent: NSWindow, delegate: GCSExportControllerDelegate) {
		if optionsDict.count == 0 {
			optionsDict[.compressionFactor] = Float(0.67)
			optionsDict[.dkExportPropertiesResolution] = 72
		}
		
		let sp = NSSavePanel()
		
		sp.accessoryView = exportAccessoryView
		mSavePanel = sp
		mFileType = .PDF
		displayOptions(forFileType: mFileType)
		
		sp.prompt = NSLocalizedString("Export", comment: "")
		sp.message = NSLocalizedString("Export The Drawing", comment: "")
		sp.canSelectHiddenExtension = true
		
		if let nfsv = (delegate as AnyObject).displayName, let nfsv2 = nfsv {
			sp.nameFieldStringValue = nfsv2
		}
		
		sp.beginSheetModal(for: parent) { (result) in
			guard result == .OK else {
				return
			}
			// call the delegate to perform the export with the data we've obtained from the user.
			
			self.optionsDict[.gcExportedFileURL] = sp.url
			
			LogEvent(.fileEvent, "export controller completed (OK), type = \(self.mFileType.rawValue), dict = \(self.optionsDict)")
			
			delegate.performExport(type: self.mFileType, withOptions: self.optionsDict)
		}
	}

	@IBAction func formatPopUpAction(_ sender: Any?) {
		guard let tag2 = (sender as AnyObject?)?.selectedItem,
			let tag = tag2?.tag,
			let newFileType = GCSExportFileTypes(rawValue: tag) else {
			return
		}
		
		mFileType = newFileType
		
		displayOptions(forFileType: newFileType)
	}
	
	@IBAction func resolutionPopUpAction(_ sender: Any?) {
		guard let tag2 = (sender as AnyObject?)?.selectedItem,
			let tag = tag2?.tag else {
				return
		}

		optionsDict[NSBitmapImageRep.PropertyKey.dkExportPropertiesResolution] = tag
	}

	@IBAction func formatIncludeGridAction(_ sender: Any?) {
		let newGrid: Bool = {
			if let newState = (sender as? NSButton)?.state {
				return newState == .on
			}
			
			return false
		}()
		
		optionsDict[.gcIncludeGridInExportedFile] = newGrid
	}

	@IBAction func jpegQualityAction(_ sender: Any?) {
		let newFloat: Float = {
			if let float2 = (sender as AnyObject?)?.floatValue {
				return float2
			}
			
			return 0.67
		}()
		
		optionsDict[.compressionFactor] = newFloat
	}

	@IBAction func jpegProgressiveAction(_ sender: Any?) {
		let newGrid: Bool = {
			if let newState = (sender as? NSButton)?.state {
				return newState == .on
			}
			
			return false
		}()

		optionsDict[.progressive] = newGrid
	}

	@IBAction func tiffCompressionAction(_ sender: Any?) {
		guard let tag2 = (sender as AnyObject?)?.selectedItem,
			let tag = tag2?.tag else {
				return
		}

		optionsDict[.compressionMethod] = tag
	}
	
	@IBAction func tiffAlphaAction(_ sender: Any?) {
		let newGrid: Bool = {
			if let newState = (sender as? NSButton)?.state {
				return newState == .on
			}
			
			return false
		}()

		optionsDict[.dkExportedImageHasAlpha] = newGrid
	}

	@IBAction func pngInterlaceAction(_ sender: Any?) {
		let newGrid: Bool = {
			if let newState = (sender as? NSButton)?.state {
				return newState == .on
			}
			
			return false
		}()

		optionsDict[.interlaced] = newGrid
	}
	
	func displayOptions(forFileType type: GCSExportFileTypes) {
		exportFormatPopUpButton.selectItem(withTag: type.rawValue)
		
		if type == .PDF {
			exportResolutionPopUpButton.isEnabled = false
		} else {
			exportResolutionPopUpButton.isEnabled = true
		}
		
		// set controls in options to match current dict state
		jpegQualitySlider.floatValue = (optionsDict[.compressionFactor] as? Float) ?? 0
		jpegProgressiveCheckbox.state = ((optionsDict[.progressive] as? Bool) ?? false) ? .on : .off
		pngInterlaceCheckbox.state = ((optionsDict[.interlaced] as? Bool) ?? false) ? .on : .off
		tiffCompressionTypePopUpButton.selectItem(withTag: (optionsDict[.compressionMethod] as? Int) ?? 0)
		tiffAlphaCheckbox.state = ((optionsDict[.dkExportedImageHasAlpha] as? Bool) ?? false) ? .on : .off
		exportResolutionPopUpButton.selectItem(withTag: (optionsDict[.dkExportPropertiesResolution] as? Int) ?? 72)
		
		let rft: String
		
		switch type {
		case .JPEG:
			exportOptionsTabView.selectTabViewItem(at: 1)
			rft = kUTTypeJPEG as String
			
		case .PNG:
			exportOptionsTabView.selectTabViewItem(at: 2)
			rft = kUTTypePNG as String
			
		case .TIFF:
			exportOptionsTabView.selectTabViewItem(at: 3)
			rft = kUTTypeTIFF as String

			
		default:
			exportOptionsTabView.selectTabViewItem(at: 0)
			rft = kUTTypePDF as String
		}
		mSavePanel?.allowedFileTypes = [rft]
	}
}
