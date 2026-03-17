import '../models/student_model.dart';
import '../models/activity_model.dart';
import '../models/visitor_model.dart';

class QrService {
  static String studentQrData(StudentModel student) {
    return 'ISKCON-STUDENT|id:${student.id}|name:${student.name}'
        '${student.phone != null ? '|phone:${student.phone}' : ''}';
  }

  static String activityQrData(ActivityModel activity) {
    return 'ISKCON-ACTIVITY|id:${activity.id}|name:${activity.name}'
        '${activity.schedule != null ? '|schedule:${activity.schedule}' : ''}';
  }

  static String visitorQrData(VisitorModel visitor) {
    return 'ISKCON-VISITOR|id:${visitor.id}|name:${visitor.visitorName}'
        '${visitor.visitorPhone != null ? '|phone:${visitor.visitorPhone}' : ''}';
  }
}
