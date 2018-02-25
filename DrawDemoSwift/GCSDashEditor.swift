//
//  GCSDashEditor.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 2/1/18.
//  Copyright © 2018 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.DKStrokeDash
import DrawKitSwift

class GCSDashEditor: NSWindowController, GCSDashEditViewDelegate {
	@IBOutlet weak var dashMarkTextField1: NSTextField!
	@IBOutlet weak var dashSpaceTextField1: NSTextField!
	@IBOutlet weak var dashMarkTextField2: NSTextField!
	@IBOutlet weak var dashSpaceTextField2: NSTextField!
	@IBOutlet weak var dashMarkTextField3: NSTextField!
	@IBOutlet weak var dashSpaceTextField3: NSTextField!
	@IBOutlet weak var dashMarkTextField4: NSTextField!
	@IBOutlet weak var dashSpaceTextField4: NSTextField!
	@IBOutlet weak var dashCountButtonMatrix: NSMatrix!
	@IBOutlet weak var dashScaleCheckbox: NSButton!
	@IBOutlet weak var dashPreviewEditView: GCSDashEditView!
	@IBOutlet weak var previewCheckbox: NSButton!
	@IBOutlet weak var phaseSlider: NSSlider?
	private weak var mDelegateRef: GCSDashEditorDelegate? = nil
	
	
	private func mEF(_ i: Int) -> NSTextField? {
		switch i {
		case 0:
			return dashMarkTextField1
			
		case 1:
			return dashSpaceTextField1
			
		case 2:
			return dashMarkTextField2
			
		case 3:
			return dashSpaceTextField2
			
		case 4:
			return dashMarkTextField3
			
		case 5:
			return dashSpaceTextField3
			
		case 6:
			return dashMarkTextField4
			
		case 7:
			return dashSpaceTextField4
			
		default:
			return nil
		}
	}
	
	private var parentWindow: NSWindow?
	
	func open(inParentWindow pw: NSWindow, modalDelegate del: GCSDashEditorDelegate) {
		if dash == nil {
			dash = DKStrokeDash()
		}
		
		parentWindow = pw
		mDelegateRef = del
		
		pw.beginSheet(window!) { (returnCode) in
			let ctxInfo = Unmanaged.passUnretained(self).toOpaque()
			del.sheetDidEnd(self.window!, returnCode: returnCode, contextInfo: ctxInfo)
			self.parentWindow = nil
		}
		notifyDelegate()
	}
	
	func updateForDash() {
		// set UI to match current dash
		
		dashPreviewEditView.dash = dash
		dashCount = dash?.count ?? 1
		dashScaleCheckbox.state = (dash?.scalesToLineWidth ?? false) ? .on : .off
		phaseSlider?.objectValue = dash?.phase ?? 1
	}
	
	var dash: DKStrokeDash? {
		didSet {
			updateForDash()
		}
	}
	
	var lineWidth: CGFloat {
		get {
			return dashPreviewEditView.lineWidth
		}
		set {
			dashPreviewEditView.lineWidth = newValue
		}
	}
	var lineCapStyle: NSBezierPath.LineCapStyle {
		get {
			return dashPreviewEditView.lineCapStyle
		}
		set {
			dashPreviewEditView.lineCapStyle = newValue
		}
	}
	var lineJoinStyle: NSBezierPath.LineJoinStyle {
		get {
			return dashPreviewEditView.lineJoinStyle
		}
		set {
			dashPreviewEditView.lineJoinStyle = newValue
		}
	}
	var lineColour: NSColor {
		get {
			return dashPreviewEditView.lineColour
		}
		set {
			dashPreviewEditView.lineColour = newValue
		}
	}
	
	/// The relevant number of fields.
	var dashCount: Int {
		get {
			return dash?.pattern.count ?? 0
		}
		set(c) {
			var count = 0
			var d = [CGFloat](repeating: 1, count: 8)

			dash?.getPattern(&d, count: &count)
			
			if count != c {
				dash?.setPattern(d, count: c)
				count = c
			}
			
			for i in 0..<8 {
				if i < count {
					mEF(i)?.objectValue = d[i]
				} else {
					mEF(i)?.stringValue = ""
				}
				
				mEF(i)?.isEnabled = i < count
			}
			
			dashCountButtonMatrix.selectCell(atRow: 0, column: (c - 1) / 2)
			phaseSlider?.maxValue = Double(dash?.length ?? 1)
		}
	}
	
	private func notifyDelegate() {
		if previewCheckbox.state == .on {
			mDelegateRef?.dashDidChange?(self)
		}
	}
	
	
	@IBAction func ok(_ sender: Any?) {
		window!.orderOut(self)
		parentWindow!.endSheet(window!, returnCode: .OK)
	}
	
	@IBAction func cancel(_ sender: Any?) {
		window!.orderOut(self)
		parentWindow!.endSheet(window!, returnCode: .cancel)
	}
	
	@IBAction func dashValueAction(_ sender: Any?) {
		var count = 0
		var d = [CGFloat](repeating: 1, count: 8)
		
		count = dash!.count
		
		for i in 0 ..< count {
			if let newFloat = mEF(i)?.objectValue as? CGFloat {
				d[i] = newFloat
			}
		}
		
		dash?.setPattern(d, count: count)
		notifyDelegate()
		phaseSlider?.maxValue = Double(dash!.length)
		dashPreviewEditView.needsDisplay = true
	}
	
	@IBAction func dashScaleCheckboxAction(_ sender: Any?) {
		if let preScale: NSControl.StateValue? = (sender as AnyObject?)?.state,
			let scale = preScale {
			dash?.scalesToLineWidth = scale == .on
		} else {
			dash?.scalesToLineWidth = false
		}
		notifyDelegate()
		dashPreviewEditView.needsDisplay = true
	}
	
	@IBAction func dashCountMatrixAction(_ sender: Any?) {
		let column = (sender as AnyObject?)?.selectedColumn ?? 0
		let count = (column + 1) * 2
		dashCount = count
		notifyDelegate()
		dashPreviewEditView.needsDisplay = true
	}
	
	@IBAction func dashPhaseSliderAction(_ sender: Any!) {
		if let prePhase = (sender as AnyObject?)?.objectValue,
			let phase = prePhase as? CGFloat {
			dash?.phase = phase
		} else {
			dash?.phase = 0
		}
		notifyDelegate()
		dashPreviewEditView.needsDisplay = true
	}

	func dashDidChange(_ sender: Any?) {
		dashCount = dash?.count ?? 1
		notifyDelegate()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		previewCheckbox.integerValue = 1;
		phaseSlider?.isHidden = true
		dashPreviewEditView.delegate = self;
		updateForDash()
	}
}
