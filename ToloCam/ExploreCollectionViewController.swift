
import UIKit
import Parse
import Bolts
import ParseUI

class ExploreCollectionViewController: PFQueryCollectionViewController,UIViewControllerPreviewingDelegate {
    
   // @IBOutlet weak var collectionView: UICollectionView!

    
    var images = [UIImage]()
    
    init!(style: UICollectionViewFlowLayout, className: String!) {
        super.init(collectionViewLayout: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        // Configure the PFQueryCollectionView
        self.parseClassName = "Posts"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
        self.objectsPerPage = 15
    }
    
    override func queryForCollection() -> PFQuery<PFObject> {
        let query = PFQuery(className: "Posts")
        query.order(byDescending:("createdAt"))
        
        return query
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "Coves-Bold", size: 30)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        //for auto resizing collection view cells
      //  let screenWidth = UIScreen.main.bounds.size.width
//        let screenHeight = UIScreen.main.bounds.size.height
        
        
     /*   let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.itemSize = CGSize(width: (screenWidth - 4)/3, height: (screenWidth - 4)/3)*/
        
//        _ = UICollectionView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), collectionViewLayout: layout)
        
        print("collectionviewdidload is called")
        if (traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self, sourceView: view)
        }
        
       // loadData()
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
    
    /*func loadData(){
        
        print("load data is called")
        
        let query = PFQuery(className: "Posts")
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground{(posts:[PFObject]?, error: Error?) -> Void in
            
            if (error == nil) {
                if let posts = posts as [PFObject]! {
                    for post in posts {
                        
                        
                        if  post["Image"] == nil{
                            print("    CHECK THIS LOL NIL )")
                        }else{
                            print("    CHECK THIS LOL \(post["Image"])")
                            
                            let imageToLoad = post["Image"]! as! PFFile
                            var imageIWillUse = UIImage()
                            
                            do {
                                try imageIWillUse = UIImage(data:imageToLoad.getData())!
                                
                            } catch {
                                
                                print(error)
                            }
                            
                            
                            
                            self.images.append(imageIWillUse)
                        }
                    }
                    
                    self.collectionView?.reloadData()
                    
                    
                }
            } else {
                //Error
                
            }
            
        }
        
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.images.count > 0{
            return self.images.count
        }else{
            return 0
        }
    }
    
    /*override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> PFCollectionViewCell {
        
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ExploreCollectionViewCell
        
        
     //   cell.imageToShow.image = (self.images[(indexPath as NSIndexPath).row] )
        
    //    cell.contentView.frame = cell.bounds
        
        cell.imageToShow.image = object["Image"] as? PFFile
        
        return cell
    }
    */
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, object: PFObject?) -> PFCollectionViewCell? {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ExploreCollectionViewCell
        
        
        //   cell.imageToShow.image = (self.images[(indexPath as NSIndexPath).row] )
        
        //    cell.contentView.frame = cell.bounds
        
        cell.imageToShow.image = UIImage(named: "gray.png")
        let image: PFFile = object!["Image"] as! PFFile
        cell.imageToShow.file = image
        
        return cell
    }
    
/*    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (UIScreen.main.bounds.size.width-4) / 3, height: (UIScreen.main.bounds.size.width-4) / 3)
    }
*/
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
