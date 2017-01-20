
import UIKit
//import Parse
//import Bolts
//import ParseUI
import AVOSCloud
import LeanCloud

class ExploreCollectionViewController: UICollectionViewController,UIViewControllerPreviewingDelegate {

    //@IBOutlet weak var collectionView: UICollectionView!

    var imageFiles = [AVFile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSFontAttributeName : UIFont(name: "Coves-Bold", size: 30)! // Note the !
        ]
        
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        //for auto resizing collection view cells
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(){
        let query = LCQuery(className: "Posts")
        query.whereKey("createdAt", .descending)
        query.find{(result) in
            if (result.isSuccess) {
                if let posts = result.objects {
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
            
        }
    }
    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, object: PFObject?) -> PFCollectionViewCell {
//        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "exploreCollectionViewCell", for: indexPath) as! ExploreCollectionViewCell
//        
//        
//        //   cell.imageToShow.image = (self.images[(indexPath as NSIndexPath).row] )
//        
//        //    cell.contentView.frame = cell.bounds
//        
////        cell.imageToShow.image = UIImage(named: "gray.png")
//        let imageFile = self.imageFiles
//        cell.imageToShow.file = image
//        cell.imageToShow.loadInBackground()
//        
//        return cell
//    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCell(withReuseIdentifier: "exploreCollectionViewCell", for: indexPath) as! ExploreCollectionViewCell
        let imageFile = self.imageFiles[indexPath.row]
        imageFile.getDataInBackground({ (data, error) in
            cell.imageToShow.image = UIImage(data: data!)
        }) { (progress) in
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
