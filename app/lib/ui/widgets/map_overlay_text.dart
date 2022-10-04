import 'package:mnmn/ui/all.dart';

class MapOverlayText extends StatelessWidget {
  const MapOverlayText(
    this.text, {
    this.color,
  });

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return MaxWidthBuilder(
      childBuilder: (_) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: color ?? Colors.black.withOpacity(0.55),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
