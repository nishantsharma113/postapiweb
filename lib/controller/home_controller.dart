import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class HomeController extends GetxController {
  RxString selectedMethod = "Post".obs;
  final urlController = TextEditingController();
  final dataController = TextEditingController();
  final box = GetStorage();
  final RxString statusCode = "".obs;
  RxBool isAddContent = false.obs;
  RxBool isLoading = false.obs;
  dynamic responseData;

  RxList<dynamic> list = [].obs;

  RxBool isEncryptData = false.obs;

  final frController = TextEditingController();
  final secretKeyController = TextEditingController();
  dynamic frData;

  List<TextEditingController> headerKeyData = <TextEditingController>[];
  List<TextEditingController> headerValueData = <TextEditingController>[];

  RxMap<String, dynamic> headerData = <String, dynamic>{
    "content-type": "application/json",
    "accept": "application/json"
  }.obs;
  RxBool isHeader = false.obs;
  @override
  void onInit() {
    selectedMethod.value = box.read("selectApi") ?? "Post";
    urlController.text = box.read("url") ?? "";
    isAddContent.value = box.read("isAddContent") ?? false;
    statusCode.value = box.read("statusCode") ?? "";
    responseData = box.read("responseData");
    dataController.text = box.read("content") ?? "";
    isEncryptData.value = box.read("showEncryptData") ?? false;
    secretKeyController.text = box.read("secretKey") ?? "";
    headerData.value = box.read("headerData") ??
        {"content-type": "application/json", "accept": "application/json"};

    for (int i = 0; i < headerData.keys.toList().length; i++) {
      headerKeyData.add(
          TextEditingController(text: headerData.keys.toList()[i].toString()));
    }
    for (int i = 0; i < headerData.values.toList().length; i++) {
      headerValueData.add(TextEditingController(
          text: headerData.values.toList()[i].toString()));
    }

    update();

    super.onInit();
  }

  onSelectedType(value) {
    selectedMethod.value = value;
    box.write("selectApi", selectedMethod.value);
    update();
  }

  onAddContent(value) {
    isAddContent.value = value;
    isEncryptData.value = false;
    isHeader.value = false;
    box.write("isAddContent", isAddContent.value);
    box.write("showEncryptData", isEncryptData.value);
    box.write("showHeaderData", isHeader.value);
    update();
  }

  addHeader() {
    headerKeyData.add(TextEditingController());
    headerValueData.add(TextEditingController());
    update();
  }

  showEncryptData(value) {
    isEncryptData.value = value;
    isAddContent.value = false;
    isHeader.value = false;
    box.write("isAddContent", isAddContent.value);
    box.write("showEncryptData", isEncryptData.value);
    box.write("showHeaderData", isHeader.value);

    update();
  }

  showHeaderData(value) {
    isHeader.value = value;
    isAddContent.value = false;
    isEncryptData.value = false;
    box.write("isAddContent", isAddContent.value);
    box.write("showEncryptData", isEncryptData.value);
    box.write("showHeaderData", isHeader.value);
    update();
  }

  fetchApi() async {
    try {
      if (urlController.text.trim().isNotEmpty) {
        isLoading.value = true;
        responseData = null;

        headerData.value = {};
        for (int i = 0; i < headerKeyData.length; i++) {
          headerData[headerKeyData[i].text] = headerValueData[i].text;
        }

        update();
        box.write("headerData", headerData);
        box.write("url", urlController.text.trim());
        final Dio dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
        ));
        if (selectedMethod.value == "Get") {
          try {
            final response = await dio.get(urlController.text.trim());
            statusCode.value = response.statusCode.toString();
            box.write("statusCode", statusCode.value);
            update();
            if (response.statusCode == 200) {
              responseData = response.data;

              box.write("responseData", responseData);

              update();
            }
          } on DioException catch (e) {
            debugPrint("GET Error: ${e.response?.data ?? e.message}");
            statusCode.value = e.response!.statusCode.toString();
            responseData = "${e.response?.data ?? e.message}";
            box.write("statusCode", e.response!.statusCode.toString());

            box.write("responseData", "${e.response?.data ?? e.message}");
            update();
          }
        } else {
          try {
            if (dataController.text.trim().isNotEmpty) {
              box.write("content", dataController.text.trim());
            }
            print("jd:${headerData}");

            final response = await dio.post(urlController.text.trim(),
                data: dataController.text.trim().isNotEmpty
                    ? json.decode(dataController.text.trim())
                    : null,
                options: Options(headers: headerData));
            print("rd:${response.headers}");
            statusCode.value = response.statusCode.toString();

            box.write("statusCode", statusCode.value);
            update();

            if (response.statusCode == 200) {
              responseData = response.data;

              box.write("responseData", responseData);
              update();
            } else {
              responseData = response.data;

              box.write("responseData", responseData);
              update();
            }
          } on DioException catch (e) {
            print(e.requestOptions.headers.toString());
            if (e.response != null) {
              debugPrint("Post Error: ${e.response?.data ?? e.message}");

              responseData = "${e.response?.data ?? e.message}";
            } else {
              responseData = "${e.message}";
            }

            if (e.response != null) {
              statusCode.value = e.response!.statusCode.toString();
              box.write("statusCode", e.response!.statusCode.toString());
              box.write("responseData", "${e.response?.data ?? e.message}");
            }
            update();
          }
        }
      }
    } catch (e) {
      debugPrint("error:${e.toString()}");
      box.write("responseData", e.toString());
      responseData = e.toString();
      update();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  encryptData() async {
    final key = encrypt.Key.fromBase64(secretKeyController.text.trim());

    // Generate a random IV (Initialization Vector) of 16 bytes
    final iv = encrypt.IV.fromLength(16);

    // Create AES encrypter
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    // Encrypt the response
    final encryptedValue =
        encrypter.encrypt(frController.text.trim().toString(), iv: iv);

    // Convert the IV and the encrypted value to Base64
    final ivBase64 = iv.base64;
    final valueBase64 = encryptedValue.base64;

    // Create an object to hold the IV and the encrypted value
    final encryptedObject = {'iv': ivBase64, 'value': valueBase64};

    // Convert the encrypted object to a JSON string
    final encryptedString = jsonEncode(encryptedObject);

    // Return the base64-encoded JSON string
    frData = base64Encode(utf8.encode(encryptedString));
    box.write("secretKey", secretKeyController.text.trim());
    update();
  }

  decryptData() async {
    box.write("secretKey", secretKeyController.text.trim());
    var decodedResponse = base64.decode(frController.text.trim());

    // Convert the decoded response to a JSON object
    var parsedEncrypted = jsonDecode(utf8.decode(decodedResponse));

    // Get the IV (Initialization Vector) and crypto key from the response and secret key
    final iv = encrypt.IV.fromBase64(parsedEncrypted['iv']);
    final key = encrypt.Key.fromBase64(secretKeyController.text.trim());

    // Create an AES encrypter
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    // Decrypt the value using the key and IV
    final decrypted = encrypter.decrypt64(parsedEncrypted['value'], iv: iv);

    frData = jsonDecode(decrypted);
    update();
  }
}
