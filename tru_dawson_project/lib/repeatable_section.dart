import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tru_dawson_project/google_map_field.dart';
import 'picture_widget.dart';
import 'package:signature/signature.dart';

class RepeatableSection extends StatefulWidget {
  final dynamic section;
  final String uniqueKey;
  final GlobalKey<FormBuilderState> fbKey;

  RepeatableSection(
      {required this.section,
      required this.uniqueKey,
      Key? key,
      required this.fbKey})
      : super(key: key);

  @override
  _RepeatableSectionState createState() => _RepeatableSectionState();
}

class _RepeatableSectionState extends State<RepeatableSection> {
  List<Map<String, dynamic>> repeatableFields = [];

  // List to keep track of unique identifiers for each section
  List<String> sectionIdentifiers = [];

  @override
  void initState() {
    super.initState();
    // Start with a default set of fields
    _addSection();
  }

  // Identifier will be a time string. This will ensure uniqueness everytime
  String _generateIdentifier() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Function for adding a repeatable section
  void _addSection() {
    sectionIdentifiers.add(_generateIdentifier());
    repeatableFields.add(widget.section);
  }

  // Function for removing the latest section that was added
  // void _removeSection(String key) {
  //   if (sectionIdentifiers.length > 1 && repeatableFields.length > 1) {
  //     Future.delayed(Duration(milliseconds: 100), () {
  //       for (var question in widget.section['questions']) {
  //         // Loop through the fields of the form and remove them
  //         String controlName = question['control']['meta_data']['control_name'];
  //         String identifier = sectionIdentifiers
  //             .last; // The latest identifier since that is what will be removed.
  //         String fullName =
  //             "$controlName $identifier"; // Control name and identifier together is the name of the field
  //         if (widget.fbKey.currentState?.fields.containsKey(fullName) ??
  //             false) {
  //           // print("\n");
  //           widget.fbKey.currentState?.fields.remove(fullName);
  //         }
  //       }
  //       print(
  //           "Fields after being removed: ${widget.fbKey.currentState?.fields}");
  //     });
  //     repeatableSections.remove(key); // Remove the section from the map
  //     sectionIdentifiers.removeLast(); // Remove the field identifier
  //     repeatableFields.removeLast(); // Remove the latest section from the list
  //   }
  // } This does not function correctly

  // This function belongs to the widget and is required for regenerating sections if desired
  List<Widget> _generateRepeatableFields(Map<String, dynamic> section) {
    List<Widget> repeatableFields = [];
    String identifier = _generateIdentifier();
    for (var question in section['questions']) {
      // Same logic as the generate fields functions
      var controlName = question['control']['meta_data']['control_name'];
      var fieldName =
          "${question['control']['meta_data']['control_name']} $identifier";
      switch (question['control']['type']) {
        case 'date_field': // If the type is date_field, build a date field
          {
            repeatableFields.add(Column(
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
            repeatableFields.add(Column(
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
            repeatableFields.add(Column(
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
              repeatableFields.add(Column(
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
              repeatableFields.add(Column(
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
            //get control name from JSON
            String controlName = fieldName;
            //add custom PictureWidget to the formfields with the controlName passed through to add to a title later
            repeatableFields.add(PictureWidget(controlName: fieldName));
            break;
          }
        case 'Signature': // If the type is signature, make signature box.
          {
            repeatableFields.add(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  //clipRRect to hold signature field, doesn't allow draw outside box as opposed to container
                  child: Signature(
                    height:
                        200, //you can make the field smaller by adjusting this
                    controller: SignatureController(),
                    backgroundColor: Colors.white,
                  ),
                )
              ],
            ));
            break;
          }
        case 'checkbox':
          {
            List<String> optionsList = ["True", "False"];
            repeatableFields.add(Column(
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
            repeatableFields.add(Column(
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
                  repeatableFields.add(Column(
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
                  repeatableFields.add(Column(
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
    }
    return repeatableFields;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0; index < repeatableFields.length; index++)
          ..._generateRepeatableFields(repeatableFields[
              index]), // Here the fields are added to the widget
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Optional: Align buttons to center
          children: [
            Container(
              padding: EdgeInsets.all(16.0), // Add space around the button
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _addSection();
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Color(0xFF6F768A)), // Make the button grey
                ),
                child: Icon(Icons.add),
              ),
            ),
            // SizedBox(width: 10), // Space between buttons
            // ElevatedButton(
            //   onPressed: () {
            //     setState(() {
            //       _removeSection(widget.uniqueKey);
            //     });
            //   },
            //   child: Icon(Icons.remove),
            // ),
          ],
        ),
      ],
    );
  }
}
