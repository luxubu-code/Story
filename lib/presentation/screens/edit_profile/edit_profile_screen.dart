import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:story/core/services/auth_service.dart';
import 'package:story/presentation/screens/edit_profile/widget/avatar_user.dart';
import 'package:story/presentation/screens/edit_profile/widget/body_edit_profile.dart';
import 'package:story/storage/secure_tokenstorage.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final AuthService authService = AuthService();

  // State variables
  String? _avatarUrl;
  File? _imageFile;
  bool _isLoading = false;
  bool _isEditing = false;
  String _email = '';
  DateTime? _creationDate;
  String vip = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final token = await SecureTokenStorage.getToken();
      if (token == null) {
        _showMessage('Vui lòng đăng nhập lại');
        return;
      }

      final user = await authService.fetchUser();
      if (user.isVip) {
        setState(() {
          vip = 'Vip';
        });
      } else {
        vip = 'bình thường ';
      }
      setState(() {
        _nameController.text = user.name;
        _dobController.text = _formatDate(user.date_of_birth);
        _avatarUrl = user.avatar_url;
        _email = user.email;
        _creationDate = user.created_at;
      });
    } catch (e) {
      _showMessage('Không thể tải thông tin: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
    return date.toString();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      _showMessage('Lỗi khi chọn ảnh: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // Chuyển đổi ngày chọn được thành định dạng `YYYY-MM-DD`
      String formattedDate =
          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _dobController.text = formattedDate;
      });
      print("Ngày đã chọn: $formattedDate");
    }
  }

  Future<void> _updateUserAccount() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final token = await SecureTokenStorage.getToken();
      if (token == null) {
        _showMessage('Vui lòng đăng nhập lại');
        return;
      }

      await authService.updateUserAccount(
        token: token,
        name: _nameController.text,
        dateOfBirth: _dobController.text,
        imagePath: _imageFile?.path,
        context: context,
      );

      _showMessage('Cập nhật thông tin thành công');
      setState(() => _isEditing = false);
    } catch (e) {
      _showMessage('Lỗi khi cập nhật: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _validateInputs() {
    if (_nameController.text.isEmpty || _dobController.text.isEmpty) {
      _showMessage('Vui lòng điền đầy đủ thông tin!');
      return false;
    }
    return true;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cập Nhật Thông Tin',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Toggle edit mode
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: AvatarUser(
                        pickImage: _pickImage,
                        imageFile: _imageFile,
                        avataUrl: _avatarUrl,
                        isEditing: _isEditing,
                      ),
                    ),
                    SizedBox(height: 30),
                    BodyEditProfile(
                      nameController: _nameController,
                      dobController: _dobController,
                      isEditing: _isEditing,
                      email: _email,
                      creationDate: _creationDate ?? DateTime.now(),
                      pickDate: _selectDate,
                      vip: vip,
                    ),
                    SizedBox(height: 30),
                    if (_isEditing)
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _updateUserAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Cập Nhật Thông Tin",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
