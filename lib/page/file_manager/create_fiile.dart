import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:lan_file_more/common/widget/checkbox.dart';
import 'package:lan_file_more/common/widget/dialog.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/common/widget/text_field.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/error.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:path/path.dart' as pathLib;
import 'package:provider/provider.dart';

import 'file_utils.dart';

Future<void> createFileModal(
  BuildContext context, {
  @required String willCreateDir,
  @required Function onExists,
  @required Function(String) onSuccess,
  @required Function(dynamic) onError,
}) async {
  MixUtils.safePop(context);
  ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
  LanFileMoreTheme themeData = themeModel.themeData;
  TextEditingController textEditingController = TextEditingController();
  bool recursiveCreate = false;

  showCupertinoModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) changeState) {
          return LanDialog(
            fontColor: themeData.itemFontColor,
            bgColor: themeData.dialogBgColor,
            title: LanDialogTitle(
                title: '新建', subTitle: '${pathLib.basename(willCreateDir)}'),
            action: true,
            children: <Widget>[
              LanTextField(
                style: TextStyle(textBaseline: TextBaseline.alphabetic),
                controller: textEditingController,
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 30,
                child: Row(children: <Widget>[
                  LanCheckBox(
                    value: recursiveCreate,
                    borderColor: themeData.itemFontColor,
                    onChanged: (val) {
                      changeState(() {
                        recursiveCreate = !recursiveCreate;
                      });
                    },
                  ),
                  NoResizeText(
                    '递归创建  例:xxx/xx/x',
                    style: TextStyle(
                      color: themeData.itemFontColor,
                    ),
                  )
                ]),
              )
            ],
            defaultCancelText: '新建文件',
            defaultOkText: '新建文件夹',
            onOk: () async {
              Directory newDir = Directory(pathLib.join(willCreateDir,
                  LanFileUtils.trimSlash(textEditingController.text)));
              if (await newDir.exists()) {
                onExists();
                return;
              }

              await newDir.create(recursive: recursiveCreate).then((value) {
                onSuccess(textEditingController.text);
                MixUtils.safePop(context);
              }).catchError((err) {
                onError(err);
                recordError(text: '创建文件失败');
              });
            },
            onCancel: () async {
              File newFile = File(pathLib.join(willCreateDir,
                  LanFileUtils.trimSlash(textEditingController.text)));
              if (await newFile.exists()) {
                onExists();
                return;
              }

              await newFile.create(recursive: recursiveCreate).then((value) {
                onSuccess(textEditingController.text);
                MixUtils.safePop(context);
              }).catchError((err) {
                onError(err);
                recordError(text: '创建文件失败');
              });
            },
          );
        },
      );
    },
  );
}
