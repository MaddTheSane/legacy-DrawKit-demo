//
//  GCSStyleManagerDialog.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 1/9/18.
//  Copyright © 2018 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.DKStyle
import DKDrawKit.DKStyleRegistry

class GCSStyleManagerDialog : NSWindowController, DKStyleRegistryDelegate {
	@IBOutlet weak var addCategoryButton: NSButton!
	@IBOutlet weak var deleteCategoryButton: NSButton!
	@IBOutlet weak var styleCategoryList: GCSTableView!
	@IBOutlet weak var styleIconMatrix: NSMatrix!
	@IBOutlet weak var styleNameTextField: NSTextField!
	@IBOutlet weak var previewImageWell: NSImageView!
	@IBOutlet weak var styleListTabView: NSTabView!
	@IBOutlet weak var styleBrowserList: NSTableView!
	@IBOutlet weak var deleteStyleButton: NSButton!
	@IBOutlet weak var keyChangeDialogController: GCSBasicDialogController!
	
	weak var selectedStyle: DKStyle?
	var selectedCategory: DKCategoryName?
	
	@IBAction func addCategoryAction(_ sender: Any!) {
		struct CatSeed {
			static var seed = 0
		}
		
		CatSeed.seed += 1
		let newCat = DKCategoryName("untitled category \(CatSeed.seed)")
		
		styles.addCategory(newCat)
		styleCategoryList.reloadData()
		
		let indx = styles.allCategories.index(of: newCat)!
		
		styleCategoryList.selectRowIndexes(IndexSet(integer: indx), byExtendingSelection: false)
		styleCategoryList.editColumn(1, row: indx, with: nil, select: true) // TO DO - !! look up column in case user has reordered them
	}
	
	@IBAction func deleteCategoryAction(_ sender: Any!) {
		if selectedCategory != .defaultCategoryName {
			styles.removeCategory(selectedCategory!)
			updateUI(forCategory: .defaultCategoryName)
		}
	}
	
	@IBAction func styleIconMatrixAction(_ sender: Any!) {
		if let selCel = (sender as AnyObject?)?.representedObject,
			let repStyle = selCel as? DKStyle {
			selectedStyle = repStyle
			
			updateUI(for: repStyle)
		}
	}
	
	@IBAction func styleKeyChangeAction(_ sender: Any!) {
		// empty
	}
	
	/// remove the style from the registry. If the style is in use nothing bad happens - the style is simply unregistered.
	@IBAction func styleDeleteAction(_ sender: Any!) {
		let alert = NSAlert()
		alert.messageText = "Really Remove ‘\(selectedStyle!.name!)’ From Registry?"
		alert.informativeText = "Removing the style from the registry does not affect any object that might be using the style, but it may prevent the style being used in another document later."
		alert.addButton(withTitle: "Remove")
		alert.addButton(withTitle: "Cancel")

		alert.beginSheetModal(for: window!) { (returnCode) in
			guard returnCode == .alertFirstButtonReturn else {
				return
			}
			DKStyleRegistry.unregisterStyle(self.selectedStyle!)
			self.updateUI(forCategory: self.selectedCategory!)
		}
	}
	
	@IBAction func registryResetAction(_ sender: Any!) {
		// warn the user of the consequences, then remove everything from the registry except the defaults
		let alert = NSAlert()
		alert.messageText = "Really Remove All Styles From Registry?"
		alert.informativeText = "Removing styles from the registry does not affect any object that might be using them, but it may prevent the styles being used in another document later."
		alert.addButton(withTitle: "Clear")
		alert.addButton(withTitle: "Cancel")
		
		alert.beginSheetModal(for: window!) { (returnCode) in
			guard returnCode == .alertFirstButtonReturn else {
				return
			}
			// remove all styles except the defaults - this restores the registry to the "first run" state
			DKStyleRegistry.resetRegistry()
			self.styleCategoryList.reloadData()
			self.updateUI(forCategory: .defaultCategoryName)
		}
	}
	
	@IBAction func saveStylesToFileAction(_ sender: Any!) {
		let sp = NSSavePanel()
		sp.allowedFileTypes = ["styles"]
		
		sp.beginSheetModal(for: window!) { (result) in
			guard result == .OK else {
				return
			}
			let path = sp.url!
			do {
				try DKStyleRegistry.shared.write(to: path, options: .atomic)
			} catch {
				NSApp.presentError(error)
			}
		}
	}
	
