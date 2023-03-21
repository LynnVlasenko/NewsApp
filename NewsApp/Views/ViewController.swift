//
//  ViewController.swift
//  NewsApp
//
//  Created by Алина Власенко on 20.03.2023.
//

import UIKit
import SafariServices //для представлення статті у Safari

class ViewController: UIViewController {
    
    //отримаємо екземпляр нашого пошуку
    private let searchVC = UISearchController(searchResultsController: nil) //замість контроллера результатів пошуку ми просто фільтруємо на основі результатів
    
    private var articles = [Article]()
    private var viewModels = [NewsTableViewCellViewModel]()
    
    //MARK: - UI objects
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        return table
    }()
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchTopArticles()
        createSearchBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: - Private
    
    private func fetchTopArticles() {
        APICaller.shared.getTopArticles { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles //зберігаємо статті, для перегляду по натисканню
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(
                        title: $0.title,
                        subtitle: $0.description ?? "No Descriotion",
                        imageURL: URL(string: $0.urlToImage ?? "")
                    )
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //SearchBar
    private func createSearchBar() {
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self //дозволяє отримати подію, коли юзер натискає кнопку пошуку на клавіатурі
    }
    
    
}
    
//MARK: - Table extension

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsTableViewCell.identifier,
            for: indexPath
        ) as? NewsTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    //Відображення статті по натисканню
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]
        
        guard let url = URL(string: article.url ?? "") else {
            return
        }
        //спеціальний, контроллер, що дає можливість відкривати статті через сафарі
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}

//MARK: - Search extension

extension ViewController: UISearchBarDelegate {
    //функція, коли кнопка пошуку натиснута
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //отримати текст панелі пошуку
        guard let text = searchBar.text, !text.isEmpty else {
            return
        }
        
        //Звертаємося до API, отримуємо текст для нашого запиту та передаємо дані статей і оновлюємо табличку
        APICaller.shared.search(with: text) { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles //зберігаємо статті, для перегляду по натисканню
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(
                        title: $0.title,
                        subtitle: $0.description ?? "No Descriotion",
                        imageURL: URL(string: $0.urlToImage ?? "")
                    )
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.searchVC.dismiss(animated: true, completion: nil)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //коли скидаєш пошук - повертаються статті з топу
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.searchVC.dismiss(animated: true, completion: nil)
            self.fetchTopArticles()
        }
    }
}
