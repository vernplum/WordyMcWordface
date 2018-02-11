import Foundation

import SpriteKit



class Level
{
    init(filename: String)
    {
   
        
        
 //       Log("init \(self) @@@@@@@@@@@@@@@")
        
        var _filename = "Level_1"
        
        let filePath = Bundle.main.path(forResource: _filename, ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
  //      let json = JSON(data: data!)
        let words = ["ARGENTINA", "COLOMBIA", "TOOTSIE", "BEEHIVE" ];//json["words"].arrayValue
        
 
        
        for word in words
        {
            var spawnPosRow = [CGPoint]()
           
        
       }
    }



    deinit
    {
 //       Log("deinit \(self)  ********************")
    }

}
