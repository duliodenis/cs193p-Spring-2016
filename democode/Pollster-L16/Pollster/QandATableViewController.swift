//
//  QandATableViewController
//  Pollster
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

struct QandA {
    var question: String
    var answers: [String]
}

class QandATableViewController: TextTableViewController
{
    // MARK: - Public API

    var qanda: QandA {
        get {
            var answers = [String]()
            if data?.count > 1 {
                for answer in data?.last ?? [] {
                    if !answer.isEmpty { answers.append(answer) }
                }
            }
            return QandA(question: data?.first?.first ?? "", answers: answers)
        }
        set {
            data = [[newValue.question], newValue.answers]
            manageEmptyRow()
        }
    }
    
    var asking = false {
        didSet {
            if asking != oldValue {
                tableView.editing = asking
                tableView.reloadData()
                manageEmptyRow()
            }
        }
    }
    
    var answering: Bool {
        get { return !asking }
        set { asking = !newValue }
    }

    var answer: String? {
        didSet {
            var answerIndex = 0
            while answerIndex < qanda.answers.count {
                if qanda.answers[answerIndex] == answer {
                    let indexPath = NSIndexPath(forRow: answerIndex, inSection: Section.Answers)
                    // be sure we're on screen before we do this (for animation, etc.)
                    NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(chooseAnswer(_:)), userInfo: indexPath , repeats: false)
                    break
                }
                answerIndex += 1
            }
        }
    }
    
    struct Section {
        static let Question = 0
        static let Answers = 1
    }
    
    // MARK: - Private Implementation
    
    func chooseAnswer(timer: NSTimer) {
        if let indexPath = timer.userInfo as? NSIndexPath {
            if tableView.indexPathForSelectedRow != indexPath {
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            }
        }
    }

    // override this to set the UITextView up like we want
    // want .Body font, some margin around the text, and only editable if we are editing the Q&A

    override func createTextViewForIndexPath(indexPath: NSIndexPath?) -> UITextView {
        let textView = super.createTextViewForIndexPath(indexPath)
        let font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textView.font = font.fontWithSize(font.pointSize * 1.7)
        textView.textContainerInset = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        textView.userInteractionEnabled = asking
        return textView
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case Section.Question: return "Question"
            case Section.Answers: return "Answers"
            default: return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        // only answers can be selected
        cell.selectionStyle = (indexPath.section == Section.Answers) ? .Gray : .None
        return cell
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return asking && indexPath.section == Section.Answers
    }
    
    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        answer = data?[indexPath.section][indexPath.row]
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        // only answers can be selected
        return (indexPath.section == Section.Answers) ? indexPath : nil
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidEndEditing(textView: UITextView) {
        manageEmptyRow()
    }
    
    private func manageEmptyRow() {
        if data != nil {
            var emptyRow: Int?
            var row = 0
            while row < data![Section.Answers].count {
                let answer = data![Section.Answers][row]
                if answer.isEmpty {
                    if emptyRow != nil {
                        data![Section.Answers].removeAtIndex(emptyRow!)
                        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: emptyRow!, inSection: Section.Answers)], withRowAnimation: .Automatic)
                        emptyRow = row-1
                    } else {
                        emptyRow = row
                        row += 1
                    }
                } else {
                    row += 1
                }
            }
            if emptyRow == nil {
                if asking {
                    data![Section.Answers].append("")
                    let indexPath = NSIndexPath(forRow: data![Section.Answers].count-1, inSection: Section.Answers)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            } else if !asking {
                data![Section.Answers].removeAtIndex(emptyRow!)
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: emptyRow!, inSection: Section.Answers)], withRowAnimation: .Automatic)
            }
        }
    }
}
