
import 'package:flutter/widgets.dart';
import 'package:preview/preview.dart';
import 'AvatarGlow.dart';  
void main() {
  runApp(_PreviewApp());
}

class _PreviewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PreviewPage(
      path: 'AvatarGlow.dart',
      providers: () => [
        
      ],
    );
  }
}
  