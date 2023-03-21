//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Алина Власенко on 20.03.2023.
//

import UIKit

//class NewsTableViewCellViewModel {
//    let title: String
//    let subtitle: String
//    let imageURL: URL?
//    var imageData: Data? = nil//для кешування даних, щоб не завантажувати картинку повторно.
//    
//    init(
//        title: String,
//        subtitle: String,
//        imageURL: URL?
//    ) {
//        self.title = title
//        self.subtitle = subtitle
//        self.imageURL = imageURL
//    }
//}

class NewsTableViewCell: UITableViewCell {
    
    static let identifier = "NewsTableViewCell"
    
    //MARK: - UI objects
    private let newsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    //MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
    }
    
    //MARK: - addSubviews
    private func addSubviews() {
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(newsImageView)
    }
    
    //MARK: - coder for error
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        newsTitleLabel.frame = CGRect(
            x: 10,
            y: 0,
            width: contentView.frame.size.width - 170,
            height: 70
        )
        subtitleLabel.frame = CGRect(
            x: 10,
            y: 70,
            width: contentView.frame.size.width - 170,
            height: contentView.frame.size.height/2
        )
        newsImageView.frame = CGRect(
            x: contentView.frame.size.width - 150,
            y: 5,
            width: 140,
            height: contentView.frame.size.height - 10
        )
    }
    
    //MARK: - functions
    //обнулення даних для повторного використкання
    override func prepareForReuse() {
        super.prepareForReuse()
        newsTitleLabel.text = nil
        subtitleLabel.text = nil
        newsImageView.image = nil
    }
    
    //конфігурація з моделлю
    func configure(with viewModel: NewsTableViewCellViewModel) {
        newsTitleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        
        // Image - відображеня картинки з API
        if let data = viewModel.imageData {
            newsImageView.image = UIImage(data: data)
        }
        else if let url = viewModel.imageURL {
            //fetch
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                //для кешування отриманих даних
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.newsImageView.image = UIImage(data: data) //self опціональний, щоб не спричинити витік пам'яті
                }
            }.resume()
        }
    }
}
