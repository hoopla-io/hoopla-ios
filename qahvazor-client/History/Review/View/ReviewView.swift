//
//  ReviewView.swift
//  qahvazor-client
//

import UIKit

final class ReviewView: CustomView {
    
    // MARK: - UI Elements
    
    let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 26.0, *) {
            var config = UIButton.Configuration.glass()
            config.image = UIImage(systemName: "xmark")
            config.baseForegroundColor = .label
            btn.configuration = config
        } else {
            btn.setImage(UIImage(systemName: "xmark"), for: .normal)
            btn.tintColor = .label
        }
        return btn
    }()
    
    let drinkImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    let drinkNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = .label
        return lbl
    }()
    
    let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = .systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let experienceLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "howWasExperience".localized
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        lbl.textColor = .label
        return lbl
    }()
    
    let cosmosView: CosmosView = {
        let cv = CosmosView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.emptyImage = UIImage.star
        cv.filledImage = UIImage.starFull
        cv.settings.fillMode = .full
        cv.settings.starSize = 40
        cv.settings.starMargin = 8
        cv.settings.updateOnTouch = true
        cv.settings.minTouchRating = 1
        cv.rating = 0
        return cv
    }()
    
    private let reasonLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "whyDidYouLoveIt".localized
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        lbl.textColor = .label
        return lbl
    }()
    
    let tagsContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let commentTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = .systemFont(ofSize: 14)
        tv.textColor = .label
        tv.layer.cornerRadius = 12
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.separator.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        tv.isScrollEnabled = false
        return tv
    }()
    
    let placeholderLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "anythingElse".localized
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = .placeholderText
        return lbl
    }()
    
    let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 26.0, *) {
            var config: UIButton.Configuration
            config = .clearGlass()
            config.baseForegroundColor = .appColor(.white)
            config.cornerStyle = .large
            config.title = "submit".localized
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                return outgoing
            }
            btn.configuration = config
            btn.backgroundColor = .main
        } else {
            btn.setTitle("submit".localized, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            btn.backgroundColor = .main
            btn.setTitleColor(.white, for: .normal)
            btn.layer.cornerRadius = 12
            btn.layer.cornerCurve = .continuous
        }
        return btn
    }()
    
    // MARK: - Tag Buttons Storage
    var tagButtons: [UIButton] = []
    
    // MARK: - Private
    private var tagsHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(closeButton)
        
        // Drink info
        let nameStack = UIStackView(arrangedSubviews: [drinkNameLabel, dateLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2
        nameStack.translatesAutoresizingMaskIntoConstraints = false
        
        let drinkStack = UIStackView(arrangedSubviews: [drinkImageView, nameStack])
        drinkStack.axis = .horizontal
        drinkStack.spacing = 12
        drinkStack.alignment = .center
        drinkStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(drinkStack)
        
        addSubview(experienceLabel)
        addSubview(cosmosView)
        addSubview(reasonLabel)
        addSubview(tagsContainerView)
        
        // Comment
        addSubview(commentTextView)
        commentTextView.addSubview(placeholderLabel)
        
        // Submit
        addSubview(submitButton)
        
        tagsHeightConstraint = tagsContainerView.heightAnchor.constraint(equalToConstant: 80)
        tagsHeightConstraint?.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            drinkStack.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 12),
            drinkStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            drinkStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20),
            
            drinkImageView.widthAnchor.constraint(equalToConstant: 44),
            drinkImageView.heightAnchor.constraint(equalToConstant: 44),
            
            experienceLabel.topAnchor.constraint(equalTo: drinkStack.bottomAnchor, constant: 20),
            experienceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            cosmosView.topAnchor.constraint(equalTo: experienceLabel.bottomAnchor, constant: 12),
            cosmosView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            reasonLabel.topAnchor.constraint(equalTo: cosmosView.bottomAnchor, constant: 20),
            reasonLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            tagsContainerView.topAnchor.constraint(equalTo: reasonLabel.bottomAnchor, constant: 12),
            tagsContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tagsContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            tagsHeightConstraint!,
            
            commentTextView.topAnchor.constraint(equalTo: tagsContainerView.bottomAnchor, constant: 16),
            commentTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            commentTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            commentTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            placeholderLabel.topAnchor.constraint(equalTo: commentTextView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: commentTextView.leadingAnchor, constant: 13),
            
            submitButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.topAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: 16),
        ])
    }
    
    // MARK: - Tags Layout
    func configureTags(_ tags: [String], target: Any, action: Selector) {
        // Remove old tags
        tagButtons.forEach { $0.removeFromSuperview() }
        tagButtons.removeAll()
        
        let horizontalSpacing: CGFloat = 8
        let verticalSpacing: CGFloat = 8
        let maxWidth = UIScreen.main.bounds.width - 40 // 20 + 20 padding
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for (index, tag) in tags.enumerated() {
            var config = UIButton.Configuration.plain()
            config.title = tag
            config.baseForegroundColor = .label
            config.background.backgroundColor = .clear
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                return outgoing
            }
            
            let button = UIButton(configuration: config)
            button.tag = index
            button.addTarget(target, action: action, for: .touchUpInside)
            
            // Border styling
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.separator.cgColor
            button.layer.cornerRadius = 18
            button.layer.cornerCurve = .continuous
            
            button.sizeToFit()
            let buttonWidth = button.frame.width
            let buttonHeight: CGFloat = 36
            
            // Check if button fits in current row
            if currentX + buttonWidth > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + verticalSpacing
            }
            
            button.frame = CGRect(x: currentX, y: currentY, width: buttonWidth, height: buttonHeight)
            tagsContainerView.addSubview(button)
            tagButtons.append(button)
            
            rowHeight = buttonHeight
            currentX += buttonWidth + horizontalSpacing
        }
        
        let totalHeight = currentY + rowHeight
        tagsHeightConstraint?.constant = totalHeight
    }
    
    func updateTagButton(_ button: UIButton, selected: Bool) {
        if selected {
            button.configuration?.baseForegroundColor = .white
            button.configuration?.background.backgroundColor = .main
            button.layer.borderColor = UIColor.main.cgColor
        } else {
            button.configuration?.baseForegroundColor = .label
            button.configuration?.background.backgroundColor = .clear
            button.layer.borderColor = UIColor.separator.cgColor
        }
    }
}
