//
//  ViewController.swift
//  TaiwanExhibitionsWithRx
//
//  Created by Chuan-Jie Jhuang on 2022/4/25.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UITableViewDelegate {

    private let viewModel = ExhibitionsViewModel(apiService: API())
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Life Cycles
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupTableView()
        setupNavigation()
        bindViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.setContentOffset(CGPoint(x: 0, y: -44), animated: false)
        self.refreshControl.beginRefreshing()
        self.viewModel.triggerAPI.onNext(())
    }
    
    // MARK: - Private Methods
    
    private func setupTableView() {
        tableView.register(UINib(nibName:String(describing: ExhibitionTableViewCell.self), bundle:nil), forCellReuseIdentifier:String(describing: ExhibitionTableViewCell.self))
        tableView.refreshControl = refreshControl
        tableView.rx.itemSelected.subscribe { [weak self] indexPath in
            self?.tableView.deselectRow(at: indexPath, animated: true)
        }.disposed(by: disposeBag)
    }
    
    private func setupNavigation() {
        navigationItem.title = "展場資訊"
    }
    
    private func bindViewModel() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewModel.data
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ExhibitionTableViewCell.self)) as? ExhibitionTableViewCell else { return UITableViewCell() }
                
                cell.config(item: element)
                
                return cell
            }.disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged).bind(to: viewModel.triggerAPI).disposed(by: disposeBag)
        viewModel.isLoading.bind(to: refreshControl.rx.isRefreshing).disposed(by: disposeBag)
    }
    
}