	@IBAction func loadStylesFromFileAction(_ sender: Any!) {
		let op = NSOpenPanel()
		op.allowedFileTypes = ["styles"]
		
		
		op.beginSheetModal(for: window!) { (result) in
			guard result == .OK else {
				return
			}
			
			// just overwrite the current reg from the file
			let path = op.url!
			do {
				try DKStyleRegistry.shared.read(from:path, mergeOptions: .replaceExistingStyles, merge: self)
				self.styleCategoryList.reloadData()
				self.updateUI(forCategory: .defaultCategoryName)
			} catch {
				
			}
		}
	}
	
	
	var styles: DKStyleRegistry {
		return DKStyleRegistry.shared
	}
	
	// MARK: -
	
	func populateMatrixWithStyle(inCategory cat: DKCategoryName) {
		let obj = styles.objects(inCategory: cat)
		
		for cols in 0 ..< styleIconMatrix.numberOfColumns {
			styleIconMatrix.removeColumn(cols)
		}
		
		let num = obj.count
		let cols = 4
		var rows = num / cols
		if (num % cols) > 0 {
			rows += 1
		}
		
		var x = 0
		var y = 0

		LogEvent(.reactiveEvent, "setting up matrix for '\(cat)' (\(num) items)")
		
		styleIconMatrix.renewRows(rows, columns: cols)
		styleIconMatrix.sizeToCells()
		let cellSize = styleIconMatrix.cellSize
		
		if num > 0 {
			for style in obj {
				let swatch = style?.standardStyleSwatch.copy() as! NSImage
				swatch.size = cellSize
				
				let cell = styleIconMatrix.cell(atRow: y, column: x)
				cell?.image = swatch
				
				cell?.representedObject = style
				styleIconMatrix.setToolTip(style?.name, for: cell!)
				
				x += 1
				if x >= cols {
					x = 0
					if y * cols < num {
						styleIconMatrix.addRow()
						y += 1
					}
				} else {
					styleIconMatrix.addColumn()
				}
			}
			
			while x < cols {
				let cell = styleIconMatrix.cell(atRow: y, column: x)
				x += 1
				cell?.image = nil
				cell?.representedObject = nil
				styleIconMatrix.setToolTip(nil, for: cell!)
				cell?.isEnabled = false
			}
		}
		
		styleIconMatrix.needsDisplay = true
	}
	
	func updateUI(for style: DKStyle!) {
		styleNameTextField.stringValue = style.name!
		styleNameTextField.isEnabled = true
		previewImageWell.image = style.standardStyleSwatch
		
		// reload table which will set the checkboxes for categories containing this style

		styleCategoryList.reloadData()
	}
	
	func updateUI(forCategory category: DKCategoryName) {
		selectedCategory = category
		populateMatrixWithStyle(inCategory: category)
		styleBrowserList.reloadData()
		styleBrowserList.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
		
		if styles.allKeys(inCategory: category).count > 0 {
			styleIconMatrix.selectCell(atRow: 0, column: 0)
			styleIconMatrix.sendAction()
		} else {
			selectedStyle = nil
			styleCategoryList.reloadData()
			styleCategoryList.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
		}
		
		// if the default category, disable the "delete" button
		if category == .defaultCategoryName {
			deleteCategoryButton.isEnabled = false
		} else {
			deleteCategoryButton.isEnabled = true
		}
	}
	
	// MARK: - As an NSWindowController
	override func windowDidLoad() {
		super.windowDidLoad()
		
		var row = styleCategoryList.selectedRow
		
		if row == -1 {
			row = styles.allCategories.index(of: .defaultCategoryName)!
			styleCategoryList.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
		}
	}
}

