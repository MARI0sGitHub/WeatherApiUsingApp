

import Foundation

/*
 Codable 프로토콜은 현재 타입을 외부 타입(json등)으로 바꾸거나 반대의 경우를 할 수 있다.
 WeatherInformation -> json
 json -> WeatherInformation
 가능
 */

struct WeatherInformation: Codable {
  let weather: [Weather]
  let temp: Temp
  let name: String

  enum CodingKeys: String, CodingKey {
    case weather
    case temp = "main"
    case name
  }
}

/*
 json의 키이름과 구조체 안의 프로퍼티 이름이 같아야 하며
 json의 키가 가르키는 밸류 타입을
 또한 따라야 한다
 */

struct Weather: Codable { //weater
  let id: Int
  let main: String
  let description: String
  let icon: String
}

/*
 json의 키이름과 구조체 안의 프로퍼티 이름이 다를 떄는
 타입 내부에 CodingKeys 라는 열거형을 만들어야함
 
 case A(우리가 만든 이름) = "B(실제 json키의 이름)"
 */

struct Temp: Codable { //main
  let temp: Double
  let feelsLike: Double
  let minTemp: Double
  let maxTemp: Double

  enum CodingKeys: String, CodingKey {
    case temp
    case feelsLike = "feels_like"
    case minTemp = "temp_min"
    case maxTemp = "temp_max"
  }
}
