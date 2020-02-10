
import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager : WeatherManager,weather : WeatherModel)
    func FailedWithError(error: Error)
}
 
struct WeatherManager {
    // ?q={cityname}
    let weatherurl = "https://api.openweathermap.org/data/2.5/weather?q="
    
    var delegate : WeatherManagerDelegate?
    
    func fetchData(_ cityName : String) {
        let urlString = "\(weatherurl)\(cityName)&units=metric&appid=d65a47de840f391c155bfa501c6c6144"
        print(urlString)
        performReq(urlString)
    }
    
        
// There are 4 steps to parse the data :
//  1. Creating a url -> 2.Creating a URL Session task -> 3.Give Session a Task -> 4. Resume the task.
    
    func performReq(_ urlString:String){
        // 1 . Create a url
        if let url = URL(string: urlString){
            
        // 2. Create a URL Session
            let session = URLSession(configuration: .default)
            
        // 3.Give session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.FailedWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if  let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self,weather: weather)
                    }
                }
            }
        // 4. Start a task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData : Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(Weatherdata.self, from: weatherData)
            
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            print(weather.cityName)
            print(weather.temperatureString)
            print(weather.ConditionName)
            return weather
        } catch {
            self.delegate?.FailedWithError(error: error)
            return nil
        }
    }
    
}
