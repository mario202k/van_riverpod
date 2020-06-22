import 'package:flutter/material.dart';

import '../main.dart';

class ModelBody extends StatelessWidget {
  final Widget  child;



  ModelBody({Key key, @required this.child})
      : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(

          physics: ClampingScrollPhysics(),
          padding: EdgeInsets.only(top: 100),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: child,
            ),
          ),
        );
      }),
    );
  }
}
