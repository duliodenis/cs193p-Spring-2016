//
//  TextTableViewController.swift
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class TextTableViewController: UITableViewController, UITextViewDelegate
{
    // MARK: Public API
    
    // outer Array is the sections
    // inner Array is the data in each row

    var data: [Array<String>]? {
        didSet {
            if oldValue == nil || data == nil {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: Text View Handling
    
    // this can be overridden to customize the look of the UITextViews

    func createTextViewForIndexPath(indexPath: NSIndexPath?) -> UITextView {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        textView.scrollEnabled = true
        textView.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        textView.opaque = false
        textView.backgroundColor = UIColor.clearColor()
        return textView
    }
    
    private func cellForTextView(textView: UITextView) -> UITableViewCell? {
        var view = textView.superview
        while (view != nil) && !(view! is UITableViewCell) { view = view!.superview }
        return view as? UITableViewCell
    }

    // MARK: UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?[section].count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let textView = createTextViewForIndexPath(indexPath)
        textView.frame = cell.contentView.bounds
        textViewWidth = textView.frame.size.width
        textView.text = data?[indexPath.section][indexPath.row]
        textView.delegate = self
        cell.contentView.addSubview(textView)
        return cell
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        if data != nil {
            data![toIndexPath.section].insert(data![fromIndexPath.section][fromIndexPath.row], atIndex: toIndexPath.row)
            let fromRow = fromIndexPath.row + ((toIndexPath.row < fromIndexPath.row) ? 1 : 0)
            data![fromIndexPath.section].removeAtIndex(fromRow)
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            data?[indexPath.section].removeAtIndex(indexPath.row)
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return heightForRowAtIndexPath(indexPath)
    }
    
    private var textViewWidth: CGFloat?
    private lazy var sizingTextView: UITextView = self.createTextViewForIndexPath(nil)

    private func heightForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section < data?.count && indexPath.row < data?[indexPath.section].count {
            if let contents = data?[indexPath.section][indexPath.row] {
                if let textView = visibleTextViewWithContents(contents) {
                    return textView.sizeThatFits(CGSize(width: textView.bounds.size.width, height: tableView.bounds.size.height)).height + 1.0
                } else {
                    let width = textViewWidth ?? tableView.bounds.size.width
                    sizingTextView.text = contents
                    return sizingTextView.sizeThatFits(CGSize(width: width, height: tableView.bounds.size.height)).height + 1.0
                }
            }
        }
        return UITableViewAutomaticDimension
    }
    
    private func visibleTextViewWithContents(contents: String) -> UITextView? {
        for cell in tableView.visibleCells {
            for subview in cell.contentView.subviews {
                if let textView = subview as? UITextView where textView.text == contents {
                    return textView
                }
            }
        }
        return nil
    }

    // MARK: UITextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        if let cell = cellForTextView(textView), let indexPath = tableView.indexPathForCell(cell) {
            data?[indexPath.section][indexPath.row] = textView.text
        }
        updateRowHeights()
        let editingRect = textView.convertRect(textView.bounds, toView: tableView)
        if !tableView.bounds.contains(editingRect) {
            // should actually scroll to be clear of keyboard too
            // but for now at least scroll to visible ...
            tableView.scrollRectToVisible(editingRect, animated: true)
        }
        textView.setContentOffset(CGPointZero, animated: true)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet()) != nil {
            returnKeyPressed(inTextView: textView)
            return false
        } else {
            return true
        }
    }
    
    func returnKeyPressed(inTextView textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    @objc private func updateRowHeights() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: Content Size Category Change Notifications
    
    private var contentSizeObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeObserver = NSNotificationCenter.defaultCenter().addObserverForName(
        UIContentSizeCategoryDidChangeNotification,
        object: nil,
        queue: NSOperationQueue.mainQueue()
        ) { notification in
            // give all the UITextViews a chance to react, then resize our row heights
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.updateRowHeights), userInfo: nil, repeats: false)
        }
    }
    
    deinit {
        if contentSizeObserver != nil {
            NSNotificationCenter.defaultCenter().removeObserver(contentSizeObserver!)
            contentSizeObserver = nil
        }
    }
}
