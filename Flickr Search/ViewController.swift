//
//  ViewController.swift
//  Flickr Search
//
//  Created by Sakshi Jaiswal on 10/07/20.
//  Copyright © 2020 Sakshi Jaiswal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var searches = FlickrSearchResults()
    let flickr = Flickr()
    var paging : Paging?
    var loadMore: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatorView.isHidden = false
        self.setupCollectionView()
        self.callSearchApi(searchText: nil, pageNo: 1)
    }
    
    func photoForIndexPath(indexPath: IndexPath) -> FlickrPhoto {
        return searches.searchResults[(indexPath as NSIndexPath).row]
    }
}

// MARK: - UICollectionViewDelegate and UICollectionViewDataSource
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func setupCollectionView() {
        self.photoCollectionView.register(UINib(nibName: PhotoCollectionViewCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionViewCell.cellIdentifier)
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches.searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastRowIndex = collectionView.numberOfItems(inSection: 0) - 1
        if indexPath.row == lastRowIndex && paging != nil {
            loadMorePhotos()
        }
        let flickrPhoto = photoForIndexPath(indexPath: indexPath)
        (cell as! PhotoCollectionViewCell).imgView_photo.image = #imageLiteral(resourceName: "placeholder")
        ImageDownloadManager.shared.downloadImage(flickrPhoto, indexPath: indexPath) { (image, url, indexPathh, error) in
            if let indexPathNew = indexPathh {
                DispatchQueue.main.async {
                    if let getCell = collectionView.cellForItem(at: indexPathNew) {
                        (getCell as? PhotoCollectionViewCell)!.imgView_photo.image = image
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /* Reduce the priority of the network operation in case the user scrolls and an image is no longer visible. */
        if self.loadMore {return}
        let flickrPhoto = photoForIndexPath(indexPath: indexPath)
        ImageDownloadManager.shared.slowDownImageDownloadTaskfor(flickrPhoto)
    }
    
    // MARK: - Helper Method
    private func loadMorePhotos() {
        guard let searchText = self.searchBar.text, searchText.count > 0 else {
            if !loadMore && paging!.currentPage! < paging!.totalPages! {
                loadMore = true
            }
            return self.callSearchApi(searchText: nil, pageNo: paging!.currentPage! + 1)
        }
        if !loadMore && paging!.currentPage! < paging!.totalPages! {
            loadMore = true
            self.callSearchApi(searchText: searchText, pageNo: paging!.currentPage! + 1)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 8
        let size = UIScreen.main.bounds.width/2 - 3*padding/2
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}

//MARK: - SearchBar Delegate
extension ViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
           searchBar.showsCancelButton = true
       }

       func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
           let isEmpty = searchBar.text?.isEmpty ?? true
           searchBar.showsCancelButton = !isEmpty
           return true
       }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        self.loadMore = true
        guard let searchText = searchBar.text, searchText.count > 0 else {
            ImageDownloadManager.shared.cancelAll()
            self.searches.searchResults.removeAll()
            self.photoCollectionView?.reloadData()
            self.loadMore = false
            return
        }
        self.callSearchApi(searchText: searchText, pageNo: 1)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        ImageDownloadManager.shared.cancelAll()
        self.searches.searchResults.removeAll()
        self.loadMore = false
        self.callSearchApi(searchText: nil, pageNo: 1)
    }
}

//MARK: - API Handler
extension ViewController {
    func callSearchApi (searchText: String?, pageNo: Int) {
        flickr.searchFlickrForTerm(searchText, page: pageNo) { results, paging, error in
            if let paging = paging, paging.currentPage == 1 {
                ImageDownloadManager.shared.cancelAll()
                self.searches.searchResults.removeAll()
                self.photoCollectionView?.reloadData()
            }
            if let error = error {
                print("Error searching: \(error)")
                return
            }
            if let results = results {
                print("Found \(results.searchResults.count) matching \(results.searchTerm)")
                self.searches.searchResults.append(contentsOf: results.searchResults)
                for photo in self.searches.searchResults {
                    print("URL:  \(photo.flickrImageURL()?.absoluteString ?? "")")
                }
                self.paging = paging
                self.activityIndicatorView.isHidden = true
                self.photoCollectionView?.reloadData()
            }
            self.loadMore = false
        }
    }
}
