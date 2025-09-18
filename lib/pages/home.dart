import 'package:flutter/material.dart';
import 'popupsSettingsPage.dart';
import 'ListsPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ClipPath(
              clipper: TopSlantClipper(),
              child: Container(
                color: Colors.orange,
                height: screenHeight * 0.15,
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text(
                  "NotiBac",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 45,
                  right: 20,
                  left: 20,
                  bottom: 10,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: const Text(
                    'مرحبًا بك في تطبيق NotiBac!\n\n'
                    'يساعدك هذا التطبيق على حفظ تواريخ وأحداث مادة التاريخ للبكالوريا بسهولة عبر التذكير بها بإشعارات منتظمة.\n\n'
                    'يضم قسمين رئيسيين:\n'
                    '• 📅 إدارة الأحداث والتواريخ\n'
                    '• ⏰ إعدادات تردد الإشعارات\n\n'
                    'ابدأ الآن واجعل حفظ التواريخ أسهل من أي وقت!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            ClipPath(
              clipper: BottomSlantClipper(),
              child: Container(
                color: Colors.orange, // same as top
                width: double.infinity,
                height: screenHeight * 0.4,
                child: Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.06),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.8,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 4,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ListsPage(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Icon(Icons.calendar_month, size: 28),
                              Text(
                                'إدارة الأحداث والتواريخ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 4,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Popupssettingspage(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Icon(Icons.access_time, size: 28),
                              Text(
                                'إعدادات تردد الإشعارات',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopSlantClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double slant = size.height * 0.4; // 30% of its height
    Path path = Path();
    path.lineTo(0, size.height); // bottom left
    path.lineTo(size.width, size.height - slant); // bottom right raised up
    path.lineTo(size.width, 0); // top right
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class BottomSlantClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double slant = size.height * 0.2; // 15% of its height
    Path path = Path();
    path.moveTo(0, 0); // top left
    path.lineTo(size.width, slant); // top right pushed down
    path.lineTo(size.width, size.height); // bottom right
    path.lineTo(0, size.height); // bottom left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
