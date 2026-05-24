import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _thumbnailController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  bool _isSaving = false;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _apiService.createPost(
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        description: _descController.text.trim(),
        content: _contentController.text.trim(),
        thumbnail: _thumbnailController.text.trim().isEmpty
            ? null
            : _thumbnailController.text.trim(),
        tag: _tagController.text.trim().isEmpty
            ? null
            : _tagController.text.trim(),
      );

      print("===== CREATE POST RESULT =====");
      print("SUCCESS: $success");
      print("==============================");

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng bài viết mới thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi! Không thể đăng bài viết.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e, stack) {
      print("===== UI ERROR =====");
      print(e);
      print(stack);
      print("====================");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Bài Viết Mới'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isSaving
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề bài viết (*)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
                onChanged: (v) {
                  _slugController.text = v
                      .trim()
                      .toLowerCase()
                      .replaceAll(RegExp(r'\s+'), '-');
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _slugController,
                decoration: const InputDecoration(
                  labelText: 'Slug (*)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập slug';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Mô tả ngắn (*)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Vui lòng nhập mô tả ngắn';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _thumbnailController,
                decoration: const InputDecoration(
                  labelText: 'Link ảnh Thumbnail (URL)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Tags (Cách nhau bằng dấu phẩy)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Nội dung chi tiết (HTML/Text)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isSaving ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                ),
                child: _isSaving
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'ĐĂNG BÀI VIẾT',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descController.dispose();
    _contentController.dispose();
    _thumbnailController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}