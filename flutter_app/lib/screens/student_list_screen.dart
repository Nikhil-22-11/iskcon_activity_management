import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../models/student_model.dart';
import '../utils/constants.dart';
import '../services/qr_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<StudentModel> _students = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();
  List<StudentModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final students = await FirestoreService().getStudents();
      if (mounted) {
        setState(() {
          _students = students;
          _filtered = students;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load students';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _students
          .where((s) =>
              s.name.toLowerCase().contains(query) ||
              (s.email?.toLowerCase().contains(query) ?? false) ||
              (s.phone?.contains(query) ?? false))
          .toList();
    });
  }

  void _showAddStudentDialog([StudentModel? existing]) {
    final nameCtrl =
        TextEditingController(text: existing?.name);
    final emailCtrl =
        TextEditingController(text: existing?.email ?? '');
    final phoneCtrl =
        TextEditingController(text: existing?.phone ?? '');
    final parentCtrl =
        TextEditingController(text: existing?.parentName ?? '');
    final parentPhoneCtrl =
        TextEditingController(text: existing?.parentPhone ?? '');
    final addressCtrl =
        TextEditingController(text: existing?.address ?? '');
    final isEdit = existing != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(isEdit ? Icons.edit : Icons.person_add,
                color: AppColors.krishnaBlue),
            const SizedBox(width: 8),
            Text(isEdit ? 'Edit Student' : 'Add Student'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: parentCtrl,
                decoration: const InputDecoration(labelText: 'Parent Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: parentPhoneCtrl,
                decoration:
                    const InputDecoration(labelText: 'Parent Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              try {
                final data = {
                  'name': nameCtrl.text.trim(),
                  if (emailCtrl.text.isNotEmpty)
                    'email': emailCtrl.text.trim(),
                  if (phoneCtrl.text.isNotEmpty)
                    'phone': phoneCtrl.text.trim(),
                  if (parentCtrl.text.isNotEmpty)
                    'parent_name': parentCtrl.text.trim(),
                  if (parentPhoneCtrl.text.isNotEmpty)
                    'parent_phone': parentPhoneCtrl.text.trim(),
                  if (addressCtrl.text.isNotEmpty)
                    'address': addressCtrl.text.trim(),
                };
                if (isEdit) {
                  final docId = existing.docId;
                  if (docId != null) {
                    await FirestoreService().updateStudent(docId, data);
                  } else {
                    await ApiService().updateStudent(existing.id, data);
                  }
                } else {
                  await FirestoreService().createStudent(data);
                }
                _loadStudents();
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

  void _showStudentDetail(StudentModel student) {
    final qrData = QrService.studentQrData(student);
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
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.krishnaBlue.withAlpha(30),
                child: Text(
                  student.name[0].toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.krishnaBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(student.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              if (student.email != null)
                Text(student.email!,
                    style: const TextStyle(color: AppColors.textSecondary)),
              const Divider(height: 24),
              _detailRow(Icons.phone, 'Phone', student.phone),
              _detailRow(Icons.family_restroom, 'Parent',
                  student.parentName),
              _detailRow(
                  Icons.phone_in_talk, 'Parent Phone', student.parentPhone),
              _detailRow(
                  Icons.location_on, 'Address', student.address),
              const SizedBox(height: 16),
              const Text('Student QR Code',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.krishnaBlue.withAlpha(80)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 180,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0D47A1),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${student.id}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String? value) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.krishnaBlue),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600)),
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
        title: const Text(AppStrings.students),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStudents),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentDialog(),
        backgroundColor: AppColors.krishnaOrange,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('Add Student',
            style: TextStyle(color: AppColors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.krishnaBlue),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch();
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (!_isLoading && !(_error != null))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${_filtered.length} student${_filtered.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ],
      ),
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
                onPressed: _loadStudents, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('No students found',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: _filtered.length,
      itemBuilder: (context, index) => _buildStudentCard(_filtered[index]),
    );
  }

  Widget _buildStudentCard(StudentModel student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showStudentDetail(student),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.krishnaBlue.withAlpha(30),
                child: Text(
                  student.name[0].toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.krishnaBlue,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    if (student.email != null)
                      Text(student.email!,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                    if (student.phone != null)
                      Text(student.phone!,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code,
                        color: AppColors.krishnaBlue),
                    tooltip: 'Show QR Code',
                    onPressed: () => _showStudentDetail(student),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _showAddStudentDialog(student);
                      } else if (value == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Student'),
                            content: Text(
                                'Are you sure you want to delete ${student.name}?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, true),
                                  child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          try {
                            if (student.docId != null) {
                              await FirestoreService().deleteStudent(student.docId!);
                            } else {
                              await ApiService().deleteStudent(student.id);
                            }
                            _loadStudents();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Student deleted'),
                                    backgroundColor: AppColors.success),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
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
                            Icon(Icons.delete,
                                size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ])),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

