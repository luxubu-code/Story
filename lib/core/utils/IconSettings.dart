import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension ShadowedIcon on Icon {
  Icon addShadow() {
    return Icon(
      this.icon,
      size: this.size,
      color: this.color,
      shadows: [
        Shadow(
          offset: Offset(2.0, 2.0),
          blurRadius: 3.0,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ],
    );
  }

  Icon toBlackIcon() {
    return Icon(
      this.icon,
      size: this.size,
      color: CupertinoColors.black,
      shadows: [
        Shadow(
          offset: Offset(2.0, 2.0),
          blurRadius: 3.0,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ],
    );
  }

  Icon toWhiteIcon() {
    return Icon(
      this.icon,
      size: this.size,
      color: CupertinoColors.white,
      shadows: [
        Shadow(
          offset: Offset(2.0, 2.0),
          blurRadius: 3.0,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ],
    );
  }

  Icon toPurpleicon() {
    return Icon(
      this.icon,
      size: this.size,
      color: CupertinoColors.systemPurple,
      shadows: [
        Shadow(
          offset: Offset(2.0, 2.0),
          blurRadius: 3.0,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ],
    );
  }

  IconButton toShadow({required void Function() onPressed}) {
    return IconButton(
      icon: addShadow(),
      onPressed: onPressed,
    );
  }
}
