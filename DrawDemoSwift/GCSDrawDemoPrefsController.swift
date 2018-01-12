//
//  GCSDrawDemoPrefsController.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/14/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.DKObjectDrawingLayer
import DKDrawKit.DKBSPObjectStorage

final class GCSDrawDemoPrefsController: NSWindowController {
	@IBOutlet weak var qualityThrottlingCheckbox: NSButton!
	@IBOutlet weak var undoSelectionsCheckbox: NSButton!
	@IBOutlet weak var storageTypeCheckbox: NSButton!

    override func windowDidLoad() {
        super.windowDidLoad()
		
		qualityThrottlingCheckbox.state = DrawDemoDocument.defaultQualityModulation ? .on : .off
		undoSelectionsCheckbox.state = DKObjectDrawingLayer.defaultSelectionChangesAreUndoable ? .on : .off
		storageTypeCheckbox.state = .off
	}

	@IBAction func qualityThrottlingAction(_ sender: NSButton?) {
		if sender?.state == .on {
			DrawDemoDocument.defaultQualityModulation = true
		} else {
			DrawDemoDocument.defaultQualityModulation = false
		}
	}
	
	@IBAction func undoableSelectionAction(_ sender: NSButton?) {
		if sender?.state == .on {
			DKObjectDrawingLayer.defaultSelectionChangesAreUndoable = true
		} else {
			DKObjectDrawingLayer.defaultSelectionChangesAreUndoable = false
		}
	}

	@IBAction func setStorageTypeAction(_ sender: NSButton?) {
		if sender?.state == .off {
			DKObjectOwnerLayer.storageClass = DKLinearObjectStorage.self
		} else {
			DKObjectOwnerLayer.storageClass = DKBSPObjectStorage.self
		}
		
		UserDefaults.standard.set(NSStringFromClass(DKObjectOwnerLayer.storageClass), forKey: "DKObjectStorageClass")
	}
}
