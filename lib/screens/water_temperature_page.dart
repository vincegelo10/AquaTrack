import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week7_networking_discussion/providers/sensor_data_provider.dart';
import 'package:week7_networking_discussion/providers/auth_provider.dart';
import 'package:week7_networking_discussion/providers/user_provider.dart';
import 'package:week7_networking_discussion/models/sensor_data_model.dart';
import 'package:week7_networking_discussion/models/user_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:week7_networking_discussion/providers/water_parameter_annotation_provider.dart';
import 'package:week7_networking_discussion/screen_arguments/data_sensor_arguments.dart';
import 'package:week7_networking_discussion/services/local_notification_service.dart';

class WaterTemperaturePage extends StatefulWidget {
  const WaterTemperaturePage({super.key});

  @override
  State<WaterTemperaturePage> createState() => _WaterTemperaturePageState();
}

class _WaterTemperaturePageState extends State<WaterTemperaturePage> {
  TextEditingController dateController = TextEditingController();
  late final NotificationService service;
  @override
  void initState() {
    service = NotificationService();
    service.initializePlatformNotifications();
    super.initState();
  }

  void checkAndShowNotification() {
    User? user = context.watch<UserProvider>().user;
    if (user == null) {
      return;
    }
    DateTime currentDate = DateTime.now();
    DateTime now = DateTime.now();
    int timestampInSeconds = now.millisecondsSinceEpoch ~/ 1000;
    var updatedData = context.watch<SensorDataProvider>().updatedSensorData;
    String phVal = context.watch<SensorDataProvider>().phLevel == ''
        ? 'NA'
        : context.watch<SensorDataProvider>().phLevel;
    String doVal = context.watch<SensorDataProvider>().dissolvedOxygen == ''
        ? 'NA'
        : context.watch<SensorDataProvider>().dissolvedOxygen;
    String tempVal = context.watch<SensorDataProvider>().waterTemp == ''
        ? 'NA'
        : user.inFahrenheit == false
            ? context.watch<SensorDataProvider>().recentWaterTemp
            : ((double.parse(context
                            .watch<SensorDataProvider>()
                            .recentWaterTemp) *
                        9 /
                        5) +
                    32)
                .toString();
    double lowerTemp = user.inFahrenheit == false
        ? user.lowerTemp
        : ((user.lowerTemp * 9 / 5) + 32);

    double upperTemp = user.inFahrenheit == false
        ? user.upperTemp
        : ((user.upperTemp * 9 / 5) + 32);

    if (updatedData?.timestamp != null) {
      //notification for PH outside of threshold
      if (phVal != 'NA' &&
          (double.parse(phVal) < user.lowerPH ||
              double.parse(phVal) > user.upperPH) &&
          timestampInSeconds - updatedData!.timestamp <= 5) {
        service.showNotification(
          id: 1,
          title: 'PH Level out of range!',
          body:
              'Current PH Level: $phVal is not within the set threshold of ${user.lowerPH}-${user.upperPH}',
        );
      }
      //notification for temperature outside of threshold
      if (tempVal != 'NA' &&
          (double.parse(tempVal) < lowerTemp ||
              double.parse(tempVal) > upperTemp) &&
          timestampInSeconds - updatedData!.timestamp <= 5) {
        service.showNotification(
          id: 2,
          title: 'Water Temperature out of range!',
          body:
              'Current Water Temperature: $tempVal is not within the set threshold of $lowerTemp-$upperTemp',
        );
      }

      //notification for DO outside of threshold
      if (doVal != 'NA' &&
          (double.parse(doVal) < user.lowerDO ||
              double.parse(doVal) > user.upperDO) &&
          timestampInSeconds - updatedData!.timestamp <= 5) {
        service.showNotification(
          id: 3,
          title: 'Dissolved Oxygen out of range!',
          body:
              'Current Dissolved Oxygen: $doVal is not within the set threshold of ${user.lowerDO}-${user.upperDO}',
        );
      }
    }
  }

