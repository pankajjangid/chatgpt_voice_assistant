import 'dart:convert';

import 'package:chatgpt_voice_assistant/pretty_dio_logger.dart';
import 'package:chatgpt_voice_assistant/secrets.dart';
import 'package:dio/dio.dart';

class OpenApiService {
  final List<Map<String, String>> messages = [];
  Future<String> isArtPromtAPI(String prompt) async {
    try {
      var headers = Map<String, String>();
      headers['Content-Type'] = 'application/json';
      headers['Authorization'] = 'Bearer $openAPIKey';
      var result = await getDioWithInterceptor().post('https://api.openai.com/v1/chat/completions',
          options: Options(
            headers: headers,
          ),
          data: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                "role": "user",
                "content":
                    "Does this message wants to generate an AI Picture ,image,art or anything simpler ? $prompt . simply answer in yes  or no"
              }
            ]
          }));
      print(result.data.toString());

      if (result.statusCode == 200) {
        var content =
            result.data['choices'][0]['message']['content'].toString().trim();

        switch (content) {
          case 'YES':
          case 'yes':
          case 'Yes':
          case 'Yes.':
          case 'yes.':
          final res =  await dalleAPI(prompt);
          return res;


          default:
           final res =  await chatGptAPI(prompt);
           return res;
        }
      }
        return 'Something went wrong';

    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGptAPI(String prompt) async {
    messages.add({'role': 'user', "content": prompt});
    try {
      var headers = Map<String, String>();
      headers['Content-Type'] = 'application/json';
      headers['Authorization'] = 'Bearer $openAPIKey';
      var result = await getDioWithInterceptor().post('https://api.openai.com/v1/chat/completions',
          options: Options(
            headers: headers,
          ),
          data: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": messages
          }));

      if (result.statusCode == 200) {
        var content =
            result.data['choices'][0]['message']['content'].toString().trim();

        messages.add({
          'role':'assistant',
          'content':content
        });

        print("Content is $content");
        return content;
      }
      return 'Something went wrong';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dalleAPI(String prompt) async {
    messages.add({'role': 'user', "content": prompt});
    try {
      var headers = Map<String, String>();
      headers['Content-Type'] = 'application/json';
      headers['Authorization'] = 'Bearer $openAPIKey';
      var result = await getDioWithInterceptor().post('https://api.openai.com/v1/images/generations',
          options: Options(
            headers: headers,
          ),
          data: jsonEncode({
            'prompt' : prompt,
            'n':1
          }));

      if (result.statusCode == 200) {
        var imageUrl =
        result.data['data'][0]['url'].toString().trim();
        print(imageUrl);

        messages.add({
          'role':'assistant',
          'content':imageUrl
        });

        return imageUrl;
      }
      return 'Something went wrong';
    } catch (e) {
      print(e);
      return e.toString();

    }

  }

  Dio getDioWithInterceptor(){
    Dio? dio;
    if(dio==null){
      dio = Dio();
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: false,
      ));
    }
    return dio;
  }
}
