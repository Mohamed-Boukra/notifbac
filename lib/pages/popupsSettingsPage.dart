import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'package:workmanager/workmanager.dart';
import '../services/notification_service.dart';//this is from old testing 



class Popupssettingspage extends StatefulWidget {
  const Popupssettingspage({super.key});

  @override
  State<Popupssettingspage> createState() => _PopupssettingspageState();
}

class _PopupssettingspageState extends State<Popupssettingspage> {
  String selectedFrequency = 'متوسط';
  bool isStudyDisabled = false;
  bool isMorningTimeSelected = false;
  bool isEveningTimeSelected = false;
  TextEditingController popupCountController = TextEditingController();
  String? errorText;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseService.getPopupSettings();
    setState(() {
      selectedFrequency = settings['selectedFrequency'] ?? 'متوسط';
      isStudyDisabled = settings['isStudyDisabled'] ?? false;
      isMorningTimeSelected = settings['isMorningTimeSelected'] ?? false;
      isEveningTimeSelected = settings['isEveningTimeSelected'] ?? false;
      popupCountController.text = settings['popupCount'] ?? '';
    });
  }

  Future<void> _saveSettings() async {
    // Check for custom popup count error before saving
    if (selectedFrequency == 'مخصص' && (popupCountController.text.isEmpty || _validatePopupCount(popupCountController.text) != null)) {
      setState(() {
        errorText = 'يرجى إدخال عدد صحيح بين 1 و 130';
      });
      return;
    }

    // Save settings to the database first
    final settings = {
      'selectedFrequency': selectedFrequency,
      'isStudyDisabled': isStudyDisabled,
      'isMorningTimeSelected': isMorningTimeSelected,
      'isEveningTimeSelected': isEveningTimeSelected,
      'popupCount': popupCountController.text,
    };
    await DatabaseService.savePopupSettings(settings);

    // -------------------------------------------------------------------------
    // --- THIS IS THE CORRECTED LOGIC FOR SCHEDULING THE WORKMANAGER TASK ----
    // -------------------------------------------------------------------------
    // Cancel any old tasks to prevent multiple schedules from running
    await Workmanager().cancelAll();

    // Determine the frequency based on selected option
    Duration frequency;
    switch (selectedFrequency) {
      case 'قليل': // Light
        frequency = const Duration(hours: 4);
        break;
      case 'متوسط': // Medium
        frequency = const Duration(minutes: 35);
        break;
      case 'كثيف': // Heavy
        frequency = const Duration(minutes: 10);
        break;
      case 'مخصص': // Custom
        int customHours = int.tryParse(popupCountController.text) ?? 0;
        // The popup count is per day, so we need to calculate the duration per popup
        if (customHours > 0) {
          frequency = Duration(hours: 24 ~/ customHours); // 24 hours divided by the number of popups
        } else {
          // If no custom value or invalid, default to a sensible value
          frequency = const Duration(hours: 2);
        }
        break;
      default:
        frequency = const Duration(hours: 2); // Default to Medium
    }

    // Register the new periodic task to run in the background
    // Removed initialDelay to ensure the task can run immediately on app close
    await Workmanager().registerPeriodicTask(
      "random-event-task",
      "random-event-task",
      frequency: frequency,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
      ),
    );
    print("DEBUG: Periodic task registered with frequency: $frequency");

    // ------------------- END OF CORRECTED LOGIC -----------------------

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الإعدادات بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.08,
              width: double.infinity,
              color: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                children: [
                  // Centered title
                  Center(
                    child: Text(
                      'إعدادات الإشعارات',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Back button positioned on the right
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            // Main content with RTL direction
            Directionality(
              textDirection: TextDirection.rtl,
              child: Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Frequency selection section
                      Text(
                        'اختر عدد النوافذ المنبثقة العشوائية التي ترغب في ظهورها خلال اليوم.',
                        style: TextStyle(
                          fontSize: screenHeight * 0.02,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.025),
                      
                      // Frequency buttons
                      Container(
                        padding: EdgeInsets.all(screenHeight * 0.005),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(screenHeight * 0.03),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: _buildFrequencyButton('قليل', screenHeight)),
                            Expanded(child: _buildFrequencyButton('متوسط', screenHeight)),
                            Expanded(child: _buildFrequencyButton('كثيف', screenHeight)),
                            Expanded(child: _buildFrequencyButton('مخصص', screenHeight)),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.05),
                      
                      // Quiet period section
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(screenHeight * 0.015),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الفترة الهادئة',
                              style: TextStyle(
                                fontSize: screenHeight * 0.025,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            
                            // Toggle switch
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'تعطيل أثناء الدراسة',
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.02,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Switch(
                                  value: isStudyDisabled,
                                  onChanged: (value) {
                                    setState(() {
                                      isStudyDisabled = value;
                                    });
                                  },
                                  activeColor: Colors.orange,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            
                            Text(
                              'حدد أوقات عدم الإزعاج لمنع ظهور النوافذ.',
                              style: TextStyle(
                                fontSize: screenHeight * 0.018,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            
                            // Time ranges
                            _buildTimeRange('نطاق الوقت صباحًا', '08:00 - 12:00', Icons.wb_sunny, screenHeight, screenWidth, isMorningTimeSelected, () {
                              setState(() {
                                isMorningTimeSelected = !isMorningTimeSelected;
                              });
                            }),
                            SizedBox(height: screenHeight * 0.015),
                            _buildTimeRange('نطاق الوقت مساءً', '18:00 - 22:00', Icons.nightlight_round, screenHeight, screenWidth, isEveningTimeSelected, () {
                              setState(() {
                                isEveningTimeSelected = !isEveningTimeSelected;
                              });
                            }),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.05),
                      
                      // Daily pop-up count section
                      Text(
                        'عدد النوافذ يوميًا',
                        style: TextStyle(
                          fontSize: screenHeight * 0.025,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      
                      Container(
                        width: double.infinity,
                        height: screenHeight * 0.06,
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(screenHeight * 0.015),
                          border: Border.all(color: errorText != null ? Colors.red : Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: popupCountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                            height: 1.0,
                          ),
                          decoration: InputDecoration(
                            hintText: 'عدد النوافذ يوميًا',
                            hintStyle: TextStyle(
                              fontSize: screenHeight * 0.018,
                              color: Colors.grey[500],
                              height: 1.0,
                            ),
                            border: InputBorder.none,
                            suffixText: 'مرات يوميًا',
                            suffixStyle: TextStyle(
                              fontSize: screenHeight * 0.016,
                              color: Colors.grey[600],
                              height: 1.0,
                            ),
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onChanged: (value) {
                            setState(() {
                              errorText = _validatePopupCount(value);
                            });
                          },
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      
                      // Error message
                      if (errorText != null)
                        Text(
                          errorText!,
                          style: TextStyle(
                            fontSize: screenHeight * 0.016,
                            color: Colors.red,
                          ),
                        ),
                      
                      SizedBox(height: screenHeight * 0.01),
                      
                      Text(
                        'سيتم توزيع الإشعارات عشوائيًا خلال الفترات المسموح بها.',
                        style: TextStyle(
                          fontSize: screenHeight * 0.018,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Save button at bottom
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.015),
                  ),
                ),
                child: Text(
                  'حفظ الإعدادات',
                  style: TextStyle(
                    fontSize: screenHeight * 0.022,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    popupCountController.dispose();
    super.dispose();
  }

  String? _validatePopupCount(String value) {
    // If empty, use default (no error)
    if (value.isEmpty) {
      return null;
    }
    
    int? count = int.tryParse(value);
    if (count == null) {
      return 'يرجى إدخال رقم صحيح';
    }
    
    if (count <= 0) {
      return 'يجب أن يكون العدد أكبر من صفر';
    }
    
    // Max 130 per day
    if (count > 130) {
      return 'الحد الأقصى 130 نافذة يوميًا';
    }
    
    return null; // No error
  }

  Widget _buildFrequencyButton(String text, double screenHeight) {
    bool isSelected = selectedFrequency == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFrequency = text;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(screenHeight * 0.025),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenHeight * 0.018,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRange(String title, String time, IconData icon, double screenHeight, double screenWidth, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenHeight * 0.02),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.orange : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.orange : Colors.grey[600],
              size: screenHeight * 0.03,
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.orange : Colors.grey[800],
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: screenHeight * 0.018,
                      color: isSelected ? Colors.orange : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            Container(
              width: screenHeight * 0.025,
              height: screenHeight * 0.025,
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.transparent,
                border: Border.all(color: isSelected ? Colors.orange : Colors.grey[400]!, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: screenHeight * 0.018,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
