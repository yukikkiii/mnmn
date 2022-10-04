import 'package:mnmn/ui/all.dart';

ImageProvider uploadedImage(String path) {
  return NetworkImage(Config.API_URL + path);
}

class CenteredSingleChildScrollView extends StatelessWidget {
  const CenteredSingleChildScrollView({
    required this.child,
    this.padding,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class MaxHeightBuilder extends StatelessWidget {
  const MaxHeightBuilder({
    this.containerBuilder,
    required this.childBuilder,
  });

  final Widget Function(BuildContext, Widget)? containerBuilder;
  final Widget Function(BuildContext) childBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final child = ConstrainedBox(
          constraints: BoxConstraints(maxHeight: constraints.maxHeight),
          child: Builder(
            builder: (context) => childBuilder(context),
          ),
        );

        if (containerBuilder == null) {
          return child;
        }
        return containerBuilder!(
          context,
          child,
        );
      },
    );
  }
}

class MaxWidthBuilder extends StatelessWidget {
  const MaxWidthBuilder({
    this.containerBuilder,
    required this.childBuilder,
  });

  final Widget Function(BuildContext, Widget)? containerBuilder;
  final Widget Function(BuildContext) childBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final child = ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Builder(
            builder: (context) => childBuilder(context),
          ),
        );

        if (containerBuilder == null) {
          return child;
        }
        return containerBuilder!(
          context,
          child,
        );
      },
    );
  }
}
