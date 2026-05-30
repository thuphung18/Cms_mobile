import 'package:cms_mobile/Dto/PostDto.dart';
import 'package:cms_mobile/services/api_service.dart';
import 'package:flutter/material.dart';
import "package:flutter_widget_from_html/flutter_widget_from_html.dart";

class PostDetailScreen extends StatefulWidget{
  // khai báo final để lưu trữ postId
  final String postId;
  final bool isAdmin;
  // tạo constructor nhận postId qia từ khóa required
  // nếu không có gì thay đổi mặc định là user đang đọc
  const PostDetailScreen({super.key,required this.postId, this.isAdmin=false});
  @override
  State<PostDetailScreen> createState()=> _PostDetailScreenState();

}
class _PostDetailScreenState extends State<PostDetailScreen>{
  final ApiService _apiService=ApiService();
  bool _isloading=true;
  // khai báo biến lưu dữ liệu bài viết
  PostDto? _postDto;
  @override
  // trong initState không được có async
  //=> async đặt ở _fetchPostDetail
  void initState()
  {
    super.initState();
    // tự động gọi hàm tải dữ liệu
    _fetchPostDetail();
  }
  // gọi api từ apiservice
  void _fetchPostDetail() async {
    // Kiểm tra: Nếu là admin thì gọi hàm Admin API, ngược lại gọi Public API
    final result = widget.isAdmin
        ? await _apiService.getAdminPostById(widget.postId)  // Endpoint Admin (Không tăng view)
        : await _apiService.getPostById(widget.postId);       // Endpoint Public (Có tăng view)

    if (mounted) {
      setState(() {
        _postDto = result;
        _isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //Trạng thái đang tải dữ liệu
    if (_isloading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Trạng thái lỗi hoặc không tìm thấy bài viết
    if (_postDto == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy bài viết')),
      );
    }

    //Trạng thái hiển thị dữ liệu thành công
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bài viết'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Tiêu đề bài viết
            Text(
              _postDto!.name ?? 'Không có tiêu đề',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Lượt xem
            Row(
              children: [
                const Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text('${_postDto!.viewCount} lượt xem'),
              ],
            ),
            const SizedBox(height: 20),

            //Ảnh đại diện (Thumbnail)
            if (_postDto!.thumbnail != null && _postDto!.thumbnail!.startsWith('http'))
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(_postDto!.thumbnail!, fit: BoxFit.cover),
              ),
            const SizedBox(height: 20),

            //Nội dung chi tiết bài viết
            Text(
              _postDto!.content ?? 'Không có nội dung',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }}