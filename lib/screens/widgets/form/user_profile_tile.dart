import 'package:ecomerce_app/utils/image_utils.dart';
import 'package:flutter/material.dart';

class UserProfileTile extends StatelessWidget {
  const UserProfileTile({
    super.key,
    required String? linkImage,
  }) : _linkImage = linkImage;

  final String? _linkImage;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: ImageUtils.buildImage(
          _linkImage,
          width: 30,
          height: 30,
        ),
      ),
      title: Text(
        "Nguyễn Hoàng Anh",
        style: Theme.of(
          context,
        ).textTheme.headlineMedium!.copyWith(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        "abc@gmail.com",
        style: Theme.of(
          context,
        ).textTheme.headlineMedium!.copyWith(
          fontSize: 12,
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: Colors.black),
        onPressed: () {},
      ),
    );
  }
}
