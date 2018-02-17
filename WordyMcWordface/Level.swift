import Foundation
import SpriteKit



struct LevelStruct : Decodable
{
    var levelConfig: LevelConfig
}

struct LevelConfig : Decodable
{
    var countdownTimer: Int
    var difficulty: Int
    var par: Int
    var levelWords: [LevelWord]
}

struct LevelWord : Decodable
{
    var word: String
    var category: Int
}



class Level
{
    var countdownTimer: Int = 30
    var difficulty: Int = 0
    var levelPar: Int = 0
    var words = [LevelWord]()
    
    init(filename: String)
    {
        if let url = Bundle.main.url(forResource: filename, withExtension: "json")
        {
            do
            {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                
                let jsonData = try decoder.decode(LevelStruct.self, from: data)
                
                self.countdownTimer = jsonData.levelConfig.countdownTimer
                self.difficulty = jsonData.levelConfig.difficulty
                self.levelPar = jsonData.levelConfig.par
                self.words = jsonData.levelConfig.levelWords
                
                for w in words
                {
                    print(w)
                }
                
            }
            catch
            {
                print("error:\(error)")
            }
        }
    }
}
