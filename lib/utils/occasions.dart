// lib/utils/occasions.dart
import 'package:hijri/hijri_calendar.dart';

/// 🔹 المناسبات الهجرية (ترجع مفتاح واحد فقط)
String? getHijriOccasionKey(HijriCalendar h) {
  final m = h.hMonth;
  final d = h.hDay;
  final key = "$m/$d";

  switch (key) {
    case "1/1":
      return "hijriNewYear"; // رأس السنة الهجرية
    case "1/10":
      return "hijriAshura"; // عاشوراء
    case "2/20":
      return "hijriArbaeen"; // أربعينية الحسين
    case "2/28":
      return "hijriProphetDeath"; // وفاة النبي
    case "3/12":
      return "hijriProphetBirthday"; // مولد النبي
    case "7/13":
      return "hijriAliBirthday"; // مولد الإمام علي
    case "7/27":
      return "hijriIsraMiraj"; // الإسراء والمعراج / المبعث
    case "8/15":
      return "hijriMidShaban"; // ليلة النصف من شعبان
    case "9/1":
      return "hijriRamadanStart"; // بداية رمضان
    case "9/17":
      return "hijriBadr"; // غزوة بدر
    case "9/21":
      return "hijriAliMartyrdom"; // استشهاد الإمام علي
    case "10/1":
      return "hijriEidFitr"; // عيد الفطر
    case "12/8":
      return "hijriTarwiyah"; // يوم التروية
    case "12/9":
      return "hijriArafah"; // يوم عرفة
    case "12/10":
      return "hijriEidAdha"; // عيد الأضحى
    case "12/18":
      return "hijriGhadir"; // عيد الغدير
  }
  return null;
}

/// 🔹 المناسبات الميلادية (ترجع لستة مفاتيح لأن اليوم قد يحمل أكثر من حدث)
List<String> getGregorianOccasionKeys(DateTime g) {
  final key =
      "${g.month.toString().padLeft(2, '0')}/${g.day.toString().padLeft(2, '0')}";

  final map = <String, List<String>>{
    "01/01": ["gregNewYear"],
    "01/06": ["gregEpiphany"],
    "01/07": ["gregOrthodoxChristmas"],
    "01/15": ["gregMartinLutherKingBirthday"],
    "02/04": ["gregWorldCancerDay"],
    "02/14": ["gregValentinesDay"],
    "03/08": ["gregInternationalWomensDay"],
    "03/14": ["gregEinsteinBirthday"],
    "03/21": ["gregPoetryDay", "gregNowruz"], // مثال يومين بنفس اليوم
    "04/01": ["gregAprilFools"],
    "04/07": ["gregWorldHealthDay"],
    "04/09": ["gregBaghdadFall2003"],
    "04/12": ["gregYuriGagarin"],
    "04/15": ["gregTitanicSinking"],
    "05/01": ["gregLaborDay"],
    "05/15": ["gregNakba"],
    "06/05": ["gregWorldEnvironmentDay"],
    "06/21": ["gregWorldMusicDay"],
    "07/04": ["gregUSAIndependence"],
    "07/20": ["gregMoonLanding"],
    "08/06": ["gregHiroshima"],
    "08/09": ["gregNagasaki"],
    "09/11": ["greg9_11"],
    "09/21": ["gregPeaceDay"],
    "10/01": ["gregElderlyDay"],
    "10/04": ["gregSputnik"],
    "10/16": ["gregFoodDay"],
    "11/09": ["gregBerlinWallFall"],
    "11/11": ["gregWW1End"],
    "12/01": ["gregWorldAidsDay"],
    "12/10": ["gregHumanRightsDay"],
    "12/25": ["gregChristmas", "gregNewtonBirthday"],
    "12/31": ["gregNewYearsEve"],
  };

  return map[key] ?? [];
}
