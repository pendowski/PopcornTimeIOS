

import UIKit
import AlamofireImage

class TVShowsCollectionViewController: ItemOverview, UIPopoverPresentationControllerDelegate, GenresDelegate, ItemOverviewDelegate {
    
    var shows = [PCTShow]()
    
    var currentGenre = TVAPI.genres.All {
        didSet {
            shows.removeAll()
            collectionView?.reloadData()
            currentPage = 1
            loadNextPage(currentPage)
        }
    }
    var currentFilter = TVAPI.filters.Trending {
        didSet {
            shows.removeAll()
            collectionView?.reloadData()
            currentPage = 1
            loadNextPage(currentPage)
        }
    }
    
    @IBAction func searchBtnPressed(sender: UIBarButtonItem) {
        presentViewController(searchController, animated: true, completion: nil)
    }
    
    @IBAction func filter(sender: AnyObject) {
        self.collectionView?.performBatchUpdates({
            self.filterHeader!.hidden = !self.filterHeader!.hidden
            }, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        loadNextPage(currentPage)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let collectionView = object as? UICollectionView where collectionView == self.collectionView! && keyPath! == "frame" {
            collectionView.performBatchUpdates(nil, completion: nil)
        }
    }
    
    func segmentedControlDidChangeSegment(segmentedControl: UISegmentedControl) {
        currentFilter = TVAPI.filters.arrayValue[segmentedControl.selectedSegmentIndex]
    }
    
    // MARK: - ItemOverviewDelegate
    
    func loadNextPage(pageNumber: Int, searchTerm: String? = nil, removeCurrentData: Bool = false) {
        guard isLoading else {
            isLoading = true
            hasNextPage = false
            TVAPI.sharedInstance.load(currentPage, filterBy: currentFilter, genre: currentGenre, searchTerm: searchTerm) { result in
                self.isLoading = false
                
                guard case .success(let items) = result else {
                    return
                }
                
                if removeCurrentData {
                    self.shows.removeAll()
                }
                self.shows += items
                if items.isEmpty // If the array passed in is empty, there are no more results so the content inset of the collection view is reset.
                {
                    self.collectionView?.contentInset = UIEdgeInsetsMake(69, 0, 0, 0)
                } else {
                    self.hasNextPage = true
                }
                self.collectionView?.reloadData()
            }
            return
        }
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        self.shows.removeAll()
        collectionView?.reloadData()
        self.currentPage = 1
        loadNextPage(self.currentPage)
    }
    
    func search(text: String) {
        self.shows.removeAll()
        collectionView?.reloadData()
        self.currentPage = 1
        self.loadNextPage(self.currentPage, searchTerm: text)
    }
    
    func shouldRefreshCollectionView() -> Bool {
        return shows.isEmpty
    }
    
    // MARK: - Navigation
    
    @IBAction func genresButtonTapped(sender: UIBarButtonItem) {
        let controller = cache.objectForKey(TraktTVAPI.type.Shows.rawValue) as? UINavigationController ?? (storyboard?.instantiateViewControllerWithIdentifier("GenresNavigationController"))! as! UINavigationController
        cache.setObject(controller, forKey: TraktTVAPI.type.Shows.rawValue)
        controller.modalPresentationStyle = .Popover
        controller.popoverPresentationController?.barButtonItem = sender
        controller.popoverPresentationController?.backgroundColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1.0)
        (controller.viewControllers[0] as! GenresTableViewController).delegate = self
        presentViewController(controller, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        fixIOS9PopOverAnchor(segue)
        if segue.identifier == "showDetail" {
            let showDetail = segue.destinationViewController as! TVShowDetailViewController
            let cell = sender as! CoverCollectionViewCell
            showDetail.currentItem = shows[(collectionView?.indexPathForCell(cell)?.row)!]
        }
    }
    
    // MARK: - Collection view data source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        collectionView.backgroundView = nil
        if shows.count == 0 {
            if error != nil {
                let background = NSBundle.mainBundle().loadNibNamed("TableViewBackground", owner: self, options: nil).first as! TableViewBackground
                background.setUpView(error: error!)
                collectionView.backgroundView = background
            } else if isLoading {
                let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
                indicator.center = collectionView.center
                collectionView.backgroundView = indicator
                indicator.sizeToFit()
                indicator.startAnimating()
            } else {
                let background = NSBundle.mainBundle().loadNibNamed("TableViewBackground", owner: self, options: nil).first as! TableViewBackground
                background.setUpView(image: UIImage(named: "Search")!, title: "No results found.", description: "No search results found for \(searchController.searchBar.text!). Please check the spelling and try again.")
                collectionView.backgroundView = background
            }
        }
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CoverCollectionViewCell
        cell.titleLabel.text = shows[indexPath.row].title
        cell.yearLabel.text = String(shows[indexPath.row].year)
        cell.coverImage.af_setImageWithURL(NSURL(string: shows[indexPath.row].coverImageAsString)!, placeholderImage: UIImage(named: "Placeholder"), imageTransition: .CrossDissolve(animationLength))
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        filterHeader = filterHeader ?? {
            let reuseableView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "filter", forIndexPath: indexPath) as! FilterCollectionReusableView
            reuseableView.segmentedControl?.removeAllSegments()
            for (index, filterValue) in TVAPI.filters.arrayValue.enumerate() {
                reuseableView.segmentedControl?.insertSegmentWithTitle(filterValue.title, atIndex: index, animated: false)
            }
            reuseableView.hidden = true
            reuseableView.segmentedControl?.addTarget(self, action: #selector(segmentedControlDidChangeSegment(_:)), forControlEvents: .ValueChanged)
            reuseableView.segmentedControl?.selectedSegmentIndex = 0
            return reuseableView
            }()
        return filterHeader!
    }
    
    // MARK: - GenresDelegate
    
    func finished(genreArrayIndex: Int) {
        navigationItem.title = TVAPI.genres.arrayValue[genreArrayIndex].rawValue
        if TVAPI.genres.arrayValue[genreArrayIndex] == .All {
            navigationItem.title = "Shows"
        }
        currentGenre = TVAPI.genres.arrayValue[genreArrayIndex]
    }
    
    func populateDataSourceArray(inout array: [String]) {
        for genre in TVAPI.genres.arrayValue {
            array.append(genre.rawValue)
        }
    }
}
