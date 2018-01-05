//
//  GCSObjectInspector.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 1/5/18.
//  Copyright © 2018 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.DKDrawkitInspectorBase
import DKDrawKit.DKDrawableObject
import DKDrawKit.DKShapeGroup
import DrawKitSwift

let metadataKeyIdentifier = NSUserInterfaceItemIdentifier("key")

class GCSObjectInspector: DKDrawkitInspectorBase {
	private enum SelectedItems: Int {
		case none = 0
		case multiple = 1
		case single = 2
		case group = 3
	}
	
	private enum MetadataType: Int {
		case string = 0
		case integer = 1
		case float = 2
	}
	
	@IBOutlet weak var genInfoAngleField: NSTextField!
	@IBOutlet weak var genInfoHeightField: NSTextField!
	@IBOutlet weak var genInfoLocationXField: NSTextField!
	@IBOutlet weak var genInfoLocationYField: NSTextField!
	@IBOutlet weak var genInfoStyleNameField: NSTextField!
	@IBOutlet weak var genInfoTypeField: NSTextField!
	@IBOutlet weak var genInfoWidthField: NSTextField!
	@IBOutlet weak var genInfoCoordinateRadioButtons: NSMatrix!
	
	@IBOutlet weak var multiInfoItemCountField: NSTextField!
	@IBOutlet weak var groupInfoItemCountField: NSTextField!
	@IBOutlet weak var mainTabView: NSTabView!
	@IBOutlet weak var metaAddItemButton: NSPopUpButton!
	@IBOutlet weak var metaRemoveItemButton: NSButton!
	@IBOutlet weak var metaTableView: NSTableView!
	@IBOutlet weak var objectTabView: NSTabView!
	
	@IBOutlet weak var lockIconImageWell: NSImageView!
	
	var sel: DKDrawableObject?
	var convertCoordinates = true

	private func updateTab(at tab: SelectedItems, withSelection sel: [DKDrawableObject]?) {
		self.sel = nil
		
		switch tab {
		case .none:
			break
			
		case .multiple:
			multiInfoItemCountField.integerValue = sel!.count
			
		case .group:
			updateGroupTab(withObject: sel!.last as? DKShapeGroup)
			
		case .single:
			self.sel = sel!.last
			updateSingleItemTab(with: self.sel!)
		}
	}
	
	func updateGroupTab(withObject group: DKShapeGroup?) {
		groupInfoItemCountField.integerValue = group?.groupObjects.count ?? 0
	}
	
	func updateSingleItemTab(with obj: DKDrawableObject) {
		var cFactor: CGFloat = 1
		var loc = obj.location
		
		if convertCoordinates {
			cFactor = 1 / obj.drawing.unitToPointsConversionFactor
			loc = obj.drawing.gridLayer!.gridLocation(for: loc)
		}
		
		if obj is DKDrawablePath || obj.locked {
			genInfoAngleField.isEnabled = false
			genInfoWidthField.isEnabled = false
			genInfoHeightField.isEnabled = false
		} else {
			genInfoAngleField.isEnabled = true
			genInfoWidthField.isEnabled = true
			genInfoHeightField.isEnabled = true
		}
		
		genInfoAngleField.objectValue = obj.angleInDegrees
		genInfoWidthField.objectValue = obj.size.width * cFactor
		genInfoHeightField.objectValue = obj.size.height * cFactor
		
		genInfoLocationXField.objectValue = loc.x
		genInfoLocationYField.objectValue = loc.y
		genInfoTypeField.stringValue = obj.className
		
		if obj.locked {
			genInfoLocationXField.isEnabled = false
			genInfoLocationYField.isEnabled = false
			lockIconImageWell.image = NSImage(named: .lockLockedTemplate)
			metaTableView.isEnabled = false
			metaAddItemButton.isEnabled = false
			metaRemoveItemButton.isEnabled = false
		} else {
			genInfoLocationXField.isEnabled = true
			genInfoLocationYField.isEnabled = true
			lockIconImageWell.image = NSImage(named: .lockUnlockedTemplate)
			metaTableView.isEnabled = true
			metaAddItemButton.isEnabled = true
			metaRemoveItemButton.isEnabled = true
		}
		
		if let obj = obj as? DKShapeGroup {
			groupInfoItemCountField.integerValue = obj.groupObjects.count
		} else {
			groupInfoItemCountField.stringValue = "n/a"
		}
		
		if let style = obj.style {
			if let cs = style.name {
				genInfoStyleNameField.stringValue = cs
			} else {
				genInfoStyleNameField.stringValue = "(unnamed)"
			}
		} else {
			genInfoStyleNameField.stringValue = "none"
		}
		
		metaTableView.reloadData()
	}
	
	
	@objc private func objectChanged(_ note: Notification!) {
		if (note.object as AnyObject?) === sel {
			updateSingleItemTab(with: sel!)
		}
	}
	
	@objc private func styleChanged(_ note: Notification!) {
		if (note.object as AnyObject?) === sel?.style {
			updateSingleItemTab(with: sel!)
		}
	}

