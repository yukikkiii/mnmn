import 'package:mnmn/ui/all.dart';

class CompanyProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('会社概要')),
      body: SingleChildScrollView(
        child: Padding(
          padding: scrollablePaddingWithHorizontal,
          child: Column(
            children: [
              Text('このページに会社概要を記載します')
            ],
          ),
        ),
      ),
    );
  }
}
