//
//  GCSStyleInspector.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 1/3/18.
//  Released under the Creative Commons license 2007 Apptree.net.
//
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
//  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
//

import Cocoa
import DKDrawKit
import DKDrawKit.DKStyle
import DKDrawKit.DKDrawkitInspectorBase
import DKDrawKit.DKDashable
import DKDrawKit.DKRasterizer
import CoreImage.CIFilter

private let classOutlineColumnIdentifier = NSUserInterfaceItemIdentifier("class")
private let enabledOutlineColumnIdentifier = NSUserInterfaceItemIdentifier("enabled")

final class GCSStyleInspector: DKDrawkitInspectorBase, GCSDashEditorDelegate, GCSDashEditViewDelegate, GCSBasicDialogDelegate {
	/// tab indexes for main tab view
	enum Tab: Int {
		case stroke = 0
		case fill
		case multipleItems
		case noItems
		case stylePreview
		case image
		case filter
		case label
		case hatch
		case pathDecor
		case blendMode
	}
	
	/// Tags used to selectively hide or disable particular items in the UI (such as labels) without needing
	/// an explicit outlet to them. The tags are deliberately set to arbitrary numbers that are unlikely to be accidentally set.
	public enum ItemsTag: Int {
		case zigZag = 145
		case pathDecorator
		case patternFill
		case arrowStroke
		case shadow
		case roughStroke
	}

	/// tab indexes for fill type tab view
	public enum FillType: Int {
		case solid = 0
		case gradient
		case pattern
	}
	
	/// tags in Add Renderer menu
	public enum AddRendererTag: Int {
		case stroke = 0
		case fill
		case group
		case image
		case coreEffect
		case label
		case hatch
		case arrowStroke
		case pathDecorator
		case patternFill
		case blendEffect
		case zigZagStroke
		case zigZagFill
		case roughStroke
	}

	
	@IBOutlet weak var outlineView: GCSOutlineView!
	@IBOutlet weak var tabView: NSTabView!
	@IBOutlet weak var addRendererPopUpButton: NSPopUpButton!
	@IBOutlet weak var removeRendererButton: NSButton!
	@IBOutlet weak var actionsPopUpButton: NSPopUpButton!
	
	@IBOutlet weak var dashEditController: GCSDashEditor!
	@IBOutlet weak var scriptEditController: GCSBasicDialogController!
	
	@IBOutlet weak var styleCloneButton: NSButton!
	@IBOutlet weak var styleLibraryPopUpButton: NSPopUpButton!
	@IBOutlet weak var styleLockCheckbox: NSButton!
	@IBOutlet weak var styleNameTextField: NSTextField!
	@IBOutlet weak var stylePreviewImageWell: NSImageView!
	@IBOutlet weak var styleRegisteredIndicatorText: NSTextField!
	@IBOutlet weak var styleAddToLibraryButton: NSButton!
	@IBOutlet weak var styleRemoveFromLibraryButton: NSButton!
	@IBOutlet weak var styleSharedCheckbox: NSButton!
	@IBOutlet weak var styleClientCountText: NSTextField!
	
	@IBOutlet weak var strokeControlsTabView: NSView!
	@IBOutlet weak var strokeColourWell: NSColorWell!
	@IBOutlet weak var strokeSlider: NSSlider!
	@IBOutlet weak var strokeTextField: NSTextField!
	@IBOutlet weak var strokeShadowCheckbox: NSButton!
	@IBOutlet weak var strokeShadowGroup: AnyObject!
	@IBOutlet weak var strokeShadowColourWell: NSColorWell!
	@IBOutlet weak var strokeShadowAngle: NSSlider!
	@IBOutlet weak var strokeShadowBlur: NSSlider!
	@IBOutlet weak var strokeShadowDistance: NSSlider!
	@IBOutlet weak var strokeDashPopUpButton: NSPopUpButton!
	@IBOutlet weak var strokeArrowDimensionOptions: NSPopUpButton!
	@IBOutlet weak var strokeArrowStartPopUpButton: NSPopUpButton!
	@IBOutlet weak var strokeArrowEndPopUpButton: NSPopUpButton!
	@IBOutlet weak var strokeArrowPreviewImageWell: NSImageView!
	@IBOutlet weak var strokeZZLength: NSSlider!
	@IBOutlet weak var strokeZZAmp: NSSlider!
	@IBOutlet weak var strokeZZSpread: NSSlider!
	@IBOutlet weak var strokeLineJoinSelector: NSSegmentedControl!
	@IBOutlet weak var strokeLineCapSelector: NSSegmentedControl!
	@IBOutlet weak var strokeRoughnessSlider: NSSlider!
	
	@IBOutlet weak var fillTypeTabView: NSTabView!
	@IBOutlet weak var fillControlsTabView: NSView!
	@IBOutlet weak var fillGradientControlBar: WTSGradientControl!
	@IBOutlet weak var fillGradientAddButton: NSButton!
	@IBOutlet weak var fillGradientRemoveButton: NSButton!
	@IBOutlet weak var fillGradientAngleSlider: NSSlider!
	@IBOutlet weak var fillGradientAngleTextField: NSTextField!
	@IBOutlet weak var fillGradientAngleLittleArrows: NSStepper!
	@IBOutlet weak var fillGradientRelativeToObject: NSButton!
	@IBOutlet weak var fillColourWell: NSColorWell!
	@IBOutlet weak var fillShadowCheckbox: NSButton!
	@IBOutlet weak var fillShadowGroup: AnyObject!
	@IBOutlet weak var fillShadowColourWell: NSColorWell!
	@IBOutlet weak var fillShadowAngle: NSSlider!
	@IBOutlet weak var fillShadowBlur: NSSlider!
	@IBOutlet weak var fillShadowDistance: NSSlider!
	@IBOutlet weak var fillPatternImagePreview: NSImageView!
	@IBOutlet weak var fillZZLength: NSSlider!
	@IBOutlet weak var fillZZAmp: NSSlider!
	@IBOutlet weak var fillZZSpread: NSSlider!
	
	@IBOutlet weak var imageWell: NSImageView!
	@IBOutlet weak var imageIdentifierTextField: NSTextField!
	@IBOutlet weak var imageOpacitySlider: NSSlider!
	@IBOutlet weak var imageScaleSlider: NSSlider!
	@IBOutlet weak var imageAngleSlider: NSSlider!
	@IBOutlet weak var imageClipToPathCheckbox: NSButton!
	@IBOutlet weak var imageFittingPopUpMenu: NSPopUpButton!
	
	@IBOutlet weak var ciFilterPopUpMenu: NSPopUpButton!
	@IBOutlet weak var ciFilterClipToPathCheckbox: NSButton!
	
	@IBOutlet weak var textLabelTextField: NSTextField!
	@IBOutlet weak var textIdentifierTextField: NSTextField!
	@IBOutlet weak var textLayoutPopUpButton: NSPopUpButton!
	@IBOutlet weak var textAlignmentPopUpButton: NSPopUpButton!
	@IBOutlet weak var textLabelPlacementPopUpButton: NSPopUpButton!
	@IBOutlet weak var textWrapLinesCheckbox: NSButton!
	@IBOutlet weak var textClipToPathCheckbox: NSButton!
	@IBOutlet weak var textRelativeAngleCheckbox: NSButton!
	@IBOutlet weak var textAngleSlider: NSSlider!
	@IBOutlet weak var textColourWell: NSColorWell!
	@IBOutlet weak var flowedTextInsetSlider: NSSlider!
	
	@IBOutlet weak var hatchColourWell: NSColorWell!
	@IBOutlet weak var hatchSpacingSlider: NSSlider!
	@IBOutlet weak var hatchSpacingTextField: NSTextField!
	@IBOutlet weak var hatchLineWidthSlider: NSSlider!
	@IBOutlet weak var hatchLineWidthTextField: NSTextField!
	@IBOutlet weak var hatchAngleSlider: NSSlider!
	@IBOutlet weak var hatchAngleTextField: NSTextField!
	@IBOutlet weak var hatchLeadInSlider: NSSlider!
	@IBOutlet weak var hatchLeadInTextField: NSTextField!
	@IBOutlet weak var hatchDashPopUpButton: NSPopUpButton!
	@IBOutlet weak var hatchRelativeAngleCheckbox: NSButton!
	@IBOutlet weak var hatchLineCapButton: NSSegmentedControl!
	
	@IBOutlet weak var pdControlsTabView: NSView!
	@IBOutlet weak var pdIntervalSlider: NSSlider!
	@IBOutlet weak var pdScaleSlider: NSSlider!
	@IBOutlet weak var pdNormalToPathCheckbox: NSButton!
	@IBOutlet weak var pdLeaderSlider: NSSlider!
	@IBOutlet weak var pdPreviewImage: NSImageView!
	@IBOutlet weak var pdPatternAlternateOffsetSlider: NSSlider!
	@IBOutlet weak var pdRampProportionSlider: NSSlider!
	@IBOutlet weak var pdAngleSlider: NSSlider!
	@IBOutlet weak var pdRelativeAngleCheckbox: NSButton!
	@IBOutlet weak var motifAngleSlider: NSSlider!
	@IBOutlet weak var motifRelativeAngleCheckbox: NSButton!
	
	@IBOutlet weak var blendModePopUpButton: NSPopUpButton!
	@IBOutlet weak var blendGroupAlphaSlider: NSSlider!
	@IBOutlet weak var blendGroupImagePreview: NSImageView!
	
	@IBOutlet weak var shadowAngleSlider: NSSlider!
	@IBOutlet weak var shadowDistanceSlider: NSSlider!
	@IBOutlet weak var shadowColourWell: NSColorWell!
	@IBOutlet weak var shadowBlurRadiusSlider: NSSlider!
	
	var style: DKStyle? {
		willSet {
			if let mStyle = style {
				NotificationCenter.default.removeObserver(self, name: nil, object: mStyle)
			}
		}
		didSet {
			// listen for style change notifications so we can track changes made by undo, etc
			if let mStyle = style {
				NotificationCenter.default.addObserver(self, selector: #selector(GCSStyleInspector.styleChanged(_:)), name: .dkStyleDidChange, object: mStyle)
			}
			updateUIForStyle()
		}
	}
	private var selectedRendererRef: DKRasterizer?
	private var mIsChangingGradient: Bool = false
	private var mDragItem: DKRasterizer?
	private var savedDash: DKStrokeDash?

	/// set up the UI to match the style attached
	private func updateUIForStyle() {
		selectedRendererRef = nil
		
		outlineView.reloadData()
		
		if let mStyle = style {
			outlineView.expandItem(mStyle, expandChildren: true)
			outlineView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
			
			styleLockCheckbox.isEnabled = true
			styleSharedCheckbox.state = mStyle.isStyleSharable ? .on : .off
			styleLockCheckbox.state = mStyle.locked ? .on : .off
			styleClientCountText.integerValue = Int(mStyle.countOfClients)
			
			if let styleName = mStyle.name {
				styleNameTextField.stringValue = styleName
			} else {
				styleNameTextField.stringValue = ""
			}
			
			if !mStyle.locked {
				addRendererPopUpButton.isEnabled = true
				removeRendererButton.isEnabled = true
				styleNameTextField.isEnabled = true
				styleSharedCheckbox.isEnabled = true
				//[mActionsPopUpButton setEnabled:YES];
			} else {
				addRendererPopUpButton.isEnabled = false
				removeRendererButton.isEnabled = false
				styleNameTextField.isEnabled = false
				styleSharedCheckbox.isEnabled = false
				//[mActionsPopUpButton setEnabled:NO];
			}
			
			// if the style isn't in the registry, disable the lock checkbox
			let registered = mStyle.isStyleRegistered
			
			styleRegisteredIndicatorText.isHidden = !registered
			styleAddToLibraryButton.isEnabled = !registered
			styleRemoveFromLibraryButton.isEnabled = registered
			styleCloneButton.isEnabled = true
			updateStylePreview()
		} else {
			outlineView.deselectAll(self)
			addRendererPopUpButton.isEnabled = false
			removeRendererButton.isEnabled = false
			styleNameTextField.stringValue = ""
			styleNameTextField.isEnabled = false
			styleSharedCheckbox.isEnabled = false
			styleRegisteredIndicatorText.isHidden = true
			styleAddToLibraryButton.isEnabled = false
			styleRemoveFromLibraryButton.isEnabled = false
			styleCloneButton.isEnabled = false
			styleLockCheckbox.isEnabled = false
			stylePreviewImageWell.image = nil
		}
	}
	
	private func updateStylePreview() {
		let is1 = NSSize(width: 128, height: 128)
		
		let img = style?.styleSwatch(with: is1, type: .automatic).copy() as? NSImage
		stylePreviewImageWell.image = img
	}
	
	@objc private func styleChanged(_ note: Notification) {
		if (note.object as AnyObject?) === style {
			if let mSelectedRendererRef = selectedRendererRef {
				selectTabPane(forObject: mSelectedRendererRef)
			} else {
				updateUIForStyle()
			}
			
			outlineView.reloadData()
			updateStylePreview()
		}
	}
	
	/// A style is being changed in some object - if the style being detached is our current style,
	/// then update the UI to show the new one being attached, otherwise just ignore it. This allows this
	/// UI to keep up with undo, style pasting, drag modifications and so on.
	@objc private func styleAttached(_ note: Notification) {
		if let theOldStyle = note.userInfo?[kDKDrawableOldStyleKey] as? DKStyle,
			theOldStyle === style,
			let theNewStyle = note.userInfo?[kDKDrawableNewStyleKey] as? DKStyle {
			self.style = theNewStyle
		}
	}
	
	@objc private func styleRegistered(_ note: Notification) {
		populatePopUpButton(withLibraryStyles: styleLibraryPopUpButton)
	}

	// MARK: - selecting which tab view is shown for the selected rasterizer
	
	/// Given an item in the outline view, this selects the appropriate tab view and sets its widget contents
	/// to match the object.
	private func selectTabPane(forObject obj: DKRasterizer?) {
		if selectedRendererRef !== obj {
			// reset the font manager's action, in case an earlier label editor changed it:

			NSFontManager.shared.action = #selector(NSObject.changeFont(_:))
		}
		
		selectedRendererRef = obj
		
		var tab: Tab = .noItems
		
		if let obj = obj {
			if let obj2 = obj as? DKStroke {
				tab = .stroke
				updateSettings(for: obj2)
			} else if let obj2 = obj as? DKFill {
				tab = .fill
				updateSettings(for: obj2)
			} else if let obj2 = obj as? DKCIFilterRastGroup {
				tab = .filter
				updateSettings(forCoreImageEffect: obj2)
			} else if let obj2 = obj as? DKQuartzBlendRastGroup {
				tab = .blendMode
				updateSettings(forBlendEffect: obj2)
			} else if obj is DKRastGroup {
				tab = .stylePreview
				updateStylePreview()
			} else if let obj2 = obj as? DKImageAdornment {
				tab = .image
				updateSettings(forImage: obj2)
			} else if let obj2 = obj as? DKHatching {
				tab = .hatch
				updateSettings(forHatch: obj2)
			} else if let obj2 = obj as? DKTextAdornment {
				tab = .label
				updateSettings(forTextLabel: obj2)
			} else if let obj2 = obj as? DKPathDecorator {
				tab = .pathDecor
				updateSettings(for: obj2)
			} else if let obj2 = obj as? DKFillPattern {
				tab = .pathDecor
				updateSettings(for: obj2)
			}
		}
		
		tabView.selectTabViewItem(at: tab.rawValue)
	}
	
	/// Given a renderer object, this adds it to the end of the currently selected group and selects it.
	private func addAndSelectNewRenderer(_ obj: DKRasterizer) {
		// need to determine which group is currently selected in the outline view to give the item a parent
		let parent: DKRastGroup? = {
			if let sel = outlineView.item(atRow: outlineView.selectedRow) {
				if let sel2 = sel as? DKRastGroup {
					return sel2
				} else {
					return (sel as AnyObject).container
				}
			} else {
				return style
			}
		}()
		
		selectedRendererRef = nil
		
		style?.notifyClientsBeforeChange()
		parent?.addRenderer(obj)
		style?.notifyClientsAfterChange()
		
		outlineView.reloadData()
		
		let row = outlineView.row(forItem: obj)
		
		if row != NSNotFound {
			outlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
		}
	}
	
	
	// MARK: - refreshing the UI for different selected rasterizers as the selection changes
	
	/// set UI widgets to match stroke's attributes
	private func updateSettings(for stroke: DKStroke) {
		strokeColourWell.color = stroke.colour
		strokeSlider.objectValue = stroke.width
		strokeTextField.objectValue = stroke.width
		strokeShadowCheckbox.state = stroke.shadow != nil ? .on : .off
		
		// set dash menu to match current dash:
		
		if let dash = stroke.dash {
			let i = strokeDashPopUpButton.indexOfItem(withRepresentedObject: dash)
			if i != -1 {
				strokeDashPopUpButton.selectItem(at: i)
			} else {
				strokeDashPopUpButton.selectItem(withTag: -3) // Other...
			}
		} else {
			strokeDashPopUpButton.selectItem(withTag: -1) // None
		}
		
		// set shadow controls (TO DO)
		
		// set cap/join selector (segmented control)

		strokeLineCapSelector.selectedSegment = Int(stroke.lineCapStyle.rawValue)
		strokeLineJoinSelector.selectedSegment = Int(stroke.lineJoinStyle.rawValue)
		
		// show/hide auxiliary controls for subclasses
		if let arrowStroke = stroke as? DKArrowStroke {
			strokeControlsTabView.setSubviewsWithTag(ItemsTag.arrowStroke.rawValue, hidden: false)
			strokeArrowStartPopUpButton.selectItem(withTag: arrowStroke.arrowHeadAtStart.rawValue)
			strokeArrowEndPopUpButton.selectItem(withTag: arrowStroke.arrowHeadAtEnd.rawValue)
			strokeArrowDimensionOptions.selectItem(withTag: arrowStroke.dimensioningLineOptions.rawValue)
			
			let previewSize = strokeArrowPreviewImageWell.bounds.size
			let preview = arrowStroke.arrowSwatchImage(with: previewSize, strokeWidth: min(8, arrowStroke.width))
			strokeArrowPreviewImageWell.image = preview
		} else if let rough = stroke as? DKRoughStroke {
			strokeRoughnessSlider.objectValue = rough.roughness
			strokeControlsTabView.setSubviewsWithTag(ItemsTag.arrowStroke.rawValue, hidden: true)
			strokeControlsTabView.setSubviewsWithTag(ItemsTag.roughStroke.rawValue, hidden: false)
		} else {
			strokeControlsTabView.setSubviewsWithTag(ItemsTag.arrowStroke.rawValue, hidden: true)
			strokeControlsTabView.setSubviewsWithTag(ItemsTag.roughStroke.rawValue, hidden: true)
		}
		
		if let zz = stroke as? DKZigZagStroke {
			strokeZZLength.objectValue = zz.wavelength
			strokeZZAmp.objectValue = zz.amplitude
			strokeZZSpread.objectValue = zz.spread
			strokeControlsTabView.setSubviewsWithTag(ItemsTag.zigZag.rawValue, hidden: false)
		} else {
			strokeControlsTabView.setSubviewsWithTag(ItemsTag.zigZag.rawValue, hidden: true)
		}
	}
	
	/// which tab of the fill type view to display
	private func updateSettings(for fill: DKFill) {
		var tab = FillType.solid
		
		if fill.gradient != nil {
			tab = .gradient
		}
		
		fillColourWell.color = fill.colour ?? .white
		fillControlsTabView.setSubviewsWithTag(ItemsTag.shadow.rawValue, enabled: fill.shadow != nil)
		
		if let fs = fill.shadow {
			fillShadowCheckbox.state = .on
			shadowColourWell.color = fs.shadowColor!
			shadowBlurRadiusSlider.objectValue = fs.shadowBlurRadius
			shadowDistanceSlider.objectValue = fs.distance
			shadowAngleSlider.objectValue = fs.angleInDegrees
		} else {
			fillShadowCheckbox.state = .off
		}
		
		let gradient: DKGradient? = fill.gradient
		
		if !mIsChangingGradient {
			fillGradientControlBar.gradient = gradient
		}
		
		fillGradientRemoveButton.isEnabled = gradient != nil
		fillGradientAddButton.isEnabled = gradient == nil
		
		let angle = gradient?.angleInDegrees ?? 0
		
		fillGradientAngleSlider.objectValue = angle
		fillGradientAngleTextField.objectValue = angle
		fillGradientAngleLittleArrows.objectValue = angle
		
		fillGradientRelativeToObject.state = fill.tracksObjectAngle ? .on : .off
		
		if let zz = fill as? DKZigZagFill {
			fillZZLength.objectValue = zz.wavelength
			fillZZAmp.objectValue = zz.amplitude
			fillZZSpread.objectValue = zz.spread
			fillControlsTabView.setSubviewsWithTag(ItemsTag.zigZag.rawValue, hidden: false)
		} else {
			fillControlsTabView.setSubviewsWithTag(ItemsTag.zigZag.rawValue, hidden: true)
		}
		fillTypeTabView.selectTabViewItem(at: tab.rawValue)
	}
	
	private func updateSettings(forHatch hatch: DKHatching) {
		hatchColourWell.color = hatch.colour
		hatchSpacingSlider.objectValue = hatch.spacing
		hatchSpacingTextField.objectValue = hatch.spacing
		hatchLineWidthSlider.objectValue = hatch.width
		hatchLineWidthTextField.objectValue = hatch.width
		hatchAngleSlider.objectValue = hatch.angleInDegrees
		hatchAngleTextField.objectValue = hatch.angleInDegrees
		hatchLeadInSlider.objectValue = hatch.leadIn
		hatchLeadInTextField.objectValue = hatch.leadIn
		hatchLineCapButton.selectedSegment = Int(hatch.lineCapStyle.rawValue)
		hatchRelativeAngleCheckbox.state = hatch.angleIsRelativeToObject ? .on : .off
		
		if let dash = hatch.dash {
			let i = hatchDashPopUpButton.indexOfItem(withRepresentedObject: dash)
			
			if i != -1 {
				hatchDashPopUpButton.selectItem(at: i)
			} else {
				hatchDashPopUpButton.selectItem(at: -3)
			}
		} else {
			hatchDashPopUpButton.selectItem(withTag: -1)
		}
	}
	
	private func updateSettings(forImage ir: DKImageAdornment) {
		imageWell.image = ir.image;
		imageOpacitySlider.objectValue = ir.opacity;
		imageScaleSlider.objectValue = ir.scale;
		imageAngleSlider.objectValue = ir.angleInDegrees;
		imageClipToPathCheckbox.state = ir.clipping != .none ? .on : .off
		imageIdentifierTextField.stringValue = ir.imageIdentifier;
		imageFittingPopUpMenu.selectItem(withTag: ir.fittingOption.rawValue)
		
		// if fitting option is fit to bounds, or fit proportionally, disable scale slider
		
		if ir.fittingOption == .clipToBounds {
			imageScaleSlider.isEnabled = true
		} else {
			imageScaleSlider.isEnabled = false
		}
	}
	
	private func updateSettings(forCoreImageEffect effg: DKCIFilterRastGroup!) {
		ciFilterClipToPathCheckbox.state = effg.clipping != .none ? .on : .off
		
		// check and select the menu item corresponding to the current filter
		ciFilterPopUpMenu.selectItem(at: (ciFilterPopUpMenu.menu!.indexOfItem(withRepresentedObject: effg.filter)))
	}
	
	private func updateSettings(forTextLabel tlr: DKTextAdornment) {
		textLabelTextField.stringValue = tlr.string
		textLayoutPopUpButton.selectItem(withTag: tlr.layoutMode.rawValue)
		textAlignmentPopUpButton.selectItem(withTag: Int(tlr.alignment.rawValue))
		textWrapLinesCheckbox.state = tlr.wrapsLines ? .on : .off
		textClipToPathCheckbox.state = tlr.clipping == .none ? .off : .on
		textRelativeAngleCheckbox.state = tlr.appliesObjectAngle ? .on : .off
		textAngleSlider.objectValue = tlr.angleInDegrees
		textLabelPlacementPopUpButton.selectItem(withTag: tlr.verticalAlignment.rawValue)
		flowedTextInsetSlider.objectValue = tlr.flowedTextPathInset
		
		textColourWell.color = tlr.colour
		
		// disable items not relevant to path text if that mode is set

		let enable: Bool = tlr.layoutMode != .alongPath && tlr.layoutMode != .alongReversedPath
		
		textClipToPathCheckbox.isEnabled = enable
		textRelativeAngleCheckbox.isEnabled = enable
		flowedTextInsetSlider.isEnabled = enable
		textAngleSlider.isEnabled = enable
		textWrapLinesCheckbox.isEnabled = enable
		
		// synchronise the Font Panel to the renderer's settings and set its action to apply to it

		let textAttrAnnoyingHack: [String: Any] = {
			var toRet = [String: Any]()
			
			for (key, obj) in tlr.textAttributes {
				toRet[key.rawValue] = obj
			}
			
			return toRet
		}()

		NSFontManager.shared.action = #selector(AppDelegate.temporaryPrivateChangeFontAction(_:))
		NSFontManager.shared.setSelectedFont(tlr.font, isMultiple: false)
		NSFontManager.shared.setSelectedAttributes(textAttrAnnoyingHack, isMultiple: false)
	}

	private func updateSettings(for pd: DKPathDecorator) {
		pdIntervalSlider.objectValue = pd.interval
		pdScaleSlider.objectValue = pd.scale
		pdNormalToPathCheckbox.state = pd.normalToPath ? .on : .off
		pdLeaderSlider.objectValue = pd.leaderDistance
		pdPreviewImage.image = pd.image
		pdRampProportionSlider.objectValue = pd.leadInAndOutLengthProportion
		
		// if really a fill pattern, deal with the alt offset control

		if let pd = pd as? DKFillPattern {
			pdPatternAlternateOffsetSlider.objectValue = pd.patternAlternateOffset.height
			pdAngleSlider.objectValue = pd.angleInDegrees
			pdRelativeAngleCheckbox.state = pd.angleIsRelativeToObject ? .on : .off
			motifAngleSlider.objectValue = pd.motifAngleInDegrees
			motifRelativeAngleCheckbox.state = pd.motifAngleIsRelativeToPattern ? .on : .off
			
			pdControlsTabView.setSubviewsWithTag(ItemsTag.pathDecorator.rawValue, hidden: true)
			pdControlsTabView.setSubviewsWithTag(ItemsTag.patternFill.rawValue, hidden: false)
		} else {
			pdControlsTabView.setSubviewsWithTag(ItemsTag.pathDecorator.rawValue, hidden: false)
			pdControlsTabView.setSubviewsWithTag(ItemsTag.patternFill.rawValue, hidden: true)
		}
	}
	
	private func updateSettings(forBlendEffect brg: DKQuartzBlendRastGroup) {
		blendModePopUpButton.selectItem(withTag: Int(brg.blendMode.rawValue))
		blendGroupAlphaSlider.objectValue = brg.alpha
		blendGroupImagePreview.image = brg.maskImage
	}
	
	
	// MARK: - setting up various menu listings:
	
	private func populatePopUpButton(withLibraryStyles button: NSPopUpButton) {
		let styleMenu = DKStyleRegistry.managedStylesMenu(withItemTarget: self, itemAction: #selector(GCSStyleInspector.libraryItemAction(_:)))
		button.menu = styleMenu
		button.title = "Style Library"
	}
	
	private func populateMenu(withDashes menu: NSMenu) {
		let dashes = DKStrokeDash.registeredDashes
		var k = 1
		
		for dash in dashes {
			let item = menu.insertItem(withTitle: "", action: nil, keyEquivalent: "", at: k)
			k += 1
			
			item.isEnabled = true
			item.representedObject = dash
			item.image = dash.standardDashSwatchImage()
		}
	}
	
	private func populateMenu(withCoreImageFilters menu: NSMenu) {
		let filt = CIFilter.filterNames(inCategory: kCICategoryStillImage)
		
		menu.removeAllItems()
		
		for filter in filt {
			let item = menu.addItem(withTitle: CIFilter.localizedName(forFilterName: filter) ?? filter, action: nil, keyEquivalent: "")
			item.representedObject = filter
		}
	}
	
	
	// MARK: - opening the subsidiary sheet for editing dashes:
	
	private func openDashEditor() {
		if let dashRenderRef = selectedRendererRef as? DKDashable {
			savedDash = dashRenderRef.dash
			
			let dash = dashRenderRef.dash?.copy() as? DKStrokeDash
			dashEditController.dash = dash
			// as long as the current renderer supports these methods, the dash editor will work:

			dashEditController.lineWidth = dashRenderRef.width
			dashEditController.lineCapStyle = dashRenderRef.lineCapStyle
			dashEditController.lineJoinStyle = dashRenderRef.lineJoinStyle
			dashEditController.lineColour = dashRenderRef.colour
			
			dashEditController.open(inParentWindow: window!, modalDelegate: self)
		} else {
			NSSound.beep()
		}
	}
	
	
	// MARK: - actions from stroke widgets:
	
	@IBAction func strokeColourAction(_ sender: Any?) {
		(selectedRendererRef as? DKStroke)?.colour = (sender as AnyObject).color
	}
	
	@IBAction func strokeWidthAction(_ sender: Any?) {
		(selectedRendererRef as? DKStroke)?.width = (sender as AnyObject).objectValue as! CGFloat
	}
	
	@IBAction func strokeShadowCheckboxAction(_ sender: Any?) {
		if let sender2 = sender as? NSButton {
			(selectedRendererRef as? DKStroke)?.shadow = sender2.state == .on ? DKStyle.defaultShadow() : nil
		}
	}
	
	@IBAction func strokeDashMenuAction(_ sender: NSPopUpButton!) {
		if let selIt = sender.selectedItem {
			let tag = selIt.tag
			switch tag {
			case -1:
				(selectedRendererRef as! DKStroke).dash = nil
				
			case -2:
				(selectedRendererRef as! DKStroke).setAutoDash()

			case -3:
				// "Other..." item
				openDashEditor()
				
			default:
				// menu's attributed object is the dash itself

				let dash = selIt.representedObject as? DKStrokeDash
				(selectedRendererRef as! DKStroke).dash = dash
			}
		}
	}
	
	@IBAction func strokePathScaleAction(_ sender: Any?) {
		if let sender = sender as AnyObject?,
			let scaleVal2 = sender.objectValue,
			let scaleVal = scaleVal2 as? CGFloat {
			(selectedRendererRef as! DKStroke).scaleWidth(by: scaleVal)
		}
	}
	
	@IBAction func strokeArrowStartMenuAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let selItem = send.selectedItem,
			let tag = selItem?.tag,
			let kind = DKArrowHeadKind(rawValue: tag) else {
			return
		}
		(selectedRendererRef as! DKArrowStroke).arrowHeadAtStart = kind
	}
	
	@IBAction func strokeArrowEndMenuAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let selItem = send.selectedItem,
			let tag = selItem?.tag,
			let kind = DKArrowHeadKind(rawValue: tag) else {
				return
		}
		(selectedRendererRef as! DKArrowStroke).arrowHeadAtEnd = kind
	}
	
	@IBAction func strokeArrowShowDimensionAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let selItem = send.selectedItem,
			let tag = selItem?.tag,
			let lineOpts = DKDimensioningLineOptions(rawValue: tag) else {
				return
		}

		(selectedRendererRef as! DKArrowStroke).dimensioningLineOptions = lineOpts
	}
	
	@IBAction func strokeTrimLengthAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let fv2 = send.objectValue,
			let fv = fv2 as? CGFloat else {
			return
		}
		(selectedRendererRef as! DKStroke).trimLength = fv
	}
	
	@IBAction func strokeZigZagLengthAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let fv2 = send.objectValue,
			let fv = fv2 as? CGFloat else {
				return
		}
		(selectedRendererRef as! DKZigZagStroke).wavelength = fv
	}
	
	@IBAction func strokeZigZagAmplitudeAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let fv2 = send.objectValue,
			let fv = fv2 as? CGFloat else {
				return
		}
		(selectedRendererRef as! DKZigZagStroke).amplitude = fv
	}
	
	@IBAction func strokeZigZagSpreadAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let fv2 = send.objectValue,
			let fv = fv2 as? CGFloat else {
				return
		}
		(selectedRendererRef as! DKZigZagStroke).spread = fv
	}
	
	@IBAction func strokeLineJoinStyleAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let fv2 = send.selectedSegment,
			let ljs = NSBezierPath.LineJoinStyle(rawValue: UInt(fv2)) else {
				return
		}
		(selectedRendererRef as! DKStroke).lineJoinStyle = ljs
	}
	
	@IBAction func strokeLineCapStyleAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let fv2 = send.selectedSegment,
			let ljs = NSBezierPath.LineCapStyle(rawValue: UInt(fv2)) else {
				return
		}
		(selectedRendererRef as! DKStroke).lineCapStyle = ljs
	}
	
	@IBAction func strokeRoughnessAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let fv2 = send.objectValue,
			let fv = fv2 as? CGFloat else {
				return
		}
		//(selectedRendererRef as? DKArrowStroke)?.rough = fv
		(selectedRendererRef as? DKRoughStroke)?.roughness = fv
	}
	
	
	// MARK: - actions from fill widgets
	
	@IBAction func fillColourAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let color = sender.color else {
			return
		}
		(selectedRendererRef as! DKFill).colour = color
	}
	
	@IBAction func fillShadowCheckboxAction(_ sender: Any?) {
		if let sender2 = sender as? NSButton {
			(selectedRendererRef as? DKFill)?.shadow = sender2.state == .on ? DKStyle.defaultShadow() : nil
		}
	}
	
	@IBAction func fillGradientAction(_ sender: Any?) {
		//	LogEvent_(kInfoEvent, @"gradient change from %@", sender );
		
		mIsChangingGradient = true
		
		// copy needed to force KVO to flag the change of gradient in the fill

		var grad: DKGradient = (sender as AnyObject).gradient!!
		grad = grad.copy() as! DKGradient
		
		(selectedRendererRef as! DKFill).gradient = grad
		
		mIsChangingGradient = false
	}
	
	@IBAction func fillRemoveGradientAction(_ sender: Any?) {
		//#pragma unused(sender)
		LogEvent(.infoEvent, "removing gradient from fill")
		(selectedRendererRef as! DKFill).gradient = nil
	}
	
	@IBAction func fillAddGradientAction(_ sender: Any?) {
		if let fill = selectedRendererRef as? DKFill {
			fill.colour = .clear
			
			fillGradientControlBar.gradient = DKGradient.`default`()
			fillGradientAction(fillGradientControlBar)
			fill.gradient = fillGradientControlBar.gradient
		}
	}
	
	@IBAction func fillGradientAngleAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let fv2 = send.objectValue,
			let fv = fv2 as? CGFloat else {
				return
		}
		let gradient = (selectedRendererRef as? DKFill)?.gradient
		gradient?.angleInDegrees = fv
	}
	
	@IBAction func fillGradientRelativeToObjectAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let stat2: NSControl.StateValue? = sender.state,
			let stat = stat2 else {
			return
		}
		(selectedRendererRef as! DKFill).tracksObjectAngle = stat == .on
	}
	
	@IBAction func fillPatternPasteImageAction(_ sender: Any?) {
		let pb = NSPasteboard.general
		
		if NSImage.canInit(with: pb) {
			let image = NSImage(pasteboard: pb)!
			(selectedRendererRef as? DKFill)?.colour = NSColor(patternImage: image)
			fillPatternImagePreview.image = image
			LogEvent(.infoEvent, "color space name: \((selectedRendererRef as? DKFill)?.colour?.colorSpaceName.rawValue ?? "Unknown")")
		}
	}
	
	@IBAction func fillZigZagLengthAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let fv2 = send.objectValue,
			let fv = fv2 as? CGFloat else {
				return
		}
		
		(selectedRendererRef as! DKZigZagFill).wavelength = fv
	}
	
	@IBAction func fillZigZagAmplitudeAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let fv2 = send.objectValue,
			let fv = fv2 as? CGFloat else {
				return
		}

		(selectedRendererRef as! DKZigZagFill).amplitude = fv
	}
	
	@IBAction func fillZigZagSpreadAction(_ sender: Any?) {
		guard let send = sender as AnyObject?,
			let fv2 = send.objectValue,
			let fv = fv2 as? CGFloat else {
				return
		}

		(selectedRendererRef as! DKZigZagFill).spread = fv
	}
	
	
	// MARK: - actions from style registry widgets:
	
	/// Open the script editing dialog.
	@IBAction func scriptButtonAction(_ sender: Any?) {
		/*
		scriptEditController.runAsSheet(inParentWindow: window!) { (returnCode) in
			if returnCode == .OK {
				if let dashRenderRef = self.selectedRendererRef as? DKDashable {
					dashRenderRef.dash = self.dashEditController.dash
				}
			} else {
				if let dashRenderRef = self.selectedRendererRef as? DKDashable {
					dashRenderRef.dash = self.savedDash
				}
			}
		}
		*/
		
		scriptEditController.runAsSheet(inParentWindow: window!, modalDelegate: self);
	}
	
	
	@IBAction func libraryMenuAction(_ sender: Any?) {
		let tag: Int
		if let tag2: Int = (sender as AnyObject?)?.tag {
			tag = tag2
		} else {
			tag = 0
		}
		
		switch tag {
		case -1:
			// add to library using the name in the field
			DKStyleRegistry.register(style!)
			
			// update the library menu
			
			//[self populateMenuWithLibraryStyles:[mStyleLibraryPopUpButton menu]];
			updateUIForStyle()

		case -4:
			// remove from library, if indeed the style really is part of it (more likely a copy, so this won't do anything)
			DKStyleRegistry.unregisterStyle(style!)
			populatePopUpButton(withLibraryStyles: styleLibraryPopUpButton)
			updateUIForStyle()
			
		case -2:
			// save library
			break
			
		case -3:
			// load library
			break
			
		default:
			break
		}
	}
	
	/// set the style for the objects in the selection to the menu item style
	@IBAction func libraryItemAction(_ sender: Any?) {
		LogEvent(.infoEvent, "library style = \(((sender as AnyObject?)!.representedObject!)!)")
		
		if let selection = selectedObjectForCurrentTarget() as? [DKDrawableObject],
			// so that the item gets added to "recently used", request the style from the registry using this method:
			
			let ro = (sender as AnyObject?)?.representedObject, let ro2 = ro as? DKStyle {
			
			let key = ro2.uniqueKey
			let ss = DKStyleRegistry.styleForKeyAdding(toRecentlyUsed: key)!
			
			selection.forEach({ (drawObj) in
				drawObj.style = ss
			})
			redisplayContent(forSelection: selection)
			
			currentDocument?.undoManager?.setActionName(NSLocalizedString("Apply Style", comment: ""))
		}
	}
	
	@IBAction func sharedStyleCheckboxAction(_ sender: Any?) {
		if !(style?.locked ?? true) {
			if let sender = sender as AnyObject?,
				let stat2: NSControl.StateValue? = sender.state,
				let stat = stat2  {
				style?.isStyleSharable = stat == .on
			}
		}
	}
	
	@IBAction func styleNameAction(_ sender: Any?) {
		if !(style?.locked ?? true) {
			if let aSend = sender as AnyObject?, let nameVal: String = aSend.stringValue {
				style?.name = nameVal
				
				// if the style is registered, update the library menu
				if style?.isStyleRegistered ?? false {
					populatePopUpButton(withLibraryStyles: styleLibraryPopUpButton)
				}
				
				currentDocument?.undoManager?.setActionName(NSLocalizedString("Change Style Name", comment: ""))
			}
		}
	}
	
	/// Makes a copy (mutable) of the current style and applies it to the objects in the selection. This gives us a useful
	/// starting point for making a new style.
	@IBAction func cloneStyleAction(_ sender: Any?) {
		let clone = style!.mutableCopy() as! DKStyle
		
		// give it a new name:
		// if it has text attributes, give it a name based on the font, otherwise, blank.
		clone.name = nil
		
		if clone.hasTextAttributes, let font = clone.textAttributes?[.font] as? NSFont {
			clone.name = DKStyle.styleName(for: font)
		}
		
		// attach it to the selected objects and update
		if let selection = selectedObjectForCurrentTarget() as? [DKDrawableObject] {
			selection.forEach({ (obj) in
				obj.style = clone
			})
			redisplayContent(forSelection: selection)
		}
		
		currentDocument?.undoManager?.setActionName(NSLocalizedString("Clone Style", comment: ""))
	}
	
	/// unlocks a locked style for editing. If the style is registered, posts a stern warning
	@IBAction func unlockStyleAction(_ sender: Any?) {
		let senderValue: Int = {
			if let sender = sender as AnyObject?,
				let intVal2 = sender.objectValue,
				let intVal = intVal2 as? Int {
				return intVal
			}
			
			return 0
		}()
		
		if (style?.isStyleRegistered ?? false), senderValue == 0 {
			// warn user what could happen
			let alert = NSAlert()
			alert.messageText = "Caution: Registered Style"
			alert.informativeText = String(format: "Editing a registered style can have unforseen consequences as such styles may become permanently changed. Are you sure you want to unlock the style ‘%@’ for editing?", style?.name ?? "")
			alert.addButton(withTitle: "Cancel")
			alert.addButton(withTitle: "Unlock Anyway")
			
			let result = alert.runModal()
			
			if result == .alertSecondButtonReturn {
				style?.locked = false
			}
		} else {
			style?.locked = senderValue != 0
		}
		
		self.updateUIForStyle()
		
		if (style?.isStyleRegistered ?? false), senderValue == 1 {
			populatePopUpButton(withLibraryStyles: styleLibraryPopUpButton)
		}
		
		currentDocument?.undoManager?.setActionName(NSLocalizedString((style?.locked ?? false) ? "Lock Style" : "Unlock Style", comment: ""))
	}
	
	
	// MARK: - actions from general style widgets:
	
	@IBAction func addRendererElementAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
		let selItem = sender.selectedItem,
			let selItem2 = selItem?.tag,
			let tag = AddRendererTag(rawValue: selItem2) else {
				return
		}
		
		let rend: DKRasterizer
		
		switch tag {
		case .stroke:
			rend = DKStroke()
			
		case .zigZagStroke:
			rend = DKZigZagStroke()
			
		case .fill:
			rend = DKFill()
			
		case .zigZagFill:
			rend = DKZigZagFill()
			
		case .group:
			rend = DKRastGroup()
			
		case .coreEffect:
			rend = DKCIFilterRastGroup()
			
		case .image:
			rend = DKImageAdornment()
			
		case .hatch:
			rend = DKHatching()
			
		case .arrowStroke:
			let arrowStr: DKArrowStroke = DKArrowStroke()
			arrowStr.width = max(1.0, style?.maxStrokeWidth ?? 0)
			rend = arrowStr
			
		case .pathDecorator:
			rend = DKPathDecorator()
			
		case .patternFill:
			rend = DKFillPattern()
			
		case .blendEffect:
			rend = DKQuartzBlendRastGroup()
			
		case .roughStroke:
			rend = DKRoughStroke()
			
		case .label:
			rend = DKTextAdornment()
		}
		
		addAndSelectNewRenderer(rend)
		
		currentDocument?.undoManager?.setActionName(NSLocalizedString("Add Style Component", comment: ""))
	}
	
	@IBAction func removeRendererElementAction(_ sender: Any?) {
		guard let sel = outlineView.item(atRow: outlineView.selectedRow) as? DKRasterizer, sel !== style else {
			return
		}
		
		let parent = sel.container!
		
		LogEvent(.infoEvent, "deleting renderer \(sel) from parent \(parent)")
		
		selectedRendererRef = nil
		
		style?.notifyClientsBeforeChange()
		parent.removeRenderer(sel)
		style?.notifyClientsAfterChange()
		
		outlineView.reloadData()
		
		let row = outlineView.row(forItem: parent)
		
		if row != NSNotFound {
			outlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
		}
		
		currentDocument?.undoManager?.setActionName(NSLocalizedString("Delete Style Component", comment: ""))
	}
	
	/// Duplicates the selected renderer within its current parent group. If the root style is selected,
	/// does nothing.
	@IBAction func duplicateRendererElementAction(_ sender: Any?) {
		
		guard let sel = outlineView.item(atRow: outlineView.selectedRow) as? DKStyle, sel !== style else {
			NSSound.beep()
			return
		}
		let newItem = sel.copy() as! DKStyle
		
		addAndSelectNewRenderer(newItem)
		currentDocument?.undoManager?.setActionName(NSLocalizedString("Duplicate Style Component", comment: ""))
	}
	
	@IBAction func copyRendererElementAction(_ sender: Any?) {
		// ensure the copy is of a component and not the whole thing
		
		guard let sel = outlineView.item(atRow: outlineView.selectedRow) as? DKStyle, sel !== style else {
			NSSound.beep()
			return
		}
		
		sel.copy(to: NSPasteboard.general)
	}
	
	@IBAction func pasteRendererElementAction(_ sender: Any?) {
		if let rend = DKRasterizer(from: NSPasteboard.general) {
			addAndSelectNewRenderer(rend)
			currentDocument?.undoManager?.setActionName(NSLocalizedString("Paste Style Component", comment: ""))
		} else {
			NSSound.beep()
		}
	}
	
	@IBAction func removeTextAttributesAction(_ sender: Any?) {
		if let style = style, !style.locked, style.hasTextAttributes {
			style.removeTextAttributes()
			currentDocument?.undoManager?.setActionName(NSLocalizedString("Remove Text Attributes", comment: ""))
		}
	}
	
	// MARK: - actions from image adornment widgets:
	
	@IBAction func imageFileButtonAction(_ sender: Any?) {
		let op = NSOpenPanel()
		
		op.allowsMultipleSelection = false
		op.canChooseDirectories = false
		op.allowedFileTypes = NSImage.imageTypes
		
		let result = op.runModal()
		
		if result == .OK {
			let image = NSImage(byReferencing: op.url!)
			
			if let selrenRef = selectedRendererRef as? DKImageAdornment {
				selrenRef.image = image
			} else if let mselRen = selectedRendererRef as? DKFill {
				mselRen.colour = NSColor(patternImage: image)
			}
		}
	}
	
	@IBAction func imageWellAction(_ sender: Any?) {
		//Currently blank...
	}
	
	@IBAction func imageIdentifierAction(_ sender: Any?) {
		if let sender = sender as AnyObject?,
			let str: String = sender.stringValue,
			let imgAd = selectedRendererRef as? DKImageAdornment {
			imgAd.imageIdentifier = str
		}
	}
	
	@IBAction func imageOpacityAction(_ sender: Any?) {
		if let imgAd = selectedRendererRef as? DKImageAdornment,
			let sender = sender as AnyObject?,
			let aFl2 = sender.objectValue,
			let aFl = aFl2 as? CGFloat {
			imgAd.opacity = aFl
		}
	}
	
	@IBAction func imageScaleAction(_ sender: Any?) {
		if let imgAd = selectedRendererRef as? DKImageAdornment,
			let sender = sender as AnyObject?,
			let aFl2 = sender.objectValue,
			let aFl = aFl2 as? CGFloat {
			imgAd.scale = aFl
		}
	}
	
	@IBAction func imageAngleAction(_ sender: Any?) {
		if let imgAd = selectedRendererRef as? DKImageAdornment,
			let sender = sender as AnyObject?,
			let aFl2 = sender.objectValue,
			let aFl = aFl2 as? CGFloat {
			imgAd.angleInDegrees = aFl
		}
	}
	
	@IBAction func imageFittingMenuAction(_ sender: NSPopUpButton!) {
		if let option = sender.selectedItem?.tag,
			let imgAd = selectedRendererRef as? DKImageAdornment,
			let opt2 = DKImageFittingOption(rawValue: option) {
			imgAd.fittingOption = opt2
		}
	}
	
	@IBAction func imageClipToPathAction(_ sender: Any?) {
		//	((DKImageAdornment *)mSelectedRendererRef).clipping = [sender intValue];
		guard let sender = sender as AnyObject?,
			let imgAd = selectedRendererRef as? DKImageAdornment,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? Int,
			let clipping = DKClippingOption(rawValue: inVal) else {
			return
		}
		imgAd.clipping = clipping
	}
	
	
	// MARK: - actions from hatch widgets
	
	@IBAction func hatchColourWellAction(_ sender: Any?) {
		guard let hatching = selectedRendererRef as? DKHatching,
			let sender = sender as AnyObject?,
			let color = sender.color else {
			return
		}
		hatching.colour = color
	}
	
	@IBAction func hatchSpacingAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let hatching = selectedRendererRef as? DKHatching,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}
		hatching.spacing = inVal
	}
	
	@IBAction func hatchLineWidthAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let hatching = selectedRendererRef as? DKHatching,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}
		hatching.width = inVal
	}
	
	@IBAction func hatchAngleAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let hatching = selectedRendererRef as? DKHatching,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}
		hatching.angleInDegrees = inVal
	}
	
	@IBAction func hatchRelativeAngleAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let hatching = selectedRendererRef as? DKHatching,
			let controlState: NSControl.StateValue = sender.state else {
			return
		}
		hatching.angleIsRelativeToObject = controlState == .on
	}
	
	@IBAction func hatchDashMenuAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let si = sender.selectedItem, let tag = si?.tag,
			let hatching = selectedRendererRef as? DKHatching else {
				return
		}
		
		switch tag {
		case -1:
			hatching.dash = nil
			
		case -2:
			hatching.setAutoDash()
			
		case -3:
			// "Other..." item
			
			openDashEditor()
			
		default:
			// menu's attributed object is the dash itself
			if let dash3 = sender.selectedItem, let dash = dash3?.representedObject as? DKStrokeDash {
				hatching.dash = dash
			}
		}
	}
	
	@IBAction func hatchLeadInAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let hatching = selectedRendererRef as? DKHatching,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}
		hatching.leadIn = inVal
	}
	
	// MARK: - actions from CI Filter widgets:
	
	@IBAction func filterMenuAction(_ sender: NSPopUpButton!) {
		LogEvent(.infoEvent, "filter menu, choice = \(sender.selectedItem!.title)")

		if let crr = selectedRendererRef as? DKCIFilterRastGroup {
			crr.filter = sender.selectedItem?.representedObject as! String
		}
	}
	
	@IBAction func filterClipToPathAction(_ sender: Any?) {
		if let crr = selectedRendererRef as? DKCIFilterRastGroup,
			let sender = sender as AnyObject?,
			let objVal2 = sender.objectValue,
			let objVal = objVal2 as? Int,
			let clipping = DKClippingOption(rawValue: objVal) {
			crr.clipping = clipping
		}
	}
	
	// MARK: - actions from text adornment widgets
	
	@IBAction func textLabelAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let adorn = selectedRendererRef as? DKTextAdornment,
			let inVal2: String = sender.stringValue else {
				return
		}
		
		adorn.setLabel(inVal2)
	}
	
	@IBAction func textLayoutAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let si = sender.selectedItem, let tag = si?.tag,
			let adorn = selectedRendererRef as? DKTextAdornment else {
				return
		}

		adorn.layoutMode = DKTextLayoutMode(rawValue: tag)
	}
	
	@IBAction func textAlignmentMenuAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let si = sender.selectedItem, let tag = si?.tag,
			let adorn = selectedRendererRef as? DKTextAdornment,
			let mode = NSTextAlignment(rawValue: UInt(tag)) else {
				return
		}
		
		adorn.alignment = mode
	}
	
	@IBAction func textPlacementMenuAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let si = sender.selectedItem, let tag = si?.tag,
			let adorn = selectedRendererRef as? DKTextAdornment,
			let mode = DKVerticalTextAlignment(rawValue: tag) else {
				return
		}
		
		adorn.verticalAlignment = mode
	}
	
	@IBAction func textWrapLinesAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let adorn = selectedRendererRef as? DKTextAdornment,
			let inVal2: NSControl.StateValue = sender.state else {
				return
		}
		
		adorn.wrapsLines = inVal2 == .on
	}
	
	@IBAction func textClipToPathAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let adorn = selectedRendererRef as? DKTextAdornment,
			let inVal2: NSControl.StateValue = sender.state else {
				return
		}
		
		adorn.appliesObjectAngle = inVal2 == .on
	}
	
	@IBAction func textRelativeAngleAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let adorn = selectedRendererRef as? DKTextAdornment,
			let inVal2: NSControl.StateValue = sender.state else {
				return
		}
		
		adorn.appliesObjectAngle = inVal2 == .on
	}
	
	@IBAction func textAngleAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let adorn = selectedRendererRef as? DKTextAdornment,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}
		
		adorn.angleInDegrees = inVal
	}
	
	@IBAction func textFontButtonAction(_ sender: Any?) {
		NSFontManager.shared.orderFrontFontPanel(sender)
	}
	
	@IBAction func textColourAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let adorn = selectedRendererRef as? DKTextAdornment,
			let inVal2 = sender.color else {
				return
		}
		
		adorn.colour = inVal2
	}
	
	@IBAction func textChangeFontAction(_ sender: NSFontManager!) {
		guard let adorn = selectedRendererRef as? DKTextAdornment else {
			return
		}

		LogEvent(.infoEvent, "got font change")
		let newFont = sender.convert(adorn.font)
		adorn.font = newFont
	}
	
	@IBAction func textFlowInsetAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let adorn = selectedRendererRef as? DKTextAdornment,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}

		adorn.flowedTextPathInset = inVal
	}
	
	@objc func changeTextAttributes(_ sender: NSFontManager) {
		if let textAdornment = selectedRendererRef as? DKTextAdornment {
			LogEvent(.infoEvent, "got attributes change")
			let textAttrAnnoyingHack: [String: Any] = {
				var toRet = [String: Any]()
				
				for (key, obj) in textAdornment.textAttributes {
					toRet[key.rawValue] = obj
				}
				
				return toRet
			}()
			let attrs = sender.convertAttributes(textAttrAnnoyingHack)
			let textAttrAnnoyingHackTheOtherWay: [NSAttributedStringKey: Any] = {
				var toRet = [NSAttributedStringKey: Any]()
				
				for (key, obj) in attrs {
					toRet[NSAttributedStringKey(rawValue: key)] = obj
				}
				
				return toRet
			}()
			textAdornment.textAttributes = textAttrAnnoyingHackTheOtherWay
		}
	}
	
	// MARK: - actions from path decaorator widgets:
	
	@IBAction func pathDecoratorIntervalAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let fill = selectedRendererRef as? DKPathDecorator,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}

		fill.interval = inVal
	}
	
	@IBAction func pathDecoratorScaleAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let fill = selectedRendererRef as? DKPathDecorator,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}

		fill.scale = inVal
	}
	
	@IBAction func pathDecoratorPasteObjectAction(_ sender: Any?) {
		let pb = NSPasteboard.general
		
		// allow PDF data to be pasted as an image
		if NSImage.canInit(with: pb),
			let image = NSImage(pasteboard: pb),
			let path = selectedRendererRef as? DKPathDecorator {
			path.image = image
		}
	}
	
	@IBAction func pathDecoratorPathNormalAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let fill = selectedRendererRef as? DKPathDecorator,
			let controlState: NSControl.StateValue = sender.state else {
				return
		}

		fill.normalToPath = controlState == .on
	}
	
	@IBAction func pathDecoratorLeaderDistanceAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let fill = selectedRendererRef as? DKPathDecorator,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}
		
		fill.leaderDistance = inVal
	}
	
	@IBAction func pathDecoratorAltPatternAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let fill = selectedRendererRef as? DKFillPattern,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}

		fill.patternAlternateOffset = NSSize(width: 0, height: inVal)
	}
	
	@IBAction func pathDecoratorRampProportionAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let fill = selectedRendererRef as? DKPathDecorator,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}
		
		fill.leadInAndOutLengthProportion = inVal

	}
	
	@IBAction func pathDecoratorAngleAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let fill = selectedRendererRef as? DKFillPattern,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}
		
		fill.angleInDegrees = inVal
	}
	
	@IBAction func pathDecoratorRelativeAngleAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let fill = selectedRendererRef as? DKFillPattern,
			let controlState: NSControl.StateValue = sender.state else {
				return
		}
		fill.angleIsRelativeToObject = controlState == .on

	}
	
	@IBAction func pathDecoratorMotifAngleAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let fill = selectedRendererRef as? DKFillPattern,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}
		
		fill.motifAngleInDegrees = inVal
	}
	
	@IBAction func pathDecoratorMotifRelativeAngleAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let fill = selectedRendererRef as? DKFillPattern,
			let controlState: NSControl.StateValue = sender.state else {
				return
		}
		fill.motifAngleIsRelativeToPattern = controlState == .on
	}
	
	
	// MARK: - actions from blend effect widgets:
	
	@IBAction func blendModeAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let si = sender.selectedItem, let tag = si?.tag,
			let blend = selectedRendererRef as? DKQuartzBlendRastGroup else {
			return
		}
		blend.blendMode = CGBlendMode(rawValue: CGBlendMode.RawValue(tag))!
	}
	
	@IBAction func blendGroupAlphaAction(_ sender: Any?) {
		guard let sender = sender as AnyObject?,
			let blend = selectedRendererRef as? DKQuartzBlendRastGroup,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}

		blend.alpha = inVal
	}
	
	@IBAction func blendGroupImagePasteAction(_ sender: Any?) {
		let pb = NSPasteboard.general
		
		if NSImage.canInit(with: pb),
			let blend = selectedRendererRef as? DKQuartzBlendRastGroup,
			let image = NSImage(pasteboard: pb) {
			blend.maskImage = image
		}
	}
	
	
	// MARK: - actions from shadow widgets:
	
	// shadow actions make copies because shadow properties are not directly under KVO, but
	// -setShadow: is, so the actions are still undoable.

	@IBAction func shadowAngleAction(_ sender: Any?) {
		guard let fill = selectedRendererRef as? DKFill,
			let shad = fill.shadow?.copy() as? NSShadow,
			let sender = sender as AnyObject?,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}
		
		shad.angleInDegrees = inVal
		fill.shadow = shad
	}
	
	@IBAction func shadowDistanceAction(_ sender: Any?) {
		guard let fill = selectedRendererRef as? DKFill,
			let shad = fill.shadow?.copy() as? NSShadow,
			let sender = sender as AnyObject?,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}
		
		shad.distance = inVal
		fill.shadow = shad
	}
	
	@IBAction func shadowBlurRadiusAction(_ sender: Any?) {
		guard let fill = selectedRendererRef as? DKFill,
			let shad = fill.shadow?.copy() as? NSShadow,
			let sender = sender as AnyObject?,
			let inVal2 = sender.objectValue,
			let inVal = inVal2 as? CGFloat else {
				return
		}
		
		shad.shadowBlurRadius = inVal
		fill.shadow = shad
	}
	
	@IBAction func shadowColourAction(_ sender: Any?) {
		guard let fill = selectedRendererRef as? DKFill,
			let shad = fill.shadow?.copy() as? NSShadow,
			let sender = sender as AnyObject?,
			let inVal2 = sender.color else {
				return
		}
		
		shad.shadowColor = inVal2
		fill.shadow = shad
	}

	// MARK: - modal sheet callback - called by selector, otherwise private
	func sheetDidEnd(_ sheet: NSWindow, returnCode: NSApplication.ModalResponse, contextInfo: UnsafeMutableRawPointer?) {
		guard let contextInfo = contextInfo else {
			return
		}
		if Unmanaged<GCSDashEditor>.fromOpaque(contextInfo).takeUnretainedValue() === dashEditController {
			if returnCode == .OK {
				if let dashRenderRef = selectedRendererRef as? DKDashable {
					dashRenderRef.dash = dashEditController.dash
				}
			} else {
				if let dashRenderRef = selectedRendererRef as? DKDashable {
					dashRenderRef.dash = savedDash
				}
			}
			
			savedDash = nil
		}
	}

	// MARK: - As a DKDrawkitInspectorBase
	override func redisplayContent(forSelection selection: [DKDrawableObject]?) {
		if let selection = selection {
			if selection.count > 1 {
				// multiple selection - if all the selected objects share the same style, we should proceeed as for
				// a single selection. Otherwise just switch to th emulti-selection tab.
				
				let styles = selection.map({$0.style}).filter({$0 != nil}).map({$0!})
				// are the styles all the same?
				var prevStyle: DKStyle? = nil
				var same = true
				
				for aStyle in styles {
					if (aStyle !== prevStyle && prevStyle != nil) {
						same = false
						break;
					}

					prevStyle = aStyle
				}
				
				if same {
					style = prevStyle
					tabView.selectTabViewItem(at: Tab.stylePreview.rawValue)
				} else {
					style = nil
					tabView.selectTabViewItem(at: Tab.multipleItems.rawValue)
				}
			} else if selection.count == 1 {
				// single selection
				style = selection[0].style
				tabView.selectTabViewItem(at: Tab.stylePreview.rawValue)
				styleClientCountText.integerValue = Int(style?.countOfClients ?? 0)
			} else {
				// no selection
				self.style = nil
				tabView.selectTabViewItem(at: Tab.noItems.rawValue)
			}
		} else {
			// no selection
			self.style = nil
			tabView.selectTabViewItem(at: Tab.noItems.rawValue)
		}
	}
	
	// MARK: - As an NSWindowController
	override func windowDidLoad() {
		super.windowDidLoad()
		(window as! NSPanel).isFloatingPanel = true
		(window as! NSPanel).becomesKeyOnlyIfNeeded = true
		NotificationCenter.default.addObserver(self, selector: #selector(GCSStyleInspector.styleAttached(_:)), name: .dkDrawableStyleWillBeDetached, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(GCSStyleInspector.styleRegistered(_:)), name: .dkStyleRegistryDidFlagPossibleUIChange, object: nil)
		
		//[mFillGradientWell setCell:[[GCSGradientCell alloc] init]];
		//[mFillGradientWell setCanBecomeActiveWell:NO];
		fillGradientControlBar.canBecomeActiveWell = false
		fillGradientControlBar.target = self
		fillGradientControlBar.action = #selector(GCSStyleInspector.fillGradientAction(_:))

		outlineView.delegate = self
		outlineView.registerForDraggedTypes([.dkTableRowInternalDrag])
		outlineView.setDraggingSourceOperationMask(.every, forLocal: true)
		outlineView.verticalMotionCanBeginDrag = true
		
		styleLibraryPopUpButton.menu?.insertItem(withTitle: "Style Library", action: nil, keyEquivalent: "", at: 0)
		
		populatePopUpButton(withLibraryStyles: styleLibraryPopUpButton)
		
		populateMenu(withDashes: hatchDashPopUpButton.menu!)
		populateMenu(withDashes: strokeDashPopUpButton.menu!)
		populateMenu(withCoreImageFilters: ciFilterPopUpMenu.menu!)
		
		addRendererPopUpButton.font = NSFont(name: "Lucida Grande", size: 10)
		addRendererPopUpButton.menu?.autoenablesItems = false
		addRendererPopUpButton.menu?.uncheckAllItems()
		addRendererPopUpButton.menu?.disableItems(withTag: -99)

		actionsPopUpButton.font = NSFont(name: "Lucida Grande", size: 10)
		actionsPopUpButton.menu?.uncheckAllItems()
		
		style = nil
		updateUIForStyle()
		
		var panelFrame = window!.frame
		let screenFrame = NSScreen.screens.first!.visibleFrame
		
		panelFrame.origin.x = screenFrame.maxX - panelFrame.width - 20
		window?.setFrameOrigin(panelFrame.origin)
	}

	// MARK: - As a GCDashEditorDelegate delegate
	func dashDidChange(_ sender: Any?) {
		// where Obj-C code is simpler than Swift:
		if let dash2: DKStrokeDash? = (sender as AnyObject?)?.dash, let dash1 = dash2 {
			if let selRenRef = selectedRendererRef as? DKDashable {
				selRenRef.dash = dash1
			}
		}
	}
	
	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		var enable = true
		let action = menuItem.action
		let sel = outlineView.item(atRow: outlineView.selectedRow) as AnyObject?
		
		if action == #selector(GCSStyleInspector.copyRendererElementAction(_:)) {
			// permitted for a valid selection even if style locked
			
			if sel == nil || sel === style {
				enable = false
			}
		} else if action == #selector(GCSStyleInspector.duplicateRendererElementAction(_:)) || action == #selector(GCSStyleInspector.removeRendererElementAction(_:)) {
			// permitted if the selection is not root or nil, and style unlocked

			if sel == nil || sel === style || style?.locked == true {
				enable = false
			}
		} else if action == #selector(GCSStyleInspector.pasteRendererElementAction(_:)) {
			// permitted if the pasteboard contains a renderer & style unlocked

			let pbtype = NSPasteboard.general.availableType(from: [.dkRasterizer])
			
			enable = pbtype != nil && style?.locked == false
		} else if action == #selector(GCSStyleInspector.libraryItemAction(_:)) {
			menuItem.state = (menuItem.representedObject as AnyObject?) === style ? .on : .off
		} else if action == #selector(GCSStyleInspector.removeTextAttributesAction(_:)) {
			if let style = self.style {
				enable = !style.locked && style.hasTextAdornment
			} else {
				enable = false
			}
		}
		return enable
	}
}

