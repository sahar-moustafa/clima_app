import 'package:clima/screens/city_screen.dart';
import 'package:flutter/material.dart';
import 'package:clima/utilities/constants.dart';
import 'package:clima/services/weather.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LocationScreen extends StatefulWidget {
  final locationWeather;
  const LocationScreen({super.key, this.locationWeather});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  WeatherModel weather = WeatherModel();

  int? temperature;
  String? weatherIcon;
  String? cityName;
  String? weatherMessage;

  bool isLoading = false;

  @override
  void initState() {
    updateUI(widget.locationWeather);
    super.initState();
  }

  void getLocationWeather() async {
    setState(() {
      isLoading = true;
    });
    var weatherData = await weather.getLocationWeather();
    setState(() {
      isLoading = false;
    });
    updateUI(weatherData);
  }

  void getCityWeather() async {
    var typedName = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CityScreen(),
      ),
    );
    setState(() {
      isLoading = true;
    });
    if (typedName != null) {
      var weatherData = await weather.getCityWeather(typedName);
      setState(() {
        isLoading = false;
      });
      updateUI(weatherData);
    }
  }

  void updateUI(dynamic weatherData) {
    setState(() {
      if (weatherData == null) {
        temperature = 0;
        weatherIcon = "Error";
        weatherMessage = "Unable to get weather data";
        cityName = "";
        return;
      }
      double temp = weatherData["main"]["temp"];
      temperature = temp.toInt();
      var condition = weatherData["weather"][0]["id"];
      weatherIcon = weather.getWeatherIcon(condition!);
      weatherMessage = weather.getMessage(temperature!);
      cityName = weatherData["name"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('images/blue-sky.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.8),
              BlendMode.dstATop,
            ),
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: !isLoading
            ? SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  getLocationWeather();
                                },
                                child: const Icon(
                                  Icons.near_me,
                                  size: 50.0,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  getCityWeather();
                                },
                                child: const Icon(
                                  Icons.location_city,
                                  size: 50.0,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      '$temperature°',
                                      style: kTempTextStyle,
                                    ),
                                    Text(
                                      weatherIcon!,
                                      style: kConditionTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: Text(
                                  '$weatherMessage in $cityName!',
                                  textAlign: TextAlign.right,
                                  style: kMessageTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : const Center(
                child: SpinKitDoubleBounce(
                  color: Colors.white,
                  size: 100.0,
                ),
              ),
      ),
    );
  }
}
