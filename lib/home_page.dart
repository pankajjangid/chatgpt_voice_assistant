import 'package:chatgpt_voice_assistant/feature_box.dart';
import 'package:chatgpt_voice_assistant/open_api_service.dart';
import 'package:chatgpt_voice_assistant/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  String speech = "";
  String? generatedImageUrl;
  String? generatedContent;
  OpenApiService openApiService = OpenApiService();
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    initSpeechToText();
    super.initState();
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize(onStatus: (status) {
      switch (status) {
        case SpeechToText.doneStatus:
          stopListening();
          break;
      }
    });
    setState(() {});
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  @override
  void dispose() {
    speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> stopListening() async {
    print(speech);

    if (speech.isNotEmpty) {
      final result = await openApiService.isArtPromtAPI(speech);
      if (result.contains('https')) {
        generatedContent = null;
        generatedImageUrl = result;
        setState(() {});
      } else {
        generatedImageUrl = null;
        generatedContent = result;
        setState(() {});
        await systemSpeak(result);
      }
    }
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      print(result.recognizedWords);
      speech = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat GPT 3"),
        leading: Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Virtual assistant pic
            Stack(
              children: [
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle),
                  ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image:
                              AssetImage("assets/images/virtualAssistant.png")),
                      shape: BoxShape.circle),
                )
              ],
            ),
            //Chat bubble
            Visibility(
              visible: generatedImageUrl == null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 40)
                    .copyWith(top: 30),
                decoration: BoxDecoration(
                    border: Border.all(color: Pallete.borderColor),
                    borderRadius: BorderRadius.circular(20)
                        .copyWith(topLeft: Radius.zero)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    generatedContent == null
                        ? "Good morning , What tasks i can do for you ?"
                        : generatedContent!,
                    style: TextStyle(
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                        fontFamily: 'Cera'),
                  ),
                ),
              ),
            ),
            // Text
            if (generatedImageUrl != null)
    Padding(padding:EdgeInsets.all(10.0),child: ClipRRect(borderRadius: BorderRadius.circular(20.0),child: Image.network(generatedImageUrl!)))
            else
              Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    margin: const EdgeInsets.only(top: 10, left: 22),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Here are few features",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Pallete.mainFontColor,
                          fontSize: 20,
                          fontFamily: 'Cera'),
                    )),
              ),
            //feature list
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: const [
                  FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerTitle: 'Chat GPT',
                    headerDesc:
                        'A smarter way to stay organized and informed with ChatGPT',
                  ),
                  FeatureBox(
                    color: Pallete.secondSuggestionBoxColor,
                    headerTitle: 'Dall-E',
                    headerDesc:
                        'Get inspired and stay creative with your personal assistant powered by Dall-E',
                  ),
                  FeatureBox(
                    color: Pallete.thirdSuggestionBoxColor,
                    headerTitle: 'Smart Voice Assistant',
                    headerDesc:
                        'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            startListening();
          } else if (speechToText.isListening) {
            stopListening();
          } else {
            initSpeechToText();
          }
        },
        backgroundColor: Pallete.firstSuggestionBoxColor,
        child:  Icon(speechToText.isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}