  Widget _graphBuilder(List<SensorData> dataList, BuildContext context,
      String lowerTemp, String upperTemp) {
    User? user = context.watch<UserProvider>().user;
    double lTemp = double.parse(lowerTemp);
    double uTemp = double.parse(upperTemp);

    if (user!.inFahrenheit) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          child: SfCartesianChart(
            backgroundColor: Colors.white,
            primaryXAxis: DateTimeAxis(
              title: AxisTitle(
                  text: "Water temperature over time",
                  textStyle: const TextStyle(
                      color: Colors.deepOrange,
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300)),
              majorGridLines: const MajorGridLines(width: 0),
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              intervalType: DateTimeIntervalType.hours,
              dateFormat: DateFormat('hh:mm a'), // Use custom time format here
            ),
            zoomPanBehavior: ZoomPanBehavior(
              enablePanning: true, // Enable panning
              enablePinching: true, // Enable zooming
              zoomMode: ZoomMode.x, // Zoom in the X-axis direction only
            ),
            series: [
              LineSeries<SensorData, DateTime>(
                  dataSource: dataList,
                  xValueMapper: (SensorData data, _) => data.timeUpload,
                  yValueMapper: (SensorData data, _) =>
                      data.waterTempInFahrenheit,
                  markerSettings: const MarkerSettings(isVisible: true),
                  pointColorMapper: (SensorData data, _) {
                    if (data.waterTempInFahrenheit < lTemp ||
                        data.waterTempInFahrenheit > uTemp) {
                      return Colors.red;
                    } else if (data.waterTempInFahrenheit == lTemp ||
                        data.waterTempInFahrenheit == uTemp) {
                      return Colors.orange;
                    } else {
                      return Colors.green;
                    }
                  }),
            ],
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          child: SfCartesianChart(
            backgroundColor: Colors.white,
            primaryXAxis: DateTimeAxis(
              title: AxisTitle(
                  text: "Water temperature over time",
                  textStyle: const TextStyle(
                      color: Colors.deepOrange,
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300)),
              majorGridLines: const MajorGridLines(width: 0),
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              intervalType: DateTimeIntervalType.hours,
              dateFormat: DateFormat('hh:mm a'), // Use custom time format here
            ),
            zoomPanBehavior: ZoomPanBehavior(
              enablePanning: true, // Enable panning
              enablePinching: true, // Enable zooming
              zoomMode: ZoomMode.x, // Zoom in the X-axis direction only
            ),
            series: [
              LineSeries<SensorData, DateTime>(
                  dataSource: dataList,
                  xValueMapper: (SensorData data, _) => data.timeUpload,
                  yValueMapper: (SensorData data, _) => data.waterTemperature,
                  markerSettings: const MarkerSettings(isVisible: true),
                  pointColorMapper: (SensorData data, _) {
                    if (data.waterTemperature < lTemp ||
                        data.waterTemperature > uTemp) {
                      return Colors.red;
                    } else if (data.waterTemperature == lTemp ||
                        data.waterTemperature == uTemp) {
                      return Colors.orange;
                    } else {
                      return Colors.green;
                    }
                  }),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    String formattedDateToday = currentDate.toString().split(' ')[0];

    User? user = context.watch<UserProvider>().user;
    checkAndShowNotification();

    _onItemTapped(int index) {
      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/');
          break;
        case 1:
          Navigator.pushNamed(context, '/editPage');
          break;
      }
    }

    if (user != null) {
      String labelData = dateController.text != formattedDateToday &&
              dateController.text.isNotEmpty
          ? "Water temperature trends on ${dateController.text}"
          : "Water temperature trends today";

      String lowerTemp = user.inFahrenheit == false
          ? user.lowerTemp.toString()
          : ((user.lowerTemp * 9 / 5) + 32).toString();

      String upperTemp = user.inFahrenheit == false
          ? user.upperTemp.toString()
          : ((user.upperTemp * 9 / 5) + 32).toString();

      List<SensorData> dataList = (dateController.text != formattedDateToday &&
              dateController.text.isNotEmpty
          ? context.watch<SensorDataProvider>().dataFromOtherDate
          : context.watch<SensorDataProvider>().dataFromSensor);
      var waterTempVal = context.watch<SensorDataProvider>().waterTemp == ''
          ? 'NA'
          : user.inFahrenheit == false
              ? context.watch<SensorDataProvider>().waterTemp
              : ((double.parse(context.watch<SensorDataProvider>().waterTemp) *
                          9 /
                          5) +
                      32)
                  .toStringAsFixed(2);

      List<String> tempUnits = ["°C", "°F"];
      var unitForRealTimeTemp =
          (user.inFahrenheit == true && waterTempVal != 'NA')
              ? tempUnits[1]
              : (waterTempVal != 'NA')
                  ? tempUnits[0]
                  : "";
      var unitForThreshold =
          user.inFahrenheit == true ? tempUnits[1] : tempUnits[0];

      void showNoDataDialog(BuildContext context) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No Data Available'),
              content: const Text('Sorry, no data is available.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      void showWaterTempThresholdDialog(BuildContext context) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Water Temperature Threshold'),
              content: Text(
                  'The water temperature threshold is between $lowerTemp-$upperTemp $unitForThreshold. Do you want to edit it?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // Background color
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("No")),
                        const SizedBox(width: 10),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Background color
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, "/editTempPage");
                            },
                            child: const Text("Yes")),
                      ]),
                ),
              ],
            );
          },
        );
      }

      Widget recentTimeUpload(BuildContext context) {
        List<SensorData> data =
            context.watch<SensorDataProvider>().dataFromSensor;

        if (data.isEmpty) {
          return const Text("Data not available",
              style: TextStyle(
                  fontWeight: FontWeight.bold, // Make the text bold
                  color: Colors.white, // Set the text color to white
                  fontSize: 10));
        } else {
          DateTime lastUpload = data[data.length - 1].timeUpload;
          String formattedTime =
              DateFormat('hh:mm a').format(lastUpload).toString();
          return Text("last uploaded by Arduino at $formattedTime",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, // Make the text bold
                  color: Colors.white, // Set the text color to white
                  fontSize: 10));
        }
      }

      Widget waterTemperatureWidgetBuilder() {
        Color colorOfWidget;
        try {
          if (double.parse(waterTempVal) > double.parse(lowerTemp) &&
              double.parse(waterTempVal) < double.parse(upperTemp)) {
            colorOfWidget = Colors.green;
          } else if (double.parse(waterTempVal) == double.parse(lowerTemp) ||
              double.parse(waterTempVal) == double.parse(upperTemp)) {
            colorOfWidget = Colors.orange;
          } else {
            colorOfWidget = Colors.red;
          }
        } catch (e) {
          colorOfWidget = Colors.black;
          print(e);
        }

        return Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
              height: 140, // Set the desired height of the square
              decoration: BoxDecoration(
                color: colorOfWidget, // Set the desired color of the square
                borderRadius: BorderRadius.circular(
                    20), // Adjust the radius to control the roundness
              ),
              child: Column(children: [
                const Text(
                  "Water Temperature",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make the text bold
                    color: Colors.white, // Set the text color to white
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "$waterTempVal $unitForRealTimeTemp",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, // Make the text bold
                      color: Colors.white, // Set the text color to white
                      fontSize: 40),
                ),
                Expanded(
                    child: Align(
                  alignment: Alignment.bottomCenter,
                  child: recentTimeUpload(context),
                )),
                const SizedBox(height: 8),
              ])),
        );
      }

      void showWaterTempAnnotationDialog(BuildContext context) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Water Temperature'),
              content: const Text(
                  'Do you want to view and annotate the water temperature data?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // Background color
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("No")),
                        const SizedBox(width: 10),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Background color
                            ),
                            onPressed: () {
                              String dateArgument = dateController.text.isEmpty
                                  ? formattedDateToday
                                  : dateController.text;
                              context
                                  .read<WaterParameterAnnotationProvider>()
                                  .fetchAnnotation(dateArgument,
                                      "water_temperature", user.email);
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                  context, '/WaterTemperatureAnnotationPage',
                                  arguments: DataSensorArguments(
                                      dataList, dateArgument));
                            },
                            child: const Text("Yes")),
                      ]),
                ),
              ],
            );
          },
        );
      }

      void showWaterTempDialog(BuildContext context) {
        String status;
        try {
          if (double.parse(waterTempVal) > double.parse(lowerTemp) &&
              double.parse(waterTempVal) < double.parse(upperTemp)) {
            status = "which is within the defined water temperature theshold";
          } else if (double.parse(waterTempVal) == double.parse(lowerTemp) ||
              double.parse(waterTempVal) == double.parse(upperTemp)) {
            if (double.parse(waterTempVal) == double.parse(lowerTemp)) {
              status =
                  "which is equal to the defined lower water temperature threshold";
            } else {
              status =
                  "which is equal to the defined upper water temperature threshold";
            }
          } else {
            status = "which is outside the defined water temperature theshold";
          }
        } catch (e) {
          status = "which means that no data is being uploaded by the Arduino";
          print(e);
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Water Temperature'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.8, // Adjust the width as needed
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      'The current water temperature is $waterTempVal $unitForRealTimeTemp, $status. The color of this widget changes according to the ff:',
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Within the threshold:"),
                        const SizedBox(width: 5),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: Colors.green),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Equal to one of the threshold: "),
                        const SizedBox(width: 5),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: Colors.orange),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Outside the threshold: "),
                        const SizedBox(width: 5),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: Colors.red),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Data not available: "),
                        const SizedBox(width: 5),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text("OK")),
              ],
            );
          },
        );
      }

      return Scaffold(
        drawer: Drawer(
            child: ListView(padding: EdgeInsets.zero, children: [
          const SizedBox(height: 100),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              context.read<AuthProvider>().signOut();
              context.read<UserProvider>().removeLoggedInUserDetails();
              Navigator.pushNamed(context, "/");
            },
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, "/");
            },
          ),
          ListTile(
            title: const Text('Edit'),
            onTap: () {
              Navigator.pushNamed(context, "/editPage");
            },
          ),
        ])),
        appBar: AppBar(
          title: const Text(
            "Water Temperature Page",
            style: TextStyle(
              color: Colors.white, // Set the text color here
            ),
          ),
        ),
        body: Container(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              showWaterTempDialog(context);
                            },
                            child: waterTemperatureWidgetBuilder())),
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        showWaterTempThresholdDialog(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Container(
                          height: 140, // Set the desired height of the square
                          decoration: BoxDecoration(
                            color: Colors
                                .yellow, // Set the desired color of the square
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius to control the roundness
                          ),
                          child: Column(children: [
                            const Text(
                              "Temperature Threshold",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold, // Make the text bold
                                color:
                                    Colors.white, // Set the text color to white
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              '''$lowerTemp - $upperTemp $unitForThreshold''',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold, // Make the text bold
                                  color: Colors
                                      .white, // Set the text color to white
                                  fontSize: 35),
                            ),
                          ]),
                        ),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .cyan, // Set the desired color of the square
                            borderRadius: BorderRadius.circular(
                                20), // Adjust the radius to control the roundness
                          ),
                          child: Column(children: [
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                labelData,
                                style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold, // Make the text bold
                                    color: Colors
                                        .white, // Set the text color to white
                                    fontSize: 20),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                                child: _graphBuilder(
                                    dataList, context, lowerTemp, upperTemp)),
                            const SizedBox(height: 10),
                          ])),
                    ),
                    onTap: () {
                      showWaterTempAnnotationDialog(context);
                    }),
                TextField(
                    controller:
                        dateController, //editing controller of this TextField
                    decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today), //icon of text field
                        labelText:
                            "Enter a date from which to see water temperature trends" //label text of field

                        ),
                    readOnly: true, // when true user cannot edit text

                    onTap: () async {
                      //when click we have to show the datepicker

                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(), //get today's date
                        firstDate:
                            DateTime(2000), // Set your desired start date
                        lastDate: DateTime.now(),
                      ); // Disable future dates);

                      if (pickedDate != null) {
                        String formattedDate = DateFormat('yyyy-MM-dd').format(
                            pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed

                        setState(() {
                          dateController.text =
                              formattedDate; //set foratted date to TextField value.
                        });
                        bool success = await context
                            .read<SensorDataProvider>()
                            .fetchDataFromOtherDate(formattedDate);

                        if (!success) {
                          showNoDataDialog(context);
                        }
                      } else {
                        print("Date is not selected");
                      }
                    })
              ],
            )),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.cyan,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Edit',
            ),
          ],
          currentIndex: 0,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          selectedLabelStyle:
              const TextStyle(overflow: TextOverflow.visible, fontSize: 10),
          unselectedLabelStyle:
              const TextStyle(overflow: TextOverflow.visible, fontSize: 10),
          onTap: _onItemTapped,
        ),
      );
    } else {
      return Scaffold(
        drawer: Drawer(
            child: ListView(
          padding: EdgeInsets.zero,
          children: const [CircularProgressIndicator()],
        )),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.cyan,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Edit',
            ),
          ],
          currentIndex: 0,
          unselectedItemColor: Colors.white,
          selectedItemColor: Colors.white,
          selectedLabelStyle:
              const TextStyle(overflow: TextOverflow.visible, fontSize: 10),
          unselectedLabelStyle:
              const TextStyle(overflow: TextOverflow.visible, fontSize: 10),
          onTap: _onItemTapped,
        ),
      );
    }
  }
}
