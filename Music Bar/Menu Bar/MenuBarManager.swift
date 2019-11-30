//
//  MenuBarManager.swift
//  Music Bar
//
//  Created by Musa Semou on 27/11/2019.
//  Copyright © 2019 Musa Semou. All rights reserved.
//

import AppKit

class MenuBarManager {
	// MARK: - Properties
	static let shared = MenuBarManager()
	static let defaultButtonTitle = "Music Bar"
	
	let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
	var trackDataDidChangeObserver: NSObjectProtocol?
	
	// MARK: - Initializers
	private init() {}
	
	// MARK: - Functions
	func initializeManager() {
		// Initialize status item button
		if let button = statusItem.button {
			button.title = MenuBarManager.defaultButtonTitle
			button.target = self
			button.action = #selector(statusItemClicked)
			button.sendAction(on: [.leftMouseUp, .rightMouseUp])
		}
		
		// Add TrackDataDidChange observer
		trackDataDidChangeObserver = NotificationCenter.observe(name: .TrackDataDidChange) {
			self.updateButtonTitle()
		}
	}
	
	func deinitializeManager() {
		// Remove TrackDataDidChange observer
		if let observer = trackDataDidChangeObserver {
			NotificationCenter.default.removeObserver(observer)
		}
	}
	
	// Updates the status item's button title according to the current track
	func updateButtonTitle() {
		if let button = statusItem.button {
			if let track = MusicApp.shared.currentTrack {
				button.title = track.displayText
				return
			}
			
			button.title = MenuBarManager.defaultButtonTitle
		}
	}
	
	// Opens the popover when the status item is clicked
	@objc func statusItemClicked() {
		// Retrieve the VC
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		guard let vc = storyboard.instantiateController(withIdentifier: "PlayerViewController") as? PlayerViewController else {
			fatalError("VC not found")
		}
		
		// Create invisible window
		let invisibleWindow = NSWindow(contentRect: NSMakeRect(0, 0, 20, 5), styleMask: .borderless, backing: .buffered, defer: false)
		invisibleWindow.backgroundColor = .red
		invisibleWindow.alphaValue = 0
		
		let buttonRect:NSRect = statusItem.button!.convert(statusItem.button!.bounds, to: nil)
		let screenRect:NSRect = statusItem.button!.window!.convertToScreen(buttonRect)
		
		let posX = screenRect.origin.x + (screenRect.width / 2) - 10
		let posY = screenRect.origin.y
		
		invisibleWindow.setFrameOrigin(NSPoint(x: posX, y: posY))
		invisibleWindow.makeKeyAndOrderFront(self)
		
		// Create popover and set properties
		let popover = NSPopover()
		popover.contentViewController = vc
		popover.behavior = .transient
		
		
		// Show the popover
		//popover.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
		popover.show(relativeTo: invisibleWindow.contentView!.frame, of: invisibleWindow.contentView!, preferredEdge: NSRectEdge.minY)
		
		// Set the app to be active
		// This is crucial in order to achieve the "unfocus" behavior when a user interacts with another application
		NSApp.activate(ignoringOtherApps: true)
	}
}
