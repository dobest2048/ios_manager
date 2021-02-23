import 'dart:io';

import 'package:android_mix/android_mix.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:lan_file_more/common/widget/function_widget.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/constant/constant.dart';
import 'package:lan_file_more/external/bot_toast/src/toast.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as pathLib;

class HelperPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HelperPageState();
  }
}

class _HelperPageState extends State<HelperPage> {
  ThemeModel _themeModel;
  CommonModel _commonModel;
  String _version;
  bool _locker;
  String _qqGroupNumber;
  String _qqGroupKey;
  String _authorEmail;
  String _authorAvatar;

  @override
  void initState() {
    super.initState();
    _version = '';
    _locker = true;
  }

  void showText(String content, {int duration = 4}) {
    BotToast.showText(
      text: content,
      duration: Duration(seconds: duration),
    );
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);

    if (_commonModel.gWebData.isNotEmpty) {
      _authorEmail = _commonModel.gWebData['mobile']['config']['author_email'];
      _qqGroupNumber =
          _commonModel.gWebData['mobile']['config']['qq_group_num'];
      _qqGroupKey = _commonModel.gWebData['mobile']['config']['qq_group_key'];
      _authorAvatar =
          _commonModel.gWebData['mobile']['config']['author_avatar'];
    } else {
      _authorEmail = DEFAULT_AUTHOR_EMAIL;
      _qqGroupNumber = DEFAULT_QQ_GROUP_NUM;
      _qqGroupKey = DEFAULT_QQ_GROUP_KEY;
      _authorAvatar = DEFAULT_AUTHOR_AVATAR;
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (_locker) {
      _locker = false;
      setState(() {
        _version = packageInfo.version;
      });
    }
  }

  Future<void> sendMail(String path) async {
    final MailOptions mailOptions = MailOptions(
      attachments: [path],
      subject: 'IOS管理器 日志',
      recipients: ['wanghan9423@outlook.com'],
      isHTML: false,
    );
    await FlutterMailer.send(mailOptions);
  }

  @override
  Widget build(BuildContext context) {
    LanFileMoreTheme themeData = _themeModel?.themeData;

    List<Widget> helperSettingItem = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle('教程'),
          SizedBox(height: 15),
          InkWell(
            onTap: () async {
              if (await canLaunch(TUTORIAL_URL)) {
                await launch(TUTORIAL_URL);
              } else {
                showText('链接打开失败');
              }
            },
            child: ListTile(
              title: LanText('使用教程'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle('日志'),
          SizedBox(height: 15),
          InkWell(
            onTap: () async {
              String externalDir = await AndroidMix.storage.getStorageDirectory;
              String logFilePath = pathLib.join(externalDir, 'FLogs/flog.txt');

              if (await File(logFilePath).exists()) {
                await sendMail(logFilePath);
              } else {
                await FLog.exportLogs();
                await sendMail(logFilePath);
              }
            },
            child: ListTile(
              title: LanText('发送日志'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          InkWell(
            onTap: () async {
              await FLog.clearLogs();
              showText('删除完成');
            },
            child: ListTile(
              title: LanText('删除日志'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          InkWell(
            onTap: () async {
              await FLog.exportLogs();
              String externalDir = await AndroidMix.storage.getStorageDirectory;
              showText('日志导出至: $externalDir');
            },
            child: ListTile(
              title: LanText('导出日志'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          SizedBox(height: 30)
        ],
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeData?.navBackgroundColor,
        border: null,
        middle: NoResizeText(
          '帮助',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 20,
            color: themeData?.navTitleColor,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListView.builder(
          itemCount: helperSettingItem.length,
          itemBuilder: (context, index) {
            return helperSettingItem[index];
          },
        ),
      ),
    );
  }
}
