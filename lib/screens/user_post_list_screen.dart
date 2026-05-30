import 'package:cms_mobile/screens/post_detail_screen.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class UserPostListScreen extends StatefulWidget {
  const UserPostListScreen({Key? key}) : super(key: key);

  @override
  State<UserPostListScreen> createState() => _UserPostListScreenState();
}

class _UserPostListScreenState extends State<UserPostListScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  PostPagingResult? _pagingResult;
  int _currentPage = 1;

  //  Thay BurnInState thành initState chuẩn vòng đời StatefulWidget
  @override
  void initState() {
    super.initState();
    _fetchPosts(); // Tự động kích hoạt tải dữ liệu khi mở màn hình
  }

  // Hàm gọi API lấy dữ liệu công khai cho User
  Future<void> _fetchPosts({int page = 1}) async {
    setState(() {
      _isLoading = true;
    });

    print("ĐANG GỌI API USER PAGING TẠI TRANG: $page...");

    // Đổi từ getPostsPaging thành getPostPaging cho khớp với ApiService
    final result = await _apiService.getPostsPaging(
      pageIndex: page,
      pageSize: 10,
    );

    if (result != null) {
      print("TẢI DATA USER THÀNH CÔNG! Nhận về: ${result.results.length} bài viết");
    } else {
      print("KẾT QUẢ API TRẢ VỀ NULL (Kiểm tra lại kết nối mạng hoặc lỗi parse JSON)");
    }

    setState(() {
      _pagingResult = result;
      _currentPage = page;
      _isLoading = false; // Tắt vòng xoay loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin Tức Mới Nhất'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        // Thêm các nút bấm chức năng ở góc phải
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
            tooltip: 'Đăng nhập Admin',
            onPressed: () {
              // LỆNH CHUYỂN HƯỚNG SANG MÀN HÌNH ADMIN TẠI ĐÂY
              Navigator.push(
                context,
                MaterialPageRoute(

                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Tính năng vuốt màn hình từ trên xuống để load lại dữ liệu mới nhất
      body: RefreshIndicator(
        onRefresh: () => _fetchPosts(page: 1),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Nếu đang loading lần đầu tiên và chưa có dữ liệu cũ thì hiện vòng xoay
    if (_isLoading && _pagingResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final posts = _pagingResult?.results ?? [];

    // Nếu mảng dữ liệu trống rỗng
    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'Không có bài viết nào hiển thị.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Đổi 'postId' thành 'post.id' để lấy đúng ID của bài viết hiện tại
                  builder: (context) => PostDetailScreen(postId: post.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Khối hiển thị hình ảnh Thumbnail bài viết
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: post.thumbnail != null && post.thumbnail!.isNotEmpty
                        ? Image.network(
                      post.thumbnail!,
                      width: 110,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImage(),
                    )
                        : _buildPlaceholderImage(),
                  ),
                  const SizedBox(width: 12),
                  // Khối thông tin Tiêu đề, Mô tả ngắn và Lượt xem
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.name ?? 'Không có tiêu đề',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          post.description ?? 'Không có mô tả ngắn.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Hàng hiển thị lượt xem mắt đọc
                        Row(
                          children: [
                            Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              '${post.viewCount} lượt xem',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  // Khối ảnh thay thế mặc định nếu bài viết không có ảnh thumbnail
  Widget _buildPlaceholderImage() {
    return Container(
      width: 110,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}