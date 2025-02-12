//
//  File.swift
//  Fetch Rewards Challenge
//
//  Created by Stanley Traub on 12/9/20.
//

import UIKit
import SDWebImage

protocol EventFavoritedProtocol: class {
    func didFavoriteEvent(eventID: Int)
}

class EventCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "EventCell"
    
    weak var delegate: EventFavoritedProtocol?
    
    var viewModel: EventDetailViewModel? {
        didSet { configure() }
    }
    
    private let eventImage: UIImageView = {
        let iv = UIImageView()
        iv.setDimensions(height: 90, width: 90)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 22
        if #available(iOS 13.0, *) {
            iv.layer.cornerCurve = .continuous
        } else {
            // Fallback on earlier versions
        }
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        label.numberOfLines = 0
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .darkGray
        }
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .darkGray
        }
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setDimensions(height: 30, width: 30)
        button.addTarget(self, action: #selector(handleFavoriteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(eventImage)
        eventImage.anchor(top:topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 20)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, locationLabel, dateLabel])
        stack.axis = .vertical
        stack.spacing = 8
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: eventImage.rightAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 20)
        
        contentView.addSubview(favoriteButton)
        favoriteButton.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 20, paddingBottom: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func handleFavoriteButtonTapped() {
        guard let viewModel = viewModel else { return }
        delegate?.didFavoriteEvent(eventID: viewModel.id)
    }
    
    // MARK: - Helpers
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        eventImage.sd_setImage(with: viewModel.image)
        titleLabel.text = viewModel.title
        locationLabel.text = viewModel.location
        dateLabel.text = viewModel.date
        favoriteButton.setImage(viewModel.favoriteButtonImageEventCell, for: .normal)
    }
}
