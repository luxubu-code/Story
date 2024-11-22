import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String description;

  const ExpandableText({super.key, required this.description});
  @override
  _ExpandableText createState() => _ExpandableText();
}

class _ExpandableText extends State<ExpandableText> {
  bool selected = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 25),
              decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: selected
                        ? MediaQuery.of(context).size.width
                        : MediaQuery.of(context).size.width,
                    child: Text(
                      widget.description,
                      style: TextStyle(color: Colors.white),
                      maxLines: selected ? null : 3,
                      overflow: selected
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: selected ? -20 : -25,
              right: 0,
              left: 0,
              child: Align(
                alignment: Alignment.center,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        selected = !selected;
                      });
                    },
                    icon: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.pinkAccent)),
                      child: Icon(
                        selected ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        size: 30,
                        color: Colors.pinkAccent,
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
