import 'package:flutter/material.dart';

class ModelBodyLogin extends StatelessWidget {
  final Widget child;
  final ScrollController scrollController = ScrollController();

  ModelBodyLogin({Key key, this.child})
      : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: Theme.of(context).colorScheme.background),
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          controller: scrollController,
          physics: ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: constraints.minWidth,
                minHeight: constraints.minHeight,
                maxHeight: constraints.maxHeight,
                maxWidth: constraints.maxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 70),
              child: child,
            ),
          ),
        );
      }),
    );
  }
}
