import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../models/activity_model.dart';
import '../utils/constants.dart';
import '../services/qr_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  List<ActivityModel> _activities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final activities = await FirestoreService().getActivities();
      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted)
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = 'Failed to load activities';
          _isLoading = false;
        });
    }
  }

  void _showAddActivityDialog([ActivityModel? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name);
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final scheduleCtrl = TextEditingController(text: existing?.schedule ?? '');
    final teacherCtrl = TextEditingController(text: existing?.teacher ?? '');
    final capacityCtrl =
        TextEditingController(text: existing?.capacity?.toString() ?? '');
    final ageGroupCtrl = TextEditingController(text: existing?.ageGroup ?? '');
    final isEdit = existing != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(isEdit ? Icons.edit : Icons.event,
                color: AppColors.krishnaOrange),
            const SizedBox(width: 8),
            Text(isEdit ? 'Edit Activity' : 'Add Activity'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Activity Name *')),
              const SizedBox(height: 8),
              TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2),
              const SizedBox(height: 8),
              TextField(
                  controller: scheduleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Schedule (e.g. Mon 6 AM)')),
              const SizedBox(height: 8),
              TextField(
                  controller: teacherCtrl,
                  decoration: const InputDecoration(labelText: 'Teacher')),
              const SizedBox(height: 8),
              TextField(
                  controller: capacityCtrl,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(
                  controller: ageGroupCtrl,
                  decoration: const InputDecoration(labelText: 'Age Group')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              try {
                final data = {
                  'name': nameCtrl.text.trim(),
                  if (descCtrl.text.isNotEmpty)
                    'description': descCtrl.text.trim(),
                  if (scheduleCtrl.text.isNotEmpty)
                    'schedule': scheduleCtrl.text.trim(),
                  if (teacherCtrl.text.isNotEmpty)
                    'teacher': teacherCtrl.text.trim(),
                  if (capacityCtrl.text.isNotEmpty)
                    'capacity': int.tryParse(capacityCtrl.text),
                  if (ageGroupCtrl.text.isNotEmpty)
                    'age_group': ageGroupCtrl.text.trim(),
                };
                if (isEdit) {
                  final docId = existing.docId;
                  if (docId != null && docId.isNotEmpty) {
                    await FirestoreService().updateActivity(docId, data);
                  } else {
                    // No docId — save as new Firestore doc
                    await FirestoreService().createActivity(data);
                  }
                } else {
                  await FirestoreService().createActivity(data);
                }
                _loadActivities();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showActivityDetail(ActivityModel activity) {
    final qrData = QrService.activityQrData(activity);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.krishnaOrange.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event,
                    color: AppColors.krishnaOrange, size: 32),
              ),
              const SizedBox(height: 12),
              Text(activity.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const Divider(height: 24),
              if (activity.description != null) ...[
                Text(activity.description!,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
              ],
              _row(Icons.schedule, 'Schedule', activity.schedule),
              _row(Icons.person, 'Teacher', activity.teacher),
              _row(Icons.people, 'Capacity', activity.capacity?.toString()),
              _row(Icons.child_care, 'Age Group', activity.ageGroup),
              const SizedBox(height: 16),
              const Text('Activity QR Code',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.deepBlue)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.krishnaOrange.withAlpha(80)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 8),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 180,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFFE65100),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFFFF6F00),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String? value) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.krishnaOrange),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.activities),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _loadActivities),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActivityDialog(),
        backgroundColor: AppColors.krishnaOrange,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('Add Activity',
            style: TextStyle(color: AppColors.white)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.krishnaBlue));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _loadActivities, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_activities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_outlined,
                size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('No activities found',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _activities.length,
      itemBuilder: (context, index) => _buildActivityCard(_activities[index]),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showActivityDetail(activity),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.krishnaOrange.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event,
                        color: AppColors.krishnaOrange, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (activity.teacher != null)
                          Text(
                            'Teacher: ${activity.teacher}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code,
                        color: AppColors.krishnaOrange),
                    tooltip: 'Show QR Code',
                    onPressed: () => _showActivityDetail(activity),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _showAddActivityDialog(activity);
                      } else if (value == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Activity'),
                            content: Text('Delete ${activity.name}?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          try {
                            if (activity.docId != null &&
                                activity.docId!.isNotEmpty) {
                              await FirestoreService()
                                  .deleteActivity(activity.docId!);
                            } else {
                              throw Exception(
                                  'Cannot delete: activity has no Firestore ID');
                            }
                            _loadActivities();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')));
                            }
                          }
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ])),
                      PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ])),
                    ],
                  ),
                ],
              ),
              if (activity.description != null) ...[
                const SizedBox(height: 8),
                Text(activity.description!,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (activity.schedule != null)
                    _buildChip(Icons.schedule, activity.schedule!,
                        AppColors.krishnaBlue),
                  if (activity.capacity != null)
                    _buildChip(Icons.people, 'Cap: ${activity.capacity}',
                        AppColors.krishnaOrange),
                  if (activity.ageGroup != null)
                    _buildChip(Icons.child_care, 'Age: ${activity.ageGroup}',
                        AppColors.success),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
