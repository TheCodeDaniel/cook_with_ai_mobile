import 'dart:developer';

import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final String generativeAIkey = String.fromEnvironment('GENERATIVE_AI_API_KEY');

  String aiReply = '';

  final queryController = TextEditingController();

  bool isLoading = false;

  late final GenerativeModel model;

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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 15,
            children: [
              SizedBox(height: 50),
              TextFormField(
                controller: queryController,
                decoration: InputDecoration(labelText: "Please enter a text to query the model"),
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
    );
  }

  readyAiModel() async {
    setState(() => isLoading = true);
    try {
      final content = [
        Content.text(queryController.text),
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
}
