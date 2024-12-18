import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postapi/controller/home_controller.dart';
import 'package:velocity_x/velocity_x.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: const Text(
            'Post Api',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: GetBuilder<HomeController>(
          builder: (controller) => SingleChildScrollView(
            child: SizedBox(
              width: context.screenWidth,
              height: context.screenHeight,
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: TextField(
                          controller: controller.urlController,
                          decoration: InputDecoration(
                            hintText: "Enter Request",
                            border: const OutlineInputBorder(),
                            prefixIcon: Row(
                              children: [
                                PopupMenuButton<String>(
                                  onSelected: controller.onSelectedType,
                                  offset: const Offset(0, 45),
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem(
                                      value: "Get",
                                      child: Text("Get"),
                                    ),
                                    const PopupMenuItem(
                                      value: "Post",
                                      child: Text("Post"),
                                    ),
                                  ],
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(controller.selectedMethod.value),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ).pSymmetric(h: 10.0),
                                Container(
                                  width: 0.8,
                                  height: 30,
                                  color: Colors.grey[500],
                                ),
                              ],
                            ).w(80),
                          ),
                        ).pOnly(left: 8.0),
                      ),
                      OutlinedButton(
                              onPressed: () {
                                controller.fetchApi();
                              },
                              style: ButtonStyle(
                                  backgroundColor: const WidgetStatePropertyAll(
                                      Colors.indigo),
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          side: const BorderSide(
                                              color: Colors.indigo,
                                              width: 1.0)))),
                              child: const Text(
                                "Send",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ).pSymmetric(v: 10.0))
                          .pSymmetric(h: 10.0)
                    ],
                  ).h(60.0).pOnly(bottom: 10.0),
                  controller.selectedMethod.value == "Post"
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (controller.isAddContent.value) {
                                      controller.onAddContent(false);
                                    } else {
                                      controller.onAddContent(true);
                                    }
                                  },
                                  child: Container(
                                    color: Colors.white,
                                    child: Row(
                                      children: [
                                        Checkbox(
                                            value:
                                                controller.isAddContent.value,
                                            onChanged: controller.onAddContent),
                                        const Text("Add Post Data")
                                      ],
                                    ),
                                  ),
                                ),
                                20.widthBox,
                                InkWell(
                                  onTap: () {
                                    if (controller.isHeader.value) {
                                      controller.showHeaderData(false);
                                    } else {
                                      controller.showHeaderData(true);
                                    }
                                  },
                                  child: Container(
                                    color: Colors.white,
                                    child: Row(
                                      children: [
                                        Checkbox(
                                            value: controller.isHeader.value,
                                            onChanged:
                                                controller.showHeaderData),
                                        const Text("Add Header Data")
                                      ],
                                    ),
                                  ),
                                ),
                                20.widthBox,
                                InkWell(
                                  onTap: () {
                                    if (controller.isEncryptData.value) {
                                      controller.showEncryptData(false);
                                    } else {
                                      controller.showEncryptData(true);
                                    }
                                  },
                                  child: Container(
                                    color: Colors.white,
                                    child: Row(
                                      children: [
                                        Checkbox(
                                            value:
                                                controller.isEncryptData.value,
                                            onChanged:
                                                controller.showEncryptData),
                                        const Text("Add Entrypt Data")
                                      ],
                                    ),
                                  ),
                                ).pOnly(right: 10.0),
                              ],
                            ),
                            Row(
                              children: [
                                controller.isEncryptData.value
                                    ? Flexible(
                                        flex: 1,
                                        child: TextField(
                                          controller: controller.frController,
                                          minLines: 5,
                                          maxLines: 15,
                                          decoration: const InputDecoration(
                                              hintText: "Enter Data",
                                              border: OutlineInputBorder()),
                                        ).pSymmetric(h: 8.0),
                                      )
                                    : const SizedBox(),
                                controller.isEncryptData.value
                                    ? Flexible(
                                        flex: 1,
                                        child: Container(
                                                width: context.screenWidth,
                                                constraints: BoxConstraints(
                                                    maxHeight: 400,
                                                    minHeight: 145),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 0.5,
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0)),
                                                child: controller.frData != null
                                                    ? SingleChildScrollView(
                                                        child: SelectableText(controller
                                                                        .frData
                                                                    is String
                                                                ? controller
                                                                    .frData
                                                                    .toString()
                                                                : const JsonEncoder
                                                                        .withIndent(
                                                                        '  ')
                                                                    .convert(
                                                                        controller
                                                                            .frData))
                                                            .p8())
                                                    : SizedBox(
                                                        child: const Text(
                                                                "Show Data")
                                                            .p8(),
                                                      ))
                                            .pOnly(right: 10.0))
                                    : const SizedBox(),
                              ],
                            ),
                            10.heightBox,
                            controller.isEncryptData.value
                                ? Row(
                                    children: [
                                      Flexible(
                                        child: TextField(
                                          controller:
                                              controller.secretKeyController,
                                          decoration: const InputDecoration(
                                              hintText: "Enter Secret Key",
                                              border: OutlineInputBorder()),
                                        ).pOnly(left: 8.0),
                                      ),
                                      OutlinedButton(
                                              onPressed: () {
                                                controller.encryptData();
                                              },
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      const WidgetStatePropertyAll(
                                                          Colors.indigo),
                                                  shape: WidgetStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          side:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .indigo,
                                                                  width:
                                                                      1.0)))),
                                              child: const Text(
                                                "Encrypt Data",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ).pSymmetric(v: 10.0))
                                          .pSymmetric(h: 10.0),
                                      OutlinedButton(
                                              onPressed: () {
                                                controller.decryptData();
                                              },
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      const WidgetStatePropertyAll(
                                                          Colors.indigo),
                                                  shape: WidgetStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          side:
                                                              const BorderSide(
                                                                  color: Colors
                                                                      .indigo,
                                                                  width:
                                                                      1.0)))),
                                              child: const Text(
                                                "Decrypt Data",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ).pSymmetric(v: 10.0))
                                          .pOnly(right: 10.0)
                                    ],
                                  ).pOnly(bottom: 10.0)
                                : const SizedBox(),
                            controller.isAddContent.value
                                ? TextField(
                                    controller: controller.dataController,
                                    minLines: 5,
                                    maxLines: 15,
                                    decoration: const InputDecoration(
                                        hintText: "Add Content",
                                        border: OutlineInputBorder()),
                                  ).pSymmetric(h: 8.0)
                                : const SizedBox(),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Column(
                                        children: List.generate(
                                            controller.headerKeyData.length,
                                            (int i) {
                                          return TextField(
                                            controller:
                                                controller.headerKeyData[i],
                                            decoration: const InputDecoration(
                                                hintText: "Key",
                                                border: OutlineInputBorder()),
                                          ).pSymmetric(h: 8.0, v: 4.0);
                                        }),
                                      ),
                                    ),
                                    Flexible(
                                      child: Column(
                                        children: List.generate(
                                            controller.headerValueData.length,
                                            (int i) {
                                          return TextField(
                                            controller:
                                                controller.headerValueData[i],
                                            decoration: const InputDecoration(
                                                hintText: "Value",
                                                border: OutlineInputBorder()),
                                          ).pSymmetric(h: 8.0, v: 4.0);
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                                10.heightBox,
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton(
                                          onPressed: () {
                                            controller.addHeader();
                                          },
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  const WidgetStatePropertyAll(
                                                      Colors.indigo),
                                              shape: WidgetStatePropertyAll(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      side: const BorderSide(
                                                          color: Colors.indigo,
                                                          width: 1.0)))),
                                          child: const Text(
                                            "Add Header",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                          ).pSymmetric(v: 10.0))
                                      .pSymmetric(h: 10.0),
                                ),
                              ],
                            )
                          ],
                        ).pOnly(bottom: 10.0)
                      : const SizedBox(),
                  controller.statusCode.value.isNotEmpty
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Response"),
                            Text("Status Code : ${controller.statusCode.value}")
                          ],
                        ).pSymmetric(h: 8.0)
                      : const SizedBox(),
                  controller.responseData != null &&
                          controller.isLoading.value == false
                      ? Flexible(
                          child: Container(
                            width: context.screenWidth,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.5, color: Colors.black),
                                borderRadius: BorderRadius.circular(5.0)),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                      controller.responseData is String
                                          ? controller.responseData
                                          : const JsonEncoder.withIndent('  ')
                                              .convert(controller.responseData))
                                  .p8(),
                            ),
                          ).p8(),
                        )
                      : controller.isLoading.value == true &&
                              controller.responseData == null
                          ? const Text("Loading ....")
                          : const SizedBox(),
                ],
              ).p16(),
            ),
          ),
        ));
  }
}
