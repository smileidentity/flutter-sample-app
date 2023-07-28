import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:smile_flutter_3/smile_flutter_3.dart';
import 'dart:io' show Directory, File, Platform;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppPage(),
      builder: EasyLoading.init(),
    );
  }
}

class DropDownType {
  String name = "";
  String value = "";

  DropDownType(String name, String value) {
    this.name = name;
    this.value = value;
  }

  bool operator ==(dynamic other) =>
      other != null && other is DropDownType && this.name == other.name;

  @override
  int get hashCode => super.hashCode;
}

class AppPage extends StatefulWidget {
  // Platform messages are asynchronous, so we initialize in an async method.
  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  var currentUserId = null;
  var isProduction = false;
  var countryDropDownValue = new DropDownType('Select Country', "select");
  var idTypeDropDownValue = new DropDownType('Select Id Type', "select");

  final idNumberController = TextEditingController();

  final firstNameController = TextEditingController();

  final middleNameController = TextEditingController();

  final lastNameController = TextEditingController();

  AlertDialog showAlert(BuildContext context, String title, String body) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    return AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        okButton,
      ],
    );
  }

  handleSelfieResult(BuildContext context, Map<dynamic, dynamic>? result) {
    var resultCode = result!["SID_RESULT_CODE"];
    var resultTag = result["SID_RESULT_TAG"];
    var title = "Selfie Capture Failed";
    var body =
        "Failed selfie capture with error ${resultCode} tag ${resultTag}";
    if (resultCode == -1) {
      title = "Selfie Capture Success";
      body =
          "Successfully captured selfie with tag ${result["SID_RESULT_TAG"]}";
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return showAlert(context, title, body);
      },
    );
  }

  processResponse(Map<dynamic, dynamic>? response) {
    countryDropDownValue = new DropDownType('Select Country', "select");
    idTypeDropDownValue = new DropDownType('Select Id Type', "select");
    idNumberController.text = "";
    firstNameController.text = "";
    middleNameController.text = "";
    lastNameController.text = "";
    if (response != null) {
      if (response["result"]["ResultCode"] != null &&
          response["result"]["ResultText"] != null) {
        setState(() {
          currentUserId = response["result"]["PartnerParams"]["user_id"];
        });
        EasyLoading.showSuccess(
            "Job Submission Succeededwith result code ${response["result"]["ResultCode"]} and result text ${response["result"]["ResultText"]}");
        return;
      }
    }
    EasyLoading.showError("Oops something went wrong, please try again");
  }

  doEnrollWithIDCard() async {
    var result = await SmileFlutter.captureSelfieAndIDCard("") ?? null;
    var resultCode = result!["SID_RESULT_CODE"];
    var resultTag = result["SID_RESULT_TAG"];
    if (resultCode == -1) {
      try {
        EasyLoading.show(status: 'loading...');
        var submitResult = await SmileFlutter.submitJob(
            resultTag, 1, isProduction, "https:test.com", null, null, null);
        EasyLoading.dismiss();
        processResponse(submitResult);
        return;
      } catch (e) {
        EasyLoading.showError("Oops something went wrong");
      }
      return;
    }
  }

  doDocVerification() async {
    var config = HashMap<String, String>();
    config["id_capture_side"] = "0";
    config["id_capture_orientation"] = "1";
    var result = await SmileFlutter.captureSelfieAndIDCard("", config) ?? null;
    var resultCode = result!["SID_RESULT_CODE"];
    var resultTag = result["SID_RESULT_TAG"];
    if (resultCode == -1) {
      docVPickerDialog(context, tag: resultTag);
      return;
    }
    EasyLoading.showError("Oops document verification failed");
  }

  doEnrollWithIDNumber(BuildContext context) async {
    var result = await SmileFlutter.captureSelfie("") ?? null;
    var resultCode = result!["SID_RESULT_CODE"];
    var resultTag = result["SID_RESULT_TAG"];
    if (resultCode == -1) {
      showIdInfoDialog(context, tag: resultTag);
      return;
    }
    EasyLoading.showError("Oops something went wrong");
  }

  doEnroll({String tag = ""}) async {
    var result = await SmileFlutter.captureSelfie(tag) ?? null;
    var resultCode = result!["SID_RESULT_CODE"];
    var resultTag = result["SID_RESULT_TAG"];

    var partnerParams = HashMap<String, String>();
    partnerParams["user_id"] = "currentUserId1";
    partnerParams["job_id"] = "currentUserId1";
    if (resultCode == -1) {
      try {
        EasyLoading.show(status: 'loading...');
        var submitResult = await SmileFlutter.submitJob(resultTag, 4,
            isProduction, "https:test.com", partnerParams, null, null);
        EasyLoading.dismiss();
        processResponse(submitResult);
        return;
      } catch (e) {
        print(e);
        EasyLoading.showError("Oops something went wrong");
      }
      return;
    }
  }

  doAuth({String tag = "", String? userId}) async {
    var partnerParams = null;
    if (currentUserId != null) {
      partnerParams = HashMap<String, String>();
      partnerParams["user_id"] = currentUserId;
    }
    var result = await SmileFlutter.captureSelfie(tag) ?? null;
    var resultCode = result!["SID_RESULT_CODE"];
    var resultTag = result["SID_RESULT_TAG"];
    if (resultCode == -1) {
      try {
        EasyLoading.show(status: 'loading...');
        var submitResult = await SmileFlutter.submitJob(resultTag, 2,
            isProduction, "https:test.com", partnerParams, null, null);
        print("Japhet now running an result is ${submitResult}");
        EasyLoading.dismiss();
        processResponse(submitResult);
        return;
      } catch (e) {
        print("Japhet now running error is ${e}");
        EasyLoading.showError("Oops something went wrong");
      }
      return;
    }
  }

  showIdInfoDialog(BuildContext context, {String tag = ""}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text("Please enter id information"),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      DropdownButton<DropDownType>(
                        value: countryDropDownValue,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (DropDownType? newValue) {
                          setState(() {
                            countryDropDownValue = newValue!;
                          });
                        },
                        items: <DropDownType>[
                          new DropDownType('Select Country', "select"),
                          new DropDownType('Ghana', "GH"),
                          new DropDownType('Kenya', "KE"),
                          new DropDownType('Nigeria', "NG"),
                          new DropDownType('South Africa', "ZA"),
                        ].map<DropdownMenuItem<DropDownType>>(
                            (DropDownType value) {
                          return DropdownMenuItem<DropDownType>(
                            value: value,
                            child: Text(value.name),
                          );
                        }).toList(),
                      ),
                      DropdownButton<DropDownType>(
                        value: idTypeDropDownValue,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (DropDownType? newValue) {
                          setState(() {
                            idTypeDropDownValue = newValue!;
                            currentUserId = newValue.name;
                          });
                        },
                        items: <DropDownType>[
                          new DropDownType('Select Id Type', "select"),
                          new DropDownType(
                              "Driver's License", "DRIVERS_LICENSE"),
                          new DropDownType("Passport", "PASSPORT"),
                          new DropDownType("SSNIT", "SSNIT"),
                          new DropDownType("Voter ID", "VOTER_ID"),
                          new DropDownType("National ID", "NATIONAL_ID"),
                          new DropDownType("Alien Card", "ALIEN_CARD"),
                          new DropDownType("BVN", "BVN"),
                          new DropDownType("NIN", "NIN"),
                          new DropDownType("NIN SLIP", "NIN_SLIP"),
                          new DropDownType("TIN", "TIN"),
                          new DropDownType("CAC", "CAC"),
                        ].map<DropdownMenuItem<DropDownType>>(
                            (DropDownType value) {
                          return DropdownMenuItem<DropDownType>(
                            value: value,
                            child: Text(value.name),
                          );
                        }).toList(),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "ID Number"),
                        controller: idNumberController,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "First Name"),
                        controller: firstNameController,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Middle Name"),
                        controller: middleNameController,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Last Name"),
                        controller: lastNameController,
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          // your code
                        }),
                    OutlinedButton(
                        child: Text("Submit"),
                        onPressed: () async {
                          if (countryDropDownValue.value == "select") {
                            EasyLoading.showError("Please select country");
                            return;
                          }
                          if (idTypeDropDownValue.value == "select") {
                            EasyLoading.showError("Please select ID Type");
                            return;
                          }

                          if (idNumberController.text.isEmpty) {
                            EasyLoading.showError("Please enter ID number");
                            return;
                          }
                          var userIdInfo = HashMap<String, String>();
                          if (countryDropDownValue != null) {
                            userIdInfo["country"] = countryDropDownValue.value;
                          }
                          if (idTypeDropDownValue != null) {
                            userIdInfo["id_type"] = idTypeDropDownValue.value;
                          }
                          if (!idNumberController.text.isEmpty) {
                            userIdInfo["id_number"] = idNumberController.text;
                          }

                          if (!firstNameController.text.isEmpty) {
                            userIdInfo["first_name"] = firstNameController.text;
                          }
                          if (!middleNameController.text.isEmpty) {
                            userIdInfo["middle_name"] =
                                middleNameController.text;
                          }
                          if (!lastNameController.text.isEmpty) {
                            userIdInfo["last_name"] = lastNameController.text;
                          }
                          userIdInfo["dob"] = "1990-07-17";
                          Navigator.of(context, rootNavigator: true).pop();
                          try {
                            EasyLoading.show(status: 'loading...');
                            var submitResult = await SmileFlutter.submitJob(
                                tag,
                                1,
                                false,
                                "https:test.com",
                                null,
                                userIdInfo,
                                null);
                            EasyLoading.dismiss();
                            processResponse(submitResult);
                            return;
                          } catch (e) {
                            print(e);
                            EasyLoading.showError(
                                "Oops enroll with id number failed");
                          }
                          // your code
                        })
                  ],
                )
              ],
            );
          });
        });
  }

  docVPickerDialog(BuildContext context, {String tag = ""}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text("Please enter id information"),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      DropdownButton<DropDownType>(
                        value: countryDropDownValue,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (DropDownType? newValue) {
                          setState(() {
                            countryDropDownValue = newValue!;
                          });
                        },
                        items: <DropDownType>[
                          new DropDownType('Select Country', "select"),
                          new DropDownType('Algeria', "DZ"),
                          new DropDownType('Angola', "AO"),
                          new DropDownType('Benin', "BJ"),
                          new DropDownType('Botswana', "BW"),
                          new DropDownType('Burkina Faso', "BF"),
                          new DropDownType('Burundi', "BI"),
                          new DropDownType('Cameroon', "CM"),
                          new DropDownType('Cabo Verde', "CV"),
                          new DropDownType('Chad', "TD"),
                          new DropDownType('Comoros', "KM"),
                          new DropDownType('Congo', "CG"),
                          new DropDownType('Côte d Ivoire', "CI"),
                          new DropDownType('DRC', "CD"),
                          new DropDownType('Djibouti', "DJ"),
                          new DropDownType('Egypt', "EG"),
                          new DropDownType('Equatorial Guinea', "GQ"),
                          new DropDownType('Eritrea', "ER"),
                          new DropDownType('Ethiopia', "ET"),
                          new DropDownType('Gabon', "GA"),
                          new DropDownType('Gambia', "GM"),
                          new DropDownType('Ghana', "GH"),
                          new DropDownType('Guinea', "GN"),
                          new DropDownType('Guinea-Bissau', "GW"),
                          new DropDownType('Kenya', "LS"),
                          new DropDownType('Liberia', "LR"),
                          new DropDownType('Libya', "LY"),
                          new DropDownType('Madagascar', "MW"),
                          new DropDownType('Mali', "ML"),
                          new DropDownType('Malawi', "MG"),
                          new DropDownType('Mauritius', "MU"),
                          new DropDownType('Mozambique', "MZ"),
                          new DropDownType('Namibia', "NA"),
                          new DropDownType('Niger', "NE"),
                          new DropDownType('Nigeria', "NG"),
                          new DropDownType('Morocco', "MA"),
                          new DropDownType('Lesotho', "KE"),
                          new DropDownType('Nigeria', "NG"),
                          new DropDownType('Rwanda', "RW"),
                          new DropDownType('Sao Tome and Principe', "ST"),
                          new DropDownType('Senegal', "SN"),
                          new DropDownType('Seychelles', "SC"),
                          new DropDownType('Sierra Leone', "SL"),
                          new DropDownType('Somalia', "SO"),
                          new DropDownType('South Africa', "ZA"),
                          new DropDownType('Sudan', "SD"),
                          new DropDownType('Togo', "TG"),
                          new DropDownType('Tunisia', "TN"),
                          new DropDownType('Uganda', "UG"),
                          new DropDownType('Tanzania', "TZ"),
                          new DropDownType('Zambia', "ZM"),
                          new DropDownType('Zimbabwe', "ZW"),
                        ].map<DropdownMenuItem<DropDownType>>(
                            (DropDownType value) {
                          return DropdownMenuItem<DropDownType>(
                            value: value,
                            child: Text(value.name),
                          );
                        }).toList(),
                      ),
                      DropdownButton<DropDownType>(
                        value: idTypeDropDownValue,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (DropDownType? newValue) {
                          setState(() {
                            idTypeDropDownValue = newValue!;
                            currentUserId = newValue.name;
                          });
                        },
                        items: <DropDownType>[
                          new DropDownType('Select Id Type', "select"),
                          new DropDownType(
                              "Driver's License", "DRIVERS_LICENSE"),
                          new DropDownType("Passport", "PASSPORT"),
                          new DropDownType("SSNIT", "SSNIT"),
                          new DropDownType("Voter ID", "VOTER_ID"),
                          new DropDownType("National ID", "NATIONAL_ID"),
                          new DropDownType("Alien Card", "ALIEN_CARD"),
                          new DropDownType("BVN", "BVN"),
                          new DropDownType("NIN", "NIN"),
                          new DropDownType("NIN SLIP", "NIN_SLIP"),
                          new DropDownType("TIN", "TIN"),
                          new DropDownType("CAC", "CAC"),
                        ].map<DropdownMenuItem<DropDownType>>(
                            (DropDownType value) {
                          return DropdownMenuItem<DropDownType>(
                            value: value,
                            child: Text(value.name),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          // your code
                        }),
                    OutlinedButton(
                        child: Text("Submit"),
                        onPressed: () async {
                          if (countryDropDownValue.value == "select") {
                            EasyLoading.showError("Please select country");
                            return;
                          }
                          if (idTypeDropDownValue.value == "select") {
                            EasyLoading.showError("Please select ID Type");
                            return;
                          }

                          var userIdInfo = HashMap<String, String>();
                          if (countryDropDownValue != null) {
                            userIdInfo["country"] = countryDropDownValue.value;
                          }
                          if (idTypeDropDownValue != null) {
                            userIdInfo["id_type"] = idTypeDropDownValue.value;
                          }
                          userIdInfo["use_enrolled_image"] = "false";
                          Navigator.of(context, rootNavigator: true).pop();
                          try {
                            EasyLoading.show(status: 'loading...');
                            var submitResult = await SmileFlutter.submitJob(
                                tag,
                                6,
                                true,
                                "https:test.com",
                                null,
                                userIdInfo,
                                null);
                            EasyLoading.dismiss();
                            processResponse(submitResult);
                            return;
                          } catch (e) {
                            EasyLoading.showError(
                                "Oops document verification failed");
                          }
                          // your code
                        })
                  ],
                )
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Smile ID Flutter Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SwitchListTile(
                title: const Text('Run on Production'),
                value: isProduction,
                onChanged: (bool value) {
                  setState(() {
                    isProduction = value;
                  });
                },
                secondary: const Icon(Icons.lightbulb_outline),
              ),
              OutlinedButton(
                  onPressed: () async {
                    var result = await SmileFlutter.captureSelfie(
                            "TEST_SELFIE_ID_CARD") ??
                        null;
                    handleSelfieResult(context, result);
                  },
                  child: Text("Selfie Test")),
              OutlinedButton(
                  onPressed: () async {
                    var config = HashMap<String, String>();
                    config["id_prompt_blurry"] = "This is blurry";
                    config["id_capture_side"] = "0";
                    config["id_capture_orientation"] = "2";
                    var result =
                        await SmileFlutter.captureIDCard("TEST_ID_CARD",config) ??
                            null;
                    handleSelfieResult(context, result);
                  },
                  child: Text("ID Card Test")),
              OutlinedButton(
                  onPressed: () async {
                    var config = HashMap<String, String>();
                    config["id_capture_side"] = "0";
                    config["id_capture_orientation"] = "2";
                    config["is_white_labelled"] = "false";
                    var result = await SmileFlutter.captureSelfieAndIDCard(
                            "test_tag", config) ??
                        null;
                    handleSelfieResult(context, result);
                  },
                  child: Text("Selfie and ID Card Test")),
              OutlinedButton(
                  onPressed: () async {
                    doEnroll();
                  },
                  child: Text("Enrol")),
              OutlinedButton(
                  onPressed: () {
                    doEnrollWithIDCard();
                  },
                  child: Text("Enroll with ID Card")),
              OutlinedButton(
                  onPressed: () {
                    doDocVerification();
                  },
                  child: Text("Document verification")),
              OutlinedButton(
                  onPressed: () {
                    doEnrollWithIDNumber(context);
                  },
                  child: Text("Enroll with ID Number")),
              OutlinedButton(
                  onPressed: () {
                    if (currentUserId != null) {
                      print("Japhet now running an auth ${currentUserId}");
                      doAuth();
                    } else {
                      EasyLoading.showError(
                          "Please perform an enroll first before attempting to authenticate");
                    }
                  },
                  child: Text("Authenticate")),
              OutlinedButton(
                  onPressed: () async {
                    try {
                      var millis = 978296400000;
                      var dt = DateTime.fromMillisecondsSinceEpoch(millis);
                      var currentTag =
                          DateFormat('dd_MM_yyyy_HH_mm_ss').format(dt);
                      var result = await SmileFlutter.showBVNConsent(
                              currentTag,
                              Platform.isAndroid ? "ic_purse" : "AppIcon",
                              "com.smileidentity.smileFlutterExample",
                              "Smile ID Test",
                              "https://docs.smileidentity.com/",false) ??
                          null;

                      print("Japhet starting");
                      for(var v in result!.keys) {
                        print("key is "+v);
                        // print("value is "+result[v]);
                      }
                      print("Japhet ending");
                      var resultCode = result["SID_RESULT_CODE"];
                      if (resultCode == 1) {
                        doEnroll(tag: currentTag);
                        return;
                      }
                      EasyLoading.showError("User did not allow consent");
                    } catch (e) {
                      EasyLoading.showError("Oops something went wrong $e");
                    }
                  },
                  child: Text("Show Consent")),
              OutlinedButton(
                  onPressed: () async {
                    try {
                      // print("japhet starting getCurrentTags");
                      // var result = await SmileFlutter.getCurrentTags() ?? null;
                      // print(result);
                      // print("japhet ending getCurrentTags");

                      print("japhet starting getImagesForTag");
                      var result2 =
                          await SmileFlutter.getImagesForTag("test_tag") ??
                              null;
                      print(result2);
                      print("japhet ending getImagesForTag");

                      if (result2 != null) {
                        print('Japhet result2 is not null');
                        List<dynamic> files = result2['images'];
                        List<String> filePaths = [];
                        for (var file in files) {
                          //File currFile = File(file);
                          //filePaths.add(currFile.path);
                          filePaths.add(file.toString());
                        }
                        print('Japhet before filePaths');
                        print(filePaths);
                        print('Japhet after filePaths');
                        File? _faceImage;
                        File? _documentImage;
                        for (var file in filePaths) {
                          if (file.contains('SID_Preview_Full'))
                            _faceImage = File(file.substring(8, file.length));
                          if (file.contains('SID_IDCard'))
                            _documentImage =
                                File(file.substring(8, file.length));
                        }
                        if (_faceImage != null) {
                          print('Japhet _faceImage is not null');
                          var contents = await _faceImage.readAsBytes();
                          print(
                              'Japhet _faceImage is not null and we are done');
                          print(
                              'The file _faceImage is ${contents.length} bytes long.');
                        } else {
                          print('The file is _faceImage is null.');
                        }

                        if (_documentImage != null) {
                          print('Japhet _documentImage is not null');
                          var contents = await _documentImage.readAsBytes();
                          print(
                              'Japhet _documentImage is not null and we are done');
                          print(
                              'The file  _documentImage is ${contents.length} bytes long.');
                        } else {
                          print('The file is _documentImage is null.');
                        }
                      } else {
                        print('Images are null');
                      }
                    } catch (e) {
                      print('We got an error ${e}');
                    }
                  },
                  child: Text("Print Tags")),
            ],
          ),
        ),
      ),
    );
  }
}
