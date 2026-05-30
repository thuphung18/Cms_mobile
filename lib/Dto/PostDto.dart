import 'package:flutter/material.dart';
class PostDto {
  final String id;
  final String? name;
  final String? slug;
  final String? description;
  final String? thumbnail;
  final String? content; // 📄 Nội dung chi tiết của bài viết
  final int viewCount;
  final String? dateCreatedAt;
  final String? categoryId;
  // hàm khởi tạo
  PostDto({
    required this.id,
    this.name,
    this.slug,
    this.description,
    this.thumbnail,
    this.content,
    this.viewCount = 0,
    this.dateCreatedAt,
    this.categoryId,
  });
  // chuyển đổi sang json
  // trả về 1 chuỗi json dưới dạng Map<String, dynamic>
  factory PostDto.fromJson(Map<String, dynamic> json) {
    return PostDto(
      id: json['id'] ?? '',
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      content: json['content'], // 🔄 Ánh xạ dữ liệu nội dung từ JSON
      viewCount: json['viewCount'] ?? 0,
      dateCreatedAt: json['dateCreatedAt'],
      categoryId: json['categoryId'],
    );
  }
}