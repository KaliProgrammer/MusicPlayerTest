//
//  ViewController.swift
//  MusicPlayerTestovoe
//
//  Created by MacBook Air on 27.05.2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MainViewController: UIViewController {
    
    let viewModel = MainViewModel()
    let disposeBag = DisposeBag()
    var position: Int = 0
    
    //MARK: - UI Components

      private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.reuseIdentifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.theme.backgroundColor
        bindToTableView()
        trackViewControllerAppear()
        setupUIElements()
    }
    
    private func bindToTableView() {
        viewModel.tracks.bind(to: tableView
            .rx
            .items(cellIdentifier: CustomCell.reuseIdentifier, cellType: CustomCell.self)) {
                (indexPath, tracks, cell) in
                cell.applyName(bandName: tracks.bandName, trackName: tracks.trackName)
                cell.applyTiming(time: tracks.timing)
            }
            .disposed(by: disposeBag)
    }
    
    func trackViewControllerAppear() {
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Track.self)).bind { [weak self] indexPath, track in
            guard let self = self else { return }
            
            self.position = indexPath.row
            
            let trackVC = TrackViewController()
            trackVC.bandName.accept(track.bandName)
            trackVC.trackName.accept(track.trackName)
            
            trackVC.position.accept(self.position)
            
            self.present(trackVC, animated: true)
        }
        .disposed(by: disposeBag)
    }
    
    //Setup UI elements
    
    private func setupUIElements() {
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }
}

