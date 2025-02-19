import 'package:flutter/material.dart';
import 'package:weather_forecast/screens/city_screen.dart';
import 'package:weather_forecast/services/weather.dart';
import 'package:weather_forecast/utilities/constants.dart';

class LocationScreen extends StatefulWidget {
  final locationWeather;
  LocationScreen({this.locationWeather});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  WeatherModel weatherModel = WeatherModel();

  late int temperature;
  late String weatherIcon;
  late String weatherMessage;
  late String cityName;

  @override
  void initState() {
    super.initState();
    updateUI(widget.locationWeather);
  }

  updateUI(dynamic weatherData) {
    setState(() {
      if (weatherData == null) {
        temperature = 0;
        weatherMessage = 'unable to get weather Data';
        weatherIcon = 'Error';
        cityName = '';
        return;
      }
      double temp = weatherData['main']['temp'];
      temperature = temp.toInt();
      weatherMessage = weatherModel.getMessage(temperature);

      int condition = weatherData['weather'][0]['id'];
      weatherIcon = weatherModel.getWeatherIcon(condition);

      cityName = weatherData['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    int dayOrNight = 1;
    if (DateTime.now().hour > 18 || DateTime.now().hour < 5) {
      dayOrNight = 2;
    } else {
      dayOrNight = 1;
    }

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            backgroundColor: Color(0x8B000000),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.location_on,
                size: 35.0,
              ),
              onPressed: () async {
                var weatherData = await WeatherModel().getLocationWeather();
                updateUI(weatherData);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.location_city_outlined,
                  size: 35.0,
                ),
                onPressed: () async {
                  var typedCityName = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CityScreen(),
                    ),
                  );
                  if (typedCityName != null) {
                    var weatherData =
                        await weatherModel.getCityWeather(typedCityName);
                    updateUI(weatherData);
                  }
                },
              ),
            ],
            title: Center(
              child: Text(
                'هواشناسی مازندران',
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background$dayOrNight.jpg'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.8), BlendMode.dstATop),
            ),
          ),
          constraints: BoxConstraints.expand(),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '$temperature°',
                        style: kTempTextStyle,
                      ),
                      Text(
                        weatherIcon,
                        style: kConditionTextStyle,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: Text(
                    "$weatherMessage in $cityName!",
                    textAlign: TextAlign.right,
                    style: kMessageTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
