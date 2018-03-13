//
//  VelibMainViewController.swift
//  velib-mobile-ios
//
//  Created by cluster SIG on 11/03/2018.
//  Copyright © 2018 velib. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
enum StandStatus: String {
    case all
    case open
    case close
}
class VelibMainViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var velibTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    // MARK: -Variables
    let velibClient = VelibCient()
    private let tableViewRefreshControl = UIRefreshControl()
    // MARK: -Rx Variables
    var disposeBag = DisposeBag()
    var velibs: BehaviorRelay<[VelibModel]> = BehaviorRelay(value: [VelibModel]())
    var isSuccess: BehaviorRelay<(Bool,String)> = BehaviorRelay(value: (false,""))
    var filtredStands: BehaviorRelay<[VelibModel]> = BehaviorRelay(value: [VelibModel]())
    var filterState: StandStatus = .all
    var searchedText: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initTableView()
        addObserverOnVelibs()
        getVelibs()
        bindVelibs()
        didSelectAtVelibRow() 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /// Init the tableview
    private func initTableView() {
        // Setup the tableview style
        self.velibTableView.alwaysBounceVertical = true
        // -> Prevent empty rows
        self.velibTableView.tableFooterView = UIView()
        // Add the refresh control
        self.tableViewRefreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        self.velibTableView.refreshControl = self.tableViewRefreshControl
        // Register cell
        self.velibTableView.register(UINib(nibName: "VelibTableViewCell", bundle: nil), forCellReuseIdentifier: "VelibTableViewCell")
        // Set Rx delegate
        self.velibTableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
       // self.velibTableView.rx.setDataSource(self).disposed(by: disposeBag)
    }
    /// Refresh List of Velib
    @objc private func refreshList() {
        getVelibs()
    }
    func getVelibs() {
        velibClient.getVelibs(velibs: velibs, isSuccess: isSuccess)
    }
    func addObserverOnVelibs() {
        self.filtredStands.asObservable().subscribe(onNext: { (velibsReturned) in
            self.velibTableView.reloadData()
            self.tableViewRefreshControl.endRefreshing()
        }, onError: { (_) in

        }).disposed(by: disposeBag)
        self.velibs.asObservable().subscribe(onNext: { (velibsReturned) in
            self.filtredStands.accept(self.filterStands())
        }, onError: { (_) in

        }).disposed(by: disposeBag)
    }
    /// Bind tableview with threads
    private func bindVelibs() {
        self.filtredStands.asObservable()
            .bind(to: velibTableView.rx.items(cellIdentifier: "VelibTableViewCell")) {  _, velib, cell in
                if let velibCell = cell as? VelibTableViewCell {
                    velibCell.setupCell(velib: velib)
                }
            }.disposed(by: disposeBag)
    }
    /// Setup the thread cell tap handling
    private func didSelectAtVelibRow() {
        self.velibTableView
            .rx
            .modelSelected(VelibModel.self)
            .subscribe(onNext: { velib in
                if self.velibTableView.indexPathForSelectedRow != nil {
                    let mapController = MapViewController()
                    mapController.velib = velib
                    self.navigationController?.pushViewController(mapController, animated: true)
                }
            }).disposed(by: disposeBag)
    }
    // MARK: -TableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    // MARK: -Actions
    @IBAction func segmentedControlPressed(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            filterState = .all
        case 1:
            filterState = .open
        case 2:
            filterState = .close
        default:
            break
        }
        filtredStands.accept(filterStands())
    }
    func filterStands() -> [VelibModel] {
        var list: [VelibModel] = []
        if filterState != .all {
            list = velibs.value.filter { (velib) in
                velib.status?.lowercased() == filterState.rawValue.lowercased()
            }
        } else {
            list = velibs.value
        }
        if !searchedText.isEmpty && searchedText.lengthOfBytes(using: .utf8) >= 3 {
            list = filterStandsByName(velibs: list, text: searchedText)
        }
        return list
    }
    func filterStandsByName(velibs: [VelibModel], text: String) -> [VelibModel] {
        let list: [VelibModel] = velibs.filter { (velib) in
            velib.name?.lowercased().contains(text.lowercased()) == true
        }
        return list
    }
    func searchByName(searchText: String) -> [VelibModel] {
        var list: [VelibModel] = []
        if searchText.isEmpty || searchText.lengthOfBytes(using: .utf8) < 3 {
            searchedText = ""
            list = filterStands()
        } else if searchText.lengthOfBytes(using: .utf8) >= 3 {
            searchedText = searchText
            list = filterStandsByName(velibs: filtredStands.value, text: searchText)
        }
        return list
    }
}
// MARK: - UISearchBarDelegate
extension VelibMainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtredStands.accept(searchByName(searchText: searchText))
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchedText = ""
        searchBar.text = ""
        filtredStands.accept(filterStands())
    }
}
