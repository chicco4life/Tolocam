
import UIKit
//import Parse
//import Bolts
//import ParseUI
import AVOSCloud

class ExploreCollectionViewController: UICollectionViewController,UIViewControllerPreviewingDelegate {

    //@IBOutlet weak var collectionView: UICollectionView!

    var imageFiles = [AVFile]()
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "Coves-Bold", size: 30)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        //pull to refresh
        self.collectionView?.addSubview(refreshControl)
        self.refreshControl.addTarget(self, action: #selector(ExploreCollectionViewController.__refreshPulled), for: UIControlEvents.valueChanged)
        self.refreshControl.isUserInteractionEnabled = true
        self.collectionView?.alwaysBounceVertical = true
        
        //for auto resizing collection view cells
        let screenWidth = UIScreen.main.bounds.size.width
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: (screenWidth-2) / 3, height: (screenWidth-2) / 3)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        self.collectionView!.collectionViewLayout = layout
        
        
//        _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), collectionViewLayout: layout)
        
        print("collectionviewdidload is called")
        if (traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self, sourceView: view)
        }
        
        __loadData()
    }
    
    func __refreshPulled() {
        self.__loadData()
        self.collectionView?.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = collectionView?.indexPathForItem(at: location) else {return nil}
        guard let cell = collectionView?.cellForItem(at: indexPath) else {return nil}
        //        guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier("PostDetailVC") as? PostDetailViewController else {return nil}
        return self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("hey there")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func __loadData(){
        self.imageFiles = []
        let query = AVQuery(className: "Posts")
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackground({ (results, error) in
            if error==nil {
                if let posts = results as? [AVObject] {
                    for post in posts {
                        if  post["Image"] == nil{
                            print("    CHECK THIS LOL NIL )")
                        }else{
                            print("    CHECK THIS LOL \(post["Image"])")
                            let imageToLoad = post["Image"]! as! AVFile
                            self.imageFiles.append(imageToLoad)
                        }
                    }
                    self.collectionView?.reloadData()
                }
            } else {
                //Error
            }
            
        })
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageFiles.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "exploreCollectionViewCell", for: indexPath) as! ExploreCollectionViewCell
        let imageFile = self.imageFiles[indexPath.row]
        imageFile.getDataInBackground({ (data:Data?, error:Error?) in
            if error == nil{
                cell.imageToShow.image = UIImage(data: data!)!
            }else{
                print(error!)
            }
        }) { (progress) in
            //progress
        }
        return cell
    }
    
    /*override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.size.width-4) / 3, height: (UIScreen.main.bounds.size.width-4) / 3)
    }*/
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
