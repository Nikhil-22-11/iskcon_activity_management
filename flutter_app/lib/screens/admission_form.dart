import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class AdmissionForm extends StatefulWidget {
  const AdmissionForm({super.key});

  @override
  State<AdmissionForm> createState() => _AdmissionFormState();
}

class _AdmissionFormState extends State<AdmissionForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _motherPhoneCtrl = TextEditingController();
  final _fatherPhoneCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _transactionIdCtrl = TextEditingController();

  // Selected values
  DateTime? _dob;
  String _gender = 'Male';
  String _hearAboutUs = 'Friends';
  String _paymentPeriod = 'Monthly';
  String _paymentMode = 'Cash';

  static const _genders = ['Male', 'Female', 'Other'];
  static const _hearOptions = ['Friends', 'Social Media', 'Posters', 'Events'];
  static const _paymentPeriods = ['Monthly', 'Quarterly', 'Yearly'];
  static const _paymentModes = ['Cash', 'Online'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _motherPhoneCtrl.dispose();
    _fatherPhoneCtrl.dispose();
    _schoolCtrl.dispose();
    _transactionIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2012),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
    );
    if (picked != null && mounted) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Date of Birth'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final data = {
        'student_name': _nameCtrl.text.trim(),
        'mother_contact': _motherPhoneCtrl.text.trim(),
        'father_contact': _fatherPhoneCtrl.text.trim(),
        'dob': _dob!.toIso8601String().split('T').first,
        'school': _schoolCtrl.text.trim(),
        'gender': _gender,
        'hear_about_us': _hearAboutUs,
        'payment_period': _paymentPeriod,
        'payment_mode': _paymentMode,
        if (_paymentMode == 'Online')
          'transaction_id': _transactionIdCtrl.text.trim(),
      };
      await FirestoreService().submitAdmission(data);
      if (!mounted) return;
      _showSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccess() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 28),
            ),
            const SizedBox(width: 12),
            const Text('Admission Submitted!'),
          ],
        ),
        content: Text(
          'Student "${_nameCtrl.text.trim()}" has been successfully admitted.\n\n'
          'Payment: $_paymentPeriod – $_paymentMode',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetForm();
            },
            child: const Text('New Admission'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameCtrl.clear();
    _motherPhoneCtrl.clear();
    _fatherPhoneCtrl.clear();
    _schoolCtrl.clear();
    _transactionIdCtrl.clear();
    setState(() {
      _dob = null;
      _gender = 'Male';
      _hearAboutUs = 'Friends';
      _paymentPeriod = 'Monthly';
      _paymentMode = 'Cash';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        title: const Text('Student Admission'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Personal Details', Icons.person),
              const SizedBox(height: 12),
              _buildCard([
                _textField(
                  controller: _nameCtrl,
                  label: 'Student Name',
                  hint: 'Enter full name',
                  icon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                _phoneField(
                  controller: _motherPhoneCtrl,
                  label: "Mother's Contact No",
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 16),
                _phoneField(
                  controller: _fatherPhoneCtrl,
                  label: "Father's Contact No",
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 16),
                _dateField(),
                const SizedBox(height: 16),
                _textField(
                  controller: _schoolCtrl,
                  label: 'School',
                  hint: 'Enter school name',
                  icon: Icons.school_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'School is required' : null,
                ),
                const SizedBox(height: 16),
                _dropdownField(
                  label: 'Gender',
                  icon: Icons.wc_outlined,
                  value: _gender,
                  items: _genders,
                  onChanged: (v) => setState(() => _gender = v!),
                ),
              ]),
              const SizedBox(height: 20),
              _sectionHeader('How Did You Hear About Us?', Icons.info_outline),
              const SizedBox(height: 12),
              _buildCard([
                _dropdownField(
                  label: 'Source',
                  icon: Icons.campaign_outlined,
                  value: _hearAboutUs,
                  items: _hearOptions,
                  onChanged: (v) => setState(() => _hearAboutUs = v!),
                ),
              ]),
              const SizedBox(height: 20),
              _sectionHeader('Payment Details', Icons.payment),
              const SizedBox(height: 12),
              _buildCard([
                _radioGroup(
                  label: 'Payment Period',
                  options: _paymentPeriods,
                  value: _paymentPeriod,
                  onChanged: (v) => setState(() => _paymentPeriod = v),
                ),
                const Divider(height: 24),
                _radioGroup(
                  label: 'Payment Mode',
                  options: _paymentModes,
                  value: _paymentMode,
                  onChanged: (v) => setState(() => _paymentMode = v),
                ),
                if (_paymentMode == 'Online') ...[
                  const SizedBox(height: 16),
                  _textField(
                    controller: _transactionIdCtrl,
                    label: 'Transaction ID',
                    hint: 'Enter transaction ID',
                    icon: Icons.receipt_long_outlined,
                    validator: (v) {
                      if (_paymentMode == 'Online' && (v == null || v.trim().isEmpty)) {
                        return 'Transaction ID is required for Online payment';
                      }
                      return null;
                    },
                  ),
                ],
              ]),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.krishnaBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Admission',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.krishnaBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.krishnaBlue, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _phoneField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
      validator: (v) {
        if (v == null || v.trim().isEmpty) return '$label is required';
        if (v.trim().length != 10) return 'Enter a valid 10-digit number';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: '10-digit mobile number',
        prefixIcon: Icon(icon, color: AppColors.krishnaBlue, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: const Icon(Icons.calendar_today_outlined, color: AppColors.krishnaBlue, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          errorText: null,
        ),
        child: Text(
          _dob == null
              ? 'Select date of birth'
              : '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}',
          style: TextStyle(
            fontSize: 16,
            color: _dob == null ? Colors.grey.shade500 : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.krishnaBlue, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }

  Widget _radioGroup({
    required String label,
    required List<String> options,
    required String value,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          children: options.map((option) {
            return InkWell(
              onTap: () => onChanged(option),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: value == option
                      ? AppColors.krishnaBlue
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: value == option
                        ? AppColors.krishnaBlue
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: value == option ? Colors.white : AppColors.textPrimary,
                    fontWeight: value == option ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
