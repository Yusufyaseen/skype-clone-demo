import 'package:flutter/material.dart';
import 'package:flutter_projects/utils/universal_variables.dart';

class CustomTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget icon;
  final Widget subTitle;
  final Widget trailing;
  final EdgeInsets margin;
  final bool mini;
  final Function() onTap;
  final Function() onLongPress;

  const CustomTile(
      {Key? key,
      required this.leading,
      required this.title,
      required this.icon,
      required this.subTitle,
      required this.trailing,
        this.margin = const EdgeInsets.all(0),
      required this.mini,
      required this.onTap,
      required this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: mini ? 10 : 0),
        margin: margin,
        child: Row(
          children: <Widget>[
            leading,
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: mini ? 10 : 15),
                padding: EdgeInsets.symmetric(vertical: mini ? 3 : 20),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        width: 1, color: UniversalVariables.separatorColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        title,
                        const SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            icon ,
                            subTitle,
                          ],
                        )
                      ],
                    ),
                    trailing,
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