// MARK: -
extension GCSStyleInspector: NSOutlineViewDataSource, NSOutlineViewDelegate {
	// MARK: As part of NSOutlineViewDataSource Protocol
	func outlineView(_ olv: NSOutlineView, acceptDrop info: NSDraggingInfo, item targetItem: Any?, childIndex: Int) -> Bool {
		// the item being moved is already stored as mDragItem, so simply move it to the new place
		let group: DKRastGroup?
		if let targetItem = targetItem,
			let targetItem2 = targetItem as? DKRastGroup {
			group = targetItem2
		} else {
			group = style
		}
		
		let srcIndex = group?.renderList?.index(of: mDragItem!) ?? NSNotFound
		
		if srcIndex != NSNotFound {
			// moving within the same group it already belongs to

			style?.notifyClientsBeforeChange()
			group?.moveRenderer(at: srcIndex, to: childIndex)
			style?.notifyClientsAfterChange()
			
			olv.reloadData()
			
			let row = olv.row(forItem: mDragItem)
			
			if row != NSNotFound {
				olv.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false) // workaround over-optimisation bug in o/v
				olv.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
			}
			
			currentDocument?.undoManager?.setActionName(NSLocalizedString("Reorder Style Component", comment: ""))

			return true
		} else if group !== mDragItem?.container {
			// moving to another group in the hierarchy

			style?.notifyClientsBeforeChange()
			mDragItem?.container?.removeRenderer(mDragItem!)
			group?.addRenderer(mDragItem!)
			group?.moveRenderer(at: (group?.countOfRenderList ?? 1) - 1, to: childIndex)
			style?.notifyClientsAfterChange()

			olv.reloadData()
			let row = olv.row(forItem: mDragItem)
			
			if row != NSNotFound {
				olv.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false) // workaround over-optimisation bug in o/v
				olv.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
			}
			
