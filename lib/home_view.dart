import 'dart:developer';
import 'dart:io';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Vertex model API key
  final String generativeAIkey = String.fromEnvironment('GENERATIVE_AI_API_KEY');

  // Late instance of generative AI model
  late final GenerativeModel model;

  // AI model reply
  String aiReply = '';

  // Text prompt query
  final queryController = TextEditingController();

  // Nullable selected image
  String? selectedImagePath;

  // Loading status boolean
  bool isLoading = false;

  @override
  void initState() {
    model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-2.0-flash-001',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cooking with AI"), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 15,
              children: [
                SizedBox(height: 50),
                TextFormField(
                  controller: queryController,
                  decoration: InputDecoration(
                    labelText: "Please enter a text to query the model",
                    suffixIcon: IconButton(
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (context) => selectImageSheet(context),
                      ),
                      icon: selectedImagePath != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(File(selectedImagePath!)),
                              child: Icon(Icons.edit, color: Colors.white),
                            )
                          : Icon(Icons.add_a_photo_outlined),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => queryController.text.isEmpty ? null : readyAiModel(),
                  child: isLoading ? CircularProgressIndicator.adaptive() : Text("Click to query"),
                ),
                Text(aiReply),
              ],
            ),
          ),
        ),
      ),
    );
  }

  readyAiModel() async {
    setState(() => isLoading = true);
    try {
      final image = selectedImagePath != null ? await File(selectedImagePath!).readAsBytes() : null;

      final content = [
        // Content.text(queryController.text), // uncomment this code if you only want to query for text
        Content.multi([
          TextPart(queryController.text),
          if (selectedImagePath != null) InlineDataPart("image/jpeg", image!),
        ])
      ];

      final response = await model.generateContent(content);

      final text = response.text;

      setState(() {
        aiReply = text ?? 'Oops... Could not connect with AI';
      });

      // end of try catch block
      setState(() => isLoading = false);
    } on Exception catch (e) {
      setState(() => isLoading = false);
      inspect(e);
      log(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  generateImage() {
    try {} on Exception catch (e) {
      inspect(e);
      log(e.toString());
    } finally {}
  }

  Future<File?> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();

      // 🔹 Check & Request Permissions (Only needed for Camera on Android & iOS)
      if (source == ImageSource.camera) {
        PermissionStatus cameraPermission = await Permission.camera.request();

        if (cameraPermission.isDenied) {
          throw Exception("Camera permission is required to take pictures.");
        } else if (cameraPermission.isPermanentlyDenied) {
          throw Exception("Camera permission is permanently denied. Enable it in settings.");
        }
      }

      // 🔹 Pick Image
      XFile? pickedFile = await picker.pickImage(source: source);

      // 🔹 Handle No Image Selected
      if (pickedFile == null) throw Exception("No image selected.");

      setState(() => aiReply = '');
      queryController.clear();

      return File(pickedFile.path); // ✅ Return the File
    } catch (e) {
      log("Image Picker Error: $e");
      return null; // 🚨 Return null if any error occurs
    }
  }

  // Select option for image query
  Widget selectImageSheet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.file_copy_outlined),
            title: Text("Gallery"),
            onTap: () async {
              Navigator.pop(context);
              final image = await pickImage(ImageSource.gallery);
              setState(() => selectedImagePath = image?.path);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.camera_alt_outlined),
            title: Text("Camera"),
            onTap: () async {
              Navigator.pop(context);
              final image = await pickImage(ImageSource.camera);
              setState(() => selectedImagePath = image?.path);
            },
          ),
        ],
      ),
    );
  }
}
