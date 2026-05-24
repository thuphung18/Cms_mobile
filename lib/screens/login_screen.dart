import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'post_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 🎯 BƯỚC 1: Khai báo thêm FocusNode cho ô mật khẩu
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true; // Trạng thái ẩn/hiện mật khẩu

  // Hàm xử lý đăng nhập gọn gàng
  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await _apiService.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        // Đăng nhập thành công -> Chuyển sang danh sách bài viết và xóa màn hình login khỏi danh sách điều hướng
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PostListScreen()),
        );
      }
    } else {
      if (mounted) {
        // Đăng nhập thất bại -> Hiển thị SnackBar báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập thất bại! Sai tài khoản hoặc mật khẩu.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo ứng dụng
                const Text(
                  'TEDU BLOG CMS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Ô nhập Username
                TextFormField(
                  controller: _usernameController,
                  textInputAction: TextInputAction.next, // Bấm Enter trên bàn phím sẽ nhảy sang ô mật khẩu
                  decoration: const InputDecoration(
                    labelText: 'Tên đăng nhập',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên đăng nhập';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ô nhập Password
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode, // 🎯 BƯỚC 2: Gán focusNode vào đây
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done, // Đổi nút bàn phím thành nút Hoàn thành (Done)
                  onFieldSubmitted: (_) => _handleLogin(), // Nhấn nút Done trên bàn phím sẽ tự kích hoạt Đăng nhập
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                        // 🎯 BƯỚC 3: Ép hệ điều hành giữ lại con trỏ chuột và bàn phím ảo ngay sau khi bấm con mắt
                        _passwordFocusNode.requestFocus();
                      },
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Nút bấm Đăng nhập
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'ĐĂNG NHẬP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose(); // 🎯 BƯỚC 4: Giải phóng bộ nhớ focus khi thoát màn hình
    super.dispose();
  }
}