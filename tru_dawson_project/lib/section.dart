import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tru_dawson_project/generation.dart';
import 'package:tru_dawson_project/google_map_field.dart';
import 'picture_widget.dart';
import 'form_page.dart';
import 'package:signature/signature.dart';

class Section extends StatefulWidget {
  final dynamic section;
  final String uniqueKey;
  final GlobalKey<FormBuilderState> fbKey;

  Section(
      {required this.section,
      required this.uniqueKey,
      Key? key,
      required this.fbKey})
      : super(key: key);

  @override
  _SectionState createState() => _SectionState();
}

int extraIdentifier =
    0; // Needed for organizing form fields for view past forms

class _SectionState extends State<Section> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  void initState() {
    super.initState();
  }

  // Identifier will be a time string. This will ensure uniqueness everytime
  String generateIdentifier() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // This function belongs to the widget and is required for regenerating sections if desired
  List<Widget> _generateFields(Map<String, dynamic> section) {
    List<Widget> fields = [];

    for (var question in section['questions']) {
      // Same logic as the generate fields functions
      var controlName = question['control']['meta_data']['control_name'];
      print("Extra Identifier Value for $controlName: $extraIdentifier \n\n");
      String identifier = generateIdentifier();
      var fieldName =
          "${question['control']['meta_data']['control_name']} $identifier $extraIdentifier";
      switch (question['control']['type']) {
        case 'date_field': // If the type is date_field, build a date field
          {
            fields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderDateTimePicker(
                  name: fieldName,
                  decoration: InputDecoration(
                    labelText: controlName,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  inputType: InputType.date,
                ),
                SizedBox(height: 10),
              ],
            ));
            break;
          }
        case 'text_field': // If the type is text_field, build a date field
          {
            fields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormBuilderTextField(
                  name: fieldName,
                  decoration: InputDecoration(
                    labelText: controlName,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 20)
              ],
            ));
            break;
          }
        case 'Dropdown':
          {
            var options = question['control']['meta_data']['options'];
            var controlName = question['control']['meta_data']['control_name'];
            fields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controlName),
                SizedBox(height: 10),
                FormBuilderDropdown(
                  name: fieldName,
                  decoration: InputDecoration(
                    labelText: controlName,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  items: options.map<DropdownMenuItem<String>>((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
              ],
            ));
            break;
          }
        case 'multiselect':
          {
            var options = question['control']['meta_data']['options']
                as List<dynamic>; // Cast options to List<dynamic>
            List<String> optionsList = [];
            if (options.length == 1) {
              // If there is only one element in the list (i.e. one string that contains all the options)
              // If options in the JSON is represented as one string, then it will need to be split
              optionsList = (options[0] as String)
                  .split(', '); // Cast options[0] to String
              fields.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  FormBuilderCheckboxGroup(
                    name: fieldName,
                    options: optionsList
                        .map((option) => FormBuilderFieldOption(
                            value: option as String, // Cast option to String
                            child: Text(
                                option as String))) // Cast option to String
                        .toList(),
                    decoration: InputDecoration(
                      labelText: controlName,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ));
            } else {
              // If there are multiple elements in options
              fields.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  FormBuilderCheckboxGroup(
                    name: fieldName,
                    options: optionsList
                        .map((option) => FormBuilderFieldOption(
                            value: option as String, // Cast option to String
                            child: Text(
                                option as String))) // Cast option to String
                        .toList(),
                    decoration: InputDecoration(
                      labelText: controlName,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ));
            }
            break;
          }
        case 'picture':
          {
            final GlobalKey<PictureWidgetState> key =
                GlobalKey<PictureWidgetState>();
            //add custom PictureWidget to the formfields with the controlName passed through to add to a title later
            var pictureWidget =
                PictureWidget(controlName: controlName, key: key);
            fields.add(pictureWidget);
            pictureWidgets.add(
                pictureWidget); // Add the image to the pictureWidgets list. Required for resetting states while navigating.
            break;
          }
        case 'Signature': // If the type is signature, make signature box.
          {
            fields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please provide your signature:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          // Outline color
                          //  width: 2.0, // Outline width
                        ),
                      ),
                      //clipRRect to hold signature field, doesn't allow draw outside box as opposed to container
                      child: Signature(
                        height:
                            200, //you can make the field smaller by adjusting this
                        controller: signatureController,
                        backgroundColor: Colors.white,
                      ),
                    )),
                Row(
                  children: [
                    IconButton(
                        tooltip: "Confirm your signature",
                        onPressed: () async {
                          if (signatureController.isNotEmpty) {
                            final signature = await exportSignature();
                          }
                        },
                        icon: Icon(Icons.check),
                        color: Colors.green),
                    IconButton(
                        tooltip: "Clear your signature",
                        onPressed: () {
                          signatureController.clear();
                          //TODO: fix removing all signatures
                          signatureURL = [];
                        },
                        icon: Icon(Icons.clear),
                        color: Colors.red),
                  ],
                )
              ],
            ));
            break;
          }
        case 'checkbox':
          {
            List<String> optionsList = ["True", "False"];
            fields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                FormBuilderRadioGroup(
                  name: fieldName,
                  options: optionsList
                      .map((option) => FormBuilderFieldOption(
                            value: option as String,
                            child: Text(option as String),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: controlName,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ));
            break;
          }
        case 'gps_location': // gps location! how exciting.
          {
            fields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pin is on your current location. Drag pin to edit.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          // Outline color
                          //  width: 2.0, // Outline width
                        ),
                      ),
                      //map :O
                      child: MapField(),
                    ))
              ],
            ));
            break;
          }
        case 'label': // If the type is a label, display some text.
          {
            var labelName;
            var labelType;
            var labelText;
            if (question['control']['meta_data'].containsKey('meta_data')) {
              // In the label section of fuel_inspection.json, there is a nested field with two metadata keys. This may be a mistake, but I will account for it here in case it pops up again in other forms
              labelName =
                  question['control']['meta_data']['meta_data']['control_name'];
              labelType =
                  question['control']['meta_data']['meta_data']['label_type'];
              labelText =
                  question['control']['meta_data']['meta_data']['control_text'];
            } else {
              labelName = controlName;
              labelType = question['control']['meta_data']['label_type'];
              labelText = question['control']['meta_data']['control_text'];
            }
            switch (labelType) {
              // The text would be presented differently depending on the label type, more cases will need to be added if new styles show up in different forms
              case "bold": // Text will be bold
                {
                  fields.add(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labelName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 36),
                      ),
                      Text(
                        labelText,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ],
                  ));
                  break;
                }
              default: // Default case no styling
                {
                  fields.add(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labelName,
                      ),
                      Text(
                        labelText,
                      ),
                    ],
                  ));
                  break;
                }
            }
            break;
          }
        default: // Print a message
          {
            print("Unidentified form field detected.");
            break;
          }
      }
      extraIdentifier++;
    }
    return fields;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        ..._generateFields(
            widget.section), // Here the fields are added to the widget
      ],
    );
  }
}