	@IBAction func addMetaItemAction(_ sender: Any?) {
		struct KeySeed {
			static var seed = 1
		}
		
		let tag: MetadataType = {
			if let sender = sender as AnyObject?,
				let selItem = sender.selectedItem,
				let aTag = selItem?.tag {
				return MetadataType(rawValue: aTag) ?? .string
			}
			
			return .string
		}()
		let key = "** change me \(KeySeed.seed) **"
		KeySeed.seed += 1
		
		switch tag {
		case .string:
			sel?.set("", forKey: key)
			
		case .integer:
			sel?.set(Int(), forKey: key)
			
		case .float:
			sel?.set(CGFloat(), forKey: key)
		}
	}
	
	@IBAction func removeMetaItemAction(_ sender: Any?) {
		let selRow = metaTableView.selectedRow
		let keys = sel!.userInfo.keys.sorted()
		let oldKey = keys[selRow]
		
		sel!.removeMetadata(forKey: oldKey)
		metaTableView.reloadData()
	}
	
	@IBAction func ungroupButtonAction(_ sender: Any?) {
		// empty
	}
	
	
	@IBAction func changeCoordinatesAction(_ sender: Any?) {
		convertCoordinates = (sender as AnyObject).selectedCell()?.tag == 0
		updateSingleItemTab(with: sel!)
	}
	
	
	@IBAction func changeLocationAction(_ sender: Any?) {
		guard let mSel = sel else {
			return
		}
		var loc = NSPoint(x: genInfoLocationXField.doubleValue, y: genInfoLocationYField.doubleValue)
		
		if convertCoordinates, let gridLayer = mSel.drawing.gridLayer {
			loc = gridLayer.point(forGridLocation: loc)
		}
		
		mSel.location = loc
		(mSel.drawing.undoManager as AnyObject?)?.setActionName(NSLocalizedString("Position Object", comment: "undo for position object"))
	}
	
	@IBAction func changeSizeAction(_ sender: Any?) {
		guard let sel = self.sel else {
			return
		}
		var size = NSSize(width: genInfoWidthField.doubleValue, height: genInfoHeightField.doubleValue)
		var cFactor: CGFloat = 1
		
		if convertCoordinates {
			cFactor = sel.drawing.unitToPointsConversionFactor
			size.width *= cFactor
			size.height *= cFactor
		}
		
		sel.size = size
		(sel.drawing.undoManager as AnyObject?)?.setActionName(NSLocalizedString("Set Object Size", comment: "undo for size object"))
	}
	
	@IBAction func changeAngleAction(_ sender: Any?) {
		if let sender = sender as AnyObject?,
			let scaleVal2 = sender.objectValue,
			let scaleVal = scaleVal2 as? CGFloat,
			let sel = sel {
			let radians = scaleVal * .pi
			sel.angle = radians
			(sel.drawing.undoManager as AnyObject?)?.setActionName(NSLocalizedString("Set Object Angle", comment: "undo for angle object"))
		}
	}
	
	// MARK: - As a DKDrawkitInspectorBase
	override func redisplayContent(forSelection selection2: [DKDrawableObject]?) {
		// this inspector really needs to work with the unfiltered selection, so fetch it:
		
		var selection: [DKDrawableObject]? = selection2
		
		if let layer = currentActiveLayer as? DKObjectDrawingLayer,
			let sel3 = layer.selection {
			selection = Array(sel3)
		}

		var tab: SelectedItems
		let oc = selection?.count ?? 0
		
		if oc == 0 {
			sel = nil
			tab = .none
		} else if oc > 1 {
			sel = nil
			tab = .multiple
		} else {
			tab = .single
		}
		
		metaTableView.reloadData()
		updateTab(at: tab, withSelection: selection)
		mainTabView.selectTabViewItem(at: tab.rawValue)
	}
	
	// MARK: - As an NSWindowController
	override func windowDidLoad() {
		super.windowDidLoad()
		(window as! NSPanel).isFloatingPanel = true
		(window as! NSPanel).becomesKeyOnlyIfNeeded = true
		mainTabView.selectTabViewItem(at: SelectedItems.none.rawValue)
		
		convertCoordinates = true
		
		NotificationCenter.default.addObserver(self, selector: #selector(GCSObjectInspector.objectChanged(_:)), name: NSNotification.Name.dkDrawableDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(GCSObjectInspector.styleChanged(_:)), name: NSNotification.Name.dkStyleNameChanged, object: nil)
	}
}

// MARK: - As part of NSTableDataSource Protocol
extension GCSObjectInspector: NSTableViewDataSource, NSTableViewDelegate {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return sel?.metadataKeys?.count ?? 0
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row rowIndex: Int) -> Any? {
		guard let mSel = sel else {
			return nil
		}

		let keys = mSel.metadataKeys!.sorted()
		let key = keys[rowIndex]
		
		if tableColumn?.identifier == metadataKeyIdentifier {
			return key
		} else {
			return mSel.metadataItem(forKey: key)?.value
		}
	}
	
	func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row rowIndex: Int) {
		guard let mSel = sel else {
			return
		}
		
		let keys = mSel.metadataKeys!.sorted()
		let oldKey = keys[rowIndex]
		
		if tableColumn?.identifier == metadataKeyIdentifier {
			let item = mSel.metadataItem(forKey: oldKey)!
			
			mSel.removeMetadata(forKey: oldKey)
			mSel.setMetadataItem(item, forKey: object as! String)
		} else {
			mSel.setMetadataItemValue(object, forKey: oldKey)
		}
	}
	
	func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
		return !(sel?.locked ?? true)
	}
}
