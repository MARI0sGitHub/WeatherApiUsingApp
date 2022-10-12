
import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var cityNameTextField: UITextField!
  @IBOutlet weak var cityNameLabel: UILabel!
  @IBOutlet weak var weatherDescriptionLabel: UILabel!
  @IBOutlet weak var tempLabel: UILabel!
  @IBOutlet weak var minTempLabel: UILabel!
  @IBOutlet weak var maxTempLabel: UILabel!
  @IBOutlet weak var weatherStackView: UIStackView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  @IBAction func tapFetchWeatherButton(_ sender: UIButton) {
    if let cityName = self.cityNameTextField.text {
      self.getCurrentWeather(cityName: cityName)
    //버튼이 눌리면 키보드 사라짐
      self.view.endEditing(true)
    }
  }

  func configureView(weatherInformation: WeatherInformation) {
    self.cityNameLabel.text = weatherInformation.name
    //weather 배열의 첫번째 요소 할당
    if let weather = weatherInformation.weather.first {
    //현재 날씨 정보 표시
      self.weatherDescriptionLabel.text = weather.description
    }
    self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))℃"
    self.minTempLabel.text = "최저: \(Int(weatherInformation.temp.minTemp - 273.15))℃"
    self.maxTempLabel.text = "최고: \(Int(weatherInformation.temp.maxTemp - 273.15))℃"
  }

  func showAlert(message: String) {
    //화면에 메시지 띄우기 알림 창
    let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
    //alert 화면 표시
    self.present(alert, animated: true, completion: nil)
  }

  func getCurrentWeather(cityName: String) {
    //호출할 api주소
    let api = Bundle.main.apiKey
    guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(api)") else { return }
    let session = URLSession(configuration: .default)
    //dataTask가 api호출 서버에서 응답이 오면 Completion Handler 클로져가 호출됨
    //data에는 서버에서 응답받은 데이터가 전달됨, response는 http헤더 및 http 상태코드, error 요청 실패시 에러객체 전달 요청 성공시nil
    //json데이터는 data파라미터에 전달됨
    //[weak self] 순환 참조 해결
    session.dataTask(with: url) { [weak self] data, response, error in
        //http 상태코드가 200번대 성공인지, 실패인지
      let successRange = (200..<300)
      guard let data = data, error == nil else { return }
      //JSONDecoder는 json에서 Codable 프로토콜을 준수한 사용자 정의 타입으로 변환 시켜줌
      let decoder = JSONDecoder()
      if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
        //1번 파라미터: json을 변환할 Codable을 준수한 사용자 타입
        //from 파라미터: 서버에서 응답받은 json데이터를 넣는다
        //디코딩 실패시 에러를 던지기 때문에 에러처리 try?
        guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return }
        /*
         네트워크 작업은 별도의 스레드에서 진행 되고
         응답이 온다해도 자동으로 메인 스레드로 오지않기 때문에
         Completion Handler 클로저에서 UI작업을 한다면 메인스레드에서 작업을 할수 있도록 만들어 줘야함
         */
        DispatchQueue.main.async {
          self?.weatherStackView.isHidden = false
          self?.configureView(weatherInformation: weatherInformation)
        }
      } else { //http 상태코드가 실패인 경우
        //에러 json 데이터를 ErrorMessage객체로 디코딩함
        guard let errorMesaage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
        //UI작업을 위해 메인 스레드
        DispatchQueue.main.async {
          self?.showAlert(message: errorMesaage.message)
        }
      }

    }.resume()
  }
}

