//
//  EventDetailController.swift
//  Fetch Rewards Challenge
//
//  Created by Stanley Traub on 12/10/20.
//

import UIKit
import RealmSwift

class EventDetailController: UIViewController {
    
    // MARK: - Properties
        
    var viewModel: EventViewModel? {
        didSet { configureWithViewModel() }
    }
    
    let realm = try! Realm()
    
    private let gradientLayer = CAGradientLayer()
    
    private let eventImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        button.setImage(image, for: .normal)
        button.setDimensions(height: 30, width: 30)
        button.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setDimensions(height: 30, width: 30)
        button.addTarget(self, action: #selector(handleFavoriteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let eventTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Actions
    
    @objc private func handleBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleFavoriteButtonTapped() {
        guard let viewModel = viewModel else { return }
        didFavoriteEvent(eventID: viewModel.id)
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(eventImageView)
        eventImageView.anchor(top: view.topAnchor)
        eventImageView.setDimensions(height: view.frame.height / 3, width: view.frame.width)
        
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingLeft: 20)
        
        view.addSubview(favoriteButton)
        favoriteButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingRight: 20)
        
        configureGradientLayer()
        
        let stack = UIStackView(arrangedSubviews: [eventTitleLabel, dateLabel, locationLabel])
        stack.axis = .vertical
        stack.spacing = 8
        
        view.addSubview(stack)
        stack.anchor(top: eventImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 20, paddingRight: 20)
        
    }
    
    private func configureWithViewModel() {
        guard let viewModel = viewModel else { return }
        eventImageView.sd_setImage(with: viewModel.image)
        eventTitleLabel.text = viewModel.title
        dateLabel.text = viewModel.date
        locationLabel.text = viewModel.location
        favoriteButton.setImage(viewModel.favoriteButtonImageDetailController, for: .normal)
    }
    
    private func configureGradientLayer() {
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [-0.03, 0.05]
        gradientLayer.frame = view.frame
        view.layer.addSublayer(gradientLayer)
    }
    
    private func addFavoriteEvent(eventID: Int) {
        guard let viewModel = viewModel else { return }
        let event = FavoritedEvent()
        event.eventId = eventID
        
        do {
            try realm.write {
                realm.add(event)
                viewModel.event.favorited.toggle()
                DispatchQueue.main.async {
                    self.favoriteButton.setImage(viewModel.favoriteButtonImageDetailController, for: .normal)
                }
            }
        } catch {
            print("Error saving event \(error)")
        }
    }
    
    private func unfavoriteEvent(eventID: Int) {
        guard let viewModel = viewModel else { return }
        let event = realm.objects(FavoritedEvent.self).filter("eventId == \(eventID)")
        
        do {
            try realm.write {
                realm.delete(event)
                viewModel.event.favorited.toggle()
                DispatchQueue.main.async {
                    self.favoriteButton.setImage(viewModel.favoriteButtonImageDetailController, for: .normal)
                }
            }
        } catch {
            print("Error deleting event \(error)")
        }
    }
}

// MARK: - EventFavoritedProtocol

extension EventDetailController: EventFavoritedProtocol {
    func didFavoriteEvent(eventID: Int) {
        guard let viewModel = viewModel else { return }
        
        if viewModel.event.favorited {
            unfavoriteEvent(eventID: eventID)
        } else {
            addFavoriteEvent(eventID: eventID)
        }

    }
}
