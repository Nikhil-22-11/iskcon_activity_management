import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/activity_model.dart';
import '../utils/constants.dart';

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
      final activities = await ApiService().getActivities();
      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Failed to load activities';
        _isLoading = false;
      });
    }
  }

  void _showAddActivityDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final scheduleCtrl = TextEditingController();
    final teacherCtrl = TextEditingController();
    final capacityCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Activity'),
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
                      labelText: 'Schedule (e.g. Mon 6 PM)')),
              const SizedBox(height: 8),
              TextField(
                  controller: teacherCtrl,
                  decoration: const InputDecoration(labelText: 'Teacher')),
              const SizedBox(height: 8),
              TextField(
                  controller: capacityCtrl,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number),
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
                await ApiService().createActivity({
                  'name': nameCtrl.text.trim(),
                  if (descCtrl.text.isNotEmpty)
                    'description': descCtrl.text.trim(),
                  if (scheduleCtrl.text.isNotEmpty)
                    'schedule': scheduleCtrl.text.trim(),
                  if (teacherCtrl.text.isNotEmpty)
                    'teacher': teacherCtrl.text.trim(),
                  if (capacityCtrl.text.isNotEmpty)
                    'capacity': int.tryParse(capacityCtrl.text),
                });
                _loadActivities();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
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
        onPressed: _showAddActivityDialog,
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
            Icon(Icons.event_outlined, size: 64, color: AppColors.textSecondary),
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
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Activity'),
                          content: Text(
                              'Delete ${activity.name}?'),
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
                          await ApiService().deleteActivity(activity.id);
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
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'delete', child: Text('Delete')),
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
                  _buildChip(
                      Icons.schedule, activity.schedule!, AppColors.krishnaBlue),
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
