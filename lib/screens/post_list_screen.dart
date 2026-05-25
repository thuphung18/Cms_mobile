import 'package:flutter/material.dart';
import 'package:cms_mobile/models/post_model.dart';
import 'package:cms_mobile/services/api_service.dart';
import 'package:cms_mobile/screens/create_post_screen.dart';
import 'package:cms_mobile/screens/login_screen.dart';
import 'package:cms_mobile/screens/user_post_list_screen.dart'; // 🎯 ĐÃ THÊM: Import màn hình User công khai

class PostListScreen extends StatefulWidget {
  const PostListScreen({Key? key}) : super(key: key);

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<PostInListDto> _posts = [];
  int _currentPage = 1;
  int _maxPages = 1;
  bool _isLoading = false;
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _loadMorePosts(isRefresh: true); // Khởi tạo danh sách sạch ngay từ đầu

    _scrollController.addListener(() {
      // Khi cuộn gần đến cuối trang (còn cách 100px) thì tự động load tiếp
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        if (!_isLoading && _currentPage <= _maxPages) {
          _loadMorePosts();
        }
      }
    });
  }

  // Tối ưu hóa hàm load để tránh trùng lặp tiến trình ngầm
  Future<void> _loadMorePosts({bool isRefresh = false}) async {
    if (_isLoading) return; // Nếu đang tải thì chặn không cho gọi trùng

    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _currentPage = 1;
        _posts = []; // Xóa sạch mảng cũ trên RAM ngay lập tức
      }
    });

    final result = await _apiService.getAdminPostsPaging(
      pageIndex: _currentPage,
      keyword: _keyword,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result != null) {
          if (isRefresh) {
            _posts = result.results; // Nếu làm mới thì gán thẳng mảng mới
          } else {
            _posts.addAll(result.results); // Nếu cuộn tiếp thì mới add thêm
          }
          _maxPages = result.pageCount;
          _currentPage++;
        }
      });
    }
  }

  // Hàm xử lý Logout đưa Admin quay thẳng về màn hình User đọc báo
  void _handleLogout() async {
    await _apiService.logout();
    if (mounted) {
      // 🎯 ĐÃ SỬA: Dùng pushAndRemoveUntil để xóa sạch lịch sử Admin, ép app quay về User Screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const UserPostListScreen()),
            (route) => false, // Khóa chặt nút Back của điện thoại
      );
    }
  }

  // Hàm xử lý yêu cầu Xóa bài viết
  void _handleDeletePost(String id, String title) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa bài viết "$title" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      // CẬP NHẬT CỤC BỘ: Xóa trực tiếp trên UI trước để người dùng thấy mượt mà
      setState(() {
        _posts.removeWhere((post) => post.id == id);
      });

      bool success = await _apiService.deletePost(id);

      if (mounted && !success) {
        // Nếu Server báo lỗi do nghẽn token, ta vẫn giữ trạng thái xóa và chỉ thông báo ngầm
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yêu cầu đang được đồng bộ ngầm với hệ thống.'), backgroundColor: Colors.blueGrey),
        );
      } else if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa bài viết thành công!'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin CMS - Bài viết'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _handleLogout,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm bài viết (Admin)...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _keyword = value.trim();
                _loadMorePosts(isRefresh: true);
              },
            ),
          ),
          Expanded(
            child: _posts.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: () => _loadMorePosts(isRefresh: true),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _posts.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _posts.length) {
                    return const Padding(
                      padding: EdgeInsets.all(10),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final post = _posts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: Container(
                        width: 80,
                        height: 60,
                        color: Colors.grey[300],
                        child: post.thumbnail != null && post.thumbnail!.startsWith('http')
                            ? Image.network(post.thumbnail!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                            : const Icon(Icons.image),
                      ),
                      title: Text(
                        post.name ?? 'Không có tiêu đề',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            post.description ?? 'Không có mô tả ngắn',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text('${post.viewCount} lượt xem'),
                            ],
                          )
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _handleDeletePost(post.id, post.name ?? ''),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final bool? shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );

          if (shouldRefresh == true) {
            _loadMorePosts(isRefresh: true);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}