import 'dart:developer';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Vertex model API key
  final String generativeAIkey = String.fromEnvironment('GENERATIVE_AI_API_KEY');

  // Late instance of generative AI model
  late final ImagenModel model;

  // AI model reply
  List aiReply = [];

  // Text prompt query
  final queryController = TextEditingController();

  // Loading status boolean
  bool isLoading = false;

  @override
  void initState() {
    model = FirebaseVertexAI.instance.imagenModel(model: 'imagen-3.0-generate-002');
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
                  ),
                ),
                TextButton(
                  onPressed: () => queryController.text.isEmpty ? null : readyAiModel(),
                  child: isLoading ? CircularProgressIndicator.adaptive() : Text("Click to query"),
                ),
                ...List.generate(
                  aiReply.length,
                  (index) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      decoration: BoxDecoration(image: DecorationImage(image: MemoryImage(aiReply[index]))),
                    );
                  },
                ),
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
      final response = await model.generateImages(queryController.text);

      final imageList = response.images;

      for (var img in imageList) {
        setState(() {
          aiReply.add(img.bytesBase64Encoded);
        });
      }

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
}
