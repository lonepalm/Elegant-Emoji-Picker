//
//  CategoriesToolbar.swift
//  Demo
//
//  Created by Grant Oganyan on 3/10/23.
//

import Foundation
import UIKit

class SectionsToolbar: UIView {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    weak var emojiPicker: ElegantEmojiPicker?
    
    let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    let selectionBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    
    var selectionConstraint: NSLayoutConstraint?
    
    var categoryButtons = [SectionButton]()
    
    init (sections: [EmojiSection], emojiPicker: ElegantEmojiPicker) {
        self.emojiPicker = emojiPicker
        super.init(frame: .zero)
        
        self.addSubview(blur, anchors: LayoutAnchor.fullFrame)
        blur.layer.shadowColor = UIColor.black.cgColor
        blur.layer.shadowOpacity = 0.15
        blur.layer.shadowOffset = .zero
        blur.layer.shadowRadius = 2
        
        let horizontalEdgePadding = 14.0
        let selectionDimension = 36.0
        selectionBlur.clipsToBounds = true
        selectionBlur.backgroundColor = .label.withAlphaComponent(0.2)
        selectionBlur.layer.cornerRadius = selectionDimension / 2.0
        self.addSubview(selectionBlur, anchors: [.top((Self.contentHeight - selectionDimension) / 2.0), .width(selectionDimension), .height(selectionDimension)])
        
        selectionConstraint = selectionBlur.centerXAnchor.constraint(equalTo: self.leadingAnchor)
        selectionConstraint?.isActive = true
        
        for i in 0..<sections.count {
            let button = SectionButton(i, icon: sections[i].icon, emojiPicker: emojiPicker)
            
            let prevButton: UIView? = categoryButtons.last
            
            self.addSubview(button, anchors: [.top(0), .height(Self.contentHeight)])
            categoryButtons.append(button)

            button.leadingAnchor.constraint(equalTo: prevButton?.trailingAnchor ?? self.leadingAnchor, constant: prevButton != nil ? 0 : horizontalEdgePadding).isActive = true
            if let prevButton = prevButton { button.widthAnchor.constraint(equalTo: prevButton.widthAnchor).isActive = true }
        }
        
        if let lastButton = self.subviews.last {
            lastButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -horizontalEdgePadding).isActive = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        UpdateCorrectSelection(animated: false)
    }
    
    func UpdateCorrectSelection (animated: Bool = true) {
        guard let emojiPicker = emojiPicker else { return }

        if !emojiPicker.isSearching { self.alpha = emojiPicker.config.categories.count <= 1 ? 0 : 1 }
        
        let posX: CGFloat? = categoryButtons.indices.contains(emojiPicker.focusedSection) ? categoryButtons[emojiPicker.focusedSection].center.x : nil
        let safePos: CGFloat = posX ?? categoryButtons.first?.center.x ?? 0
        
        if animated {
            selectionConstraint?.constant = safePos
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
            return
        }
        
        selectionConstraint?.constant = safePos
    }
    
    class SectionButton: UIView {
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        let imageView = UIImageView()
        
        let section: Int
        weak var emojiPicker: ElegantEmojiPicker?
        
        init (_ section: Int, icon: UIImage?, emojiPicker: ElegantEmojiPicker) {
            self.section = section
            self.emojiPicker = emojiPicker
            super.init(frame: .zero)
            
            imageView.image = icon
            imageView.contentMode = .center
            imageView.tintColor = .label.withAlphaComponent(0.5)
            self.addSubview(imageView, anchors: LayoutAnchor.fullFrame(8))
            
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Tap)))
        }
        
        @objc func Tap () {
            guard let emojiPicker = emojiPicker else { return }
            emojiPicker.didSelectSection(section)
        }
    }
    
    static let contentHeight = 50.0
}