extension GCSStyleManagerDialog: NSTableViewDataSource, NSTableViewDelegate {
	// MARK: - As an NSTableView delegate
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		if (notification.object as AnyObject?) === styleCategoryList {
			// when the user selects a different category in the list, the matrix is repopulated with the styles in that category

			let catItem = styleCategoryList.selectedRow
			
			LogEvent(.reactiveEvent, "selection change: \(catItem)")
			
			if catItem != -1 {
				let cat = styles.allCategories[catItem]
				updateUI(forCategory: cat)
			}
		} else if (notification.object as AnyObject?) === styleBrowserList {
			let rowIndex = styleBrowserList.selectedRow
			let sortedKeys = styles.allSortedKeys(inCategory: selectedCategory!)
			
			if rowIndex >= 0, rowIndex < sortedKeys.count {
				let key = sortedKeys[rowIndex]
				
				selectedStyle = styles.object(forKey: key)
				updateUI(for: selectedStyle)
			}
		}
	}
	
	func tableView(_ aTableView: NSTableView, willDisplayCell aCell: Any, for aTableColumn: NSTableColumn?, row rowIndex: Int) {
		if aTableView === styleCategoryList, let aCell = aCell as? NSCell {
			let cat = styles.allCategories[rowIndex]
			let anEnable = cat != .defaultCategoryName
			aCell.isEnabled = anEnable
		}
	}
	
	func tableView(_ aTableView: NSTableView, shouldEdit aTableColumn: NSTableColumn?, row rowIndex: Int) -> Bool {
		if aTableView === styleCategoryList {
			let cat = styles.allCategories[rowIndex]
			return cat != .defaultCategoryName
		}
		
		return true
	}
	
	//MARK: - As part of NSTableDataSource Protocol
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		if tableView === styleCategoryList {
			return styles.allCategories.count
		} else if tableView === styleBrowserList {
			return styles.allKeys(inCategory: selectedCategory!).count
		} else {
			return 0
		}
	}
	
	
	func tableView(_ aTableView: NSTableView, objectValueFor aTableColumn: NSTableColumn?, row rowIndex: Int) -> Any? {
		let identifier = aTableColumn?.identifier
		
		if aTableView === styleCategoryList {
			if identifier == styleCategoryListNameIdentifier {
				return styles.allCategories[rowIndex]
			} else if identifier == styleCategoryListKeyIdentifier {
				// checkbox for inclusion in category for the selected style

				let cat = styles.allCategories[rowIndex]
				let key = selectedStyle!.uniqueKey
				
				let include = styles.key(key, existsInCategory: cat)
				
				return include
			} else {
				return nil
			}
		} else if aTableColumn === styleBrowserList {
			let sortedKeys = styles.allSortedKeys(inCategory: selectedCategory!)
			let key = sortedKeys[rowIndex]
			
			if identifier == styleBrowserListNameIdentifier {
				return styles.styleName(forKey: key)
			} else if identifier == styleBrowserListImageIdentifier {
				let style = styles.style(forKey: key)!
				let swatch = style.standardStyleSwatch.copy() as! NSImage
				
				swatch.size = NSSize(width: 32, height: 32)
				
				return swatch
			}
		}
		
		return nil
	}
	
	func tableView(_ aTableView: NSTableView, setObjectValue anObject: Any?, for aTableColumn: NSTableColumn?, row rowIndex: Int) {
		let identifier = aTableColumn?.identifier
		
		if aTableView === styleCategoryList {
			if identifier == styleCategoryListNameIdentifier, let anObject = anObject as? String {
				LogEvent(.reactiveEvent, "renaming category ‘\(selectedCategory!)’ to ‘\(anObject)’");
				let newName = DKCategoryName(anObject)
				
				styles.renameCategory(selectedCategory!, to: newName)
				aTableView.abortEditing()
				// renaming will reorder the category list, so need to reload the list and change selection

				aTableView.reloadData()
				
				let indx = styles.allCategories.index(of: newName)!
				aTableView.selectRowIndexes(IndexSet(integer: indx), byExtendingSelection: false)
				styleBrowserList.reloadData()
			} else if identifier == styleCategoryListKeyIdentifier, rowIndex != -1, let anObject = anObject as? Bool {
				// the user hit the "included" checkbox. This will add or remove the selected style from the selected category
				// accordingly
				let cat = styles.allCategories[rowIndex]
				let key = selectedStyle!.uniqueKey
				
				// the "all items" category can't be edited
				guard cat != .defaultCategoryName else {
					return
				}
				
				if anObject {
					// add to category (which must exist as it's listed in the table, so pass NO for create)
					LogEvent(.reactiveEvent, "the style key ‘\(key)’ is being added to category ‘\(cat)’");
					
					styles.addKey(key, toCategory: cat, createCategory: false)
				} else {
					// remove from category

					LogEvent(.reactiveEvent, "the style key ‘\(key)’ is being removed from category ‘\(cat)’");

					styles.removeKey(key, fromCategory: cat)
				}
				
				aTableView.reloadData()
				
				if cat == selectedCategory {
					populateMatrixWithStyle(inCategory: cat)
				}
			}
		}
	}
}

let styleCategoryListNameIdentifier = NSUserInterfaceItemIdentifier("catName")
let styleCategoryListKeyIdentifier = NSUserInterfaceItemIdentifier("keyInCat")
let styleBrowserListNameIdentifier = NSUserInterfaceItemIdentifier("name")
let styleBrowserListImageIdentifier = NSUserInterfaceItemIdentifier("image")