			currentDocument?.undoManager?.setActionName(NSLocalizedString("Move Style Component To Group", comment: ""))
			
			return true
		}
		
		return false
	}

	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			return style ?? NSNull()
		} else if let item2 = item as? DKRastGroup {
			return item2.renderer(at: index)
		}
		return NSNull()
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if style == nil {
			return false
		} else if (item as AnyObject as! NSObject) == NSNull() {
			return true
		} else {
			return item is DKRastGroup
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return 1
		} else if let item = item as? DKRastGroup {
			return item.countOfRenderList
		}
		
		return 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
		guard let identifier = tableColumn?.identifier else {
			return nil
		}
		
		switch identifier {
		case classOutlineColumnIdentifier:
			if let item = item as? NSObject {
				return item.className
			} else {
				return style?.className ?? "<nil>"
			}
			
		case enabledOutlineColumnIdentifier:
			if let item = item as? DKRasterizer {
				return item.enabled
			} else {
				return false
			}
		default:
			return nil
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
		guard tableColumn?.identifier == enabledOutlineColumnIdentifier,
			let obj = object as? Bool,
			let item = item as? DKRasterizer else {
				return
		}
		item.enabled = obj
	}
	
	func outlineView(_ olv: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
		LogEvent(.infoEvent, "proposing drop on \((item as? CustomStringConvertible)?.description ?? "<nil>"), childIndex = \(index)")
		if let item = item as? DKRastGroup {
			if index == NSOutlineViewDropOnItemIndex {
				olv.setDropItem(item, dropChildIndex: 0)
			} else {
				olv.setDropItem(item, dropChildIndex: index)
			}
			
			return .generic
		} else {
			return []
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, writeItems rows: [Any], to pasteboard: NSPasteboard) -> Bool {
		LogEvent(.infoEvent, "starting drag in outline view, array = \(rows)")
		
		mDragItem = rows.first as? DKRasterizer
		
		if mDragItem === style {
			return false
		}
		
		// just write dummy data to the pboard - it's all internal so we just keep a reference to the item being moved

		pasteboard.declareTypes([.dkTableRowInternalDrag], owner: self)
		pasteboard.setData(Data(), forType: .dkTableRowInternalDrag)
		return true
	}

	// MARK: - As an NSOutlineView delegate
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		// select the appropriate tab for the selected item and set up its contents

		let row = outlineView.selectedRow
		if row == -1 {
			selectTabPane(forObject: nil)
		} else {
			let item = outlineView.item(atRow: row)
			
			if !(style?.locked == false) {
				selectTabPane(forObject: style)
			} else {
				selectTabPane(forObject: item as? DKRasterizer)
			}
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, toolTipFor cell: NSCell, rect: NSRectPointer, tableColumn: NSTableColumn?, item: Any, mouseLocation: NSPoint) -> String {
		return (item as? DKRasterizer)?.styleScript ?? ""
	}
	
	func outlineView(_ outlineView: NSOutlineView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, item: Any) {
		guard let tableIdentifier = tableColumn?.identifier else {
			return
		}
		switch tableIdentifier {
		case classOutlineColumnIdentifier:
			if (style?.locked ?? false) {
				(cell as! NSTextFieldCell).textColor = NSColor.disabledControlTextColor
			} else {
				(cell as! NSTextFieldCell).textColor = NSColor.textColor
			}
			
		case enabledOutlineColumnIdentifier:
			(cell as! NSCell).isEnabled = !(style?.locked ?? true)
			break
			
		default:
			break
		}
	}
}
