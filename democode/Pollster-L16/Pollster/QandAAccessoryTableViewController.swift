//
//  QandAAccessoryDoneTableViewController.swift
//  Pollster
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

// Adds accessoryValues for the cells

class QandAAccessoryTableViewController: QandATableViewController
{
    // MARK: Public API

    // key is content found in a cell
    // value is what to put in the accessory label for that cell
    // note: if two cells have the same content, they'll both get the same accessory value
    // (which may or may not be what you want, but there it is)

    var accessoryValues = [String:CustomStringConvertible]() {
        didSet {
            for content in data?[Section.Answers] ?? [] {
                accessoryLabelForContent(content)?.text = "\(accessoryValues[content] ?? "")"
            }
        }
    }
    
    // MARK: - Private Implementation

    private func accessoryLabelForContent(content: String) -> UILabel? {
        for cell in tableView.visibleCells {
            for subview in cell.contentView.subviews {
                if let textView = subview as? UITextView where textView.text == content {
                    for subview in textView.subviews {
                        if let label = subview as? UILabel {
                            return label
                        }
                    }
                }
            }
        }
        return nil
    }
    
    override func createTextViewForIndexPath(indexPath: NSIndexPath?) -> UITextView {
        let textView = super.createTextViewForIndexPath(indexPath)
        createAccessoryLabel(inTextView: textView)
        return textView
    }
    
    private func createAccessoryLabel(inTextView textView: UITextView) {
        let label = UILabel()
        label.textAlignment = .Right
        label.text = "100"
        label.sizeToFit()
        let width = label.bounds.size.width
        label.frame = CGRect(x: textView.bounds.maxX - width, y: 0, width: width, height: textView.bounds.size.height)
        label.text = ""
        label.autoresizingMask = [.FlexibleHeight,.FlexibleLeftMargin]
        textView.addSubview(label)
    }

    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if asking && indexPath.section == Section.Answers {
            if let answerInRow = data?[indexPath.section][indexPath.row] {
                accessoryLabelForContent(answerInRow)?.text = "\(accessoryValues[answerInRow] ?? "")"
            }
        }
        return cell
    }
}
