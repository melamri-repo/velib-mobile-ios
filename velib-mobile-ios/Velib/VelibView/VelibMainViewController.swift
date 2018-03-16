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
    case closed
}
class VelibMainViewController: UIViewController, UITableViewDelegate {
    // MARK: -Components
    @IBOutlet weak var velibTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // MARK: -Variables
    let velibClient = VelibCient()
    var filterState: StandStatus = .all
    var searchedText: String = ""
    private let tableViewRefreshControl = UIRefreshControl()
    // MARK: -Rx Variables
    var disposeBag = DisposeBag()
    var velibs: BehaviorRelay<[VelibModel]> = BehaviorRelay(value: [VelibModel]())
    var isSuccess: BehaviorRelay<(Bool,String)> = BehaviorRelay(value: (false,""))
    var filtredStands: BehaviorRelay<[VelibModel]> = BehaviorRelay(value: [VelibModel]())
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
        addObserverOnVelibs()
        getVelibs()
        bindVelibs()
        didSelectAtVelibRow() 
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
        // Do not set datasource to prevent xcode from crashing
    }
    /// Refresh List of Velib
    @objc private func refreshList() {
        getVelibs()
    }
    /// get all velibs from datasource
    func getVelibs() {
        self.noDataLabel.isHidden = true
        self.activityIndicator.startAnimating()
        velibClient.getVelibs(velibs: velibs, isSuccess: isSuccess)
    }
    /// add observer on Velib lists : filtred and not filtred
    func addObserverOnVelibs() {
        self.filtredStands.asObservable().subscribe(onNext: { (velibsReturned) in
            self.velibTableView.reloadData()
            self.tableViewRefreshControl.endRefreshing()
            // show noDataLabel depending on filtredStands count
            if self.filtredStands.value.isEmpty {
                self.noDataLabel.isHidden = false
            } else {
                self.noDataLabel.isHidden = true
            }
            self.activityIndicator.stopAnimating()
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
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let mapController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                    mapController.selectedVelib = velib
                    mapController.isFromVelibList = true
                    self.navigationController?.pushViewController(mapController, animated: true)
                }
            }).disposed(by: disposeBag)
    }
    // MARK: -TableViewDelegate
    /// set the height for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    // MARK: -Actions
    /// set filterState
    @IBAction func segmentedControlPressed(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            filterState = .all
        case 1:
            filterState = .open
        case 2:
            filterState = .closed
        default:
            break
        }
        filtredStands.accept(filterStands())
    }
    /// Filter velib list depending on filterState and searchText
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
    /// Filter velib List by name
    func filterStandsByName(velibs: [VelibModel], text: String) -> [VelibModel] {
        let list: [VelibModel] = velibs.filter { (velib) in
            velib.name?.lowercased().contains(text.lowercased()) == true
        }
        return list
    }
    func searchByName(searchText: String) -> [VelibModel] {
        var list: [VelibModel] = []
        // search by name only after 3 charars
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
    /// searchBar text editing
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtredStands.accept(searchByName(searchText: searchText))
    }
    /// Cancel button pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchedText = ""
        searchBar.text = ""
        filtredStands.accept(filterStands())
        searchBar.resignFirstResponder()
    }
    /// resign keyboard when end editing
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
