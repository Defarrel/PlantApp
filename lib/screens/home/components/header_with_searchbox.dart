import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plantapp/constant.dart';
import 'package:plantapp/screens/home/components/camera_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantapp/screens/home/components/storage_helper.dart';

class HeaderWithSearchBox extends StatefulWidget {
  const HeaderWithSearchBox({super.key, required this.size});

  final Size size;

  @override
  State<HeaderWithSearchBox> createState() => _HeaderWithSearchBoxState();
}

class _HeaderWithSearchBoxState extends State<HeaderWithSearchBox> {
  File? _profileImage;

  Future<void> _navigateToCamera() async {
    final image = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );

    if (image != null && image is File) {
      final savedFile = await StorageHelper.saveImage(image, "camera_");
      setState(() {
        _profileImage = savedFile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto berhasil disimpan dari kamera!')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final originalFile = File(pickedFile.path);
      final savedFile = await StorageHelper.saveImage(originalFile, "gallery_");
      setState(() {
        _profileImage = savedFile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto berhasil disalin dari galeri!')),
      );
    }
  }

  void _showProfileOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 8, 0),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 10,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Ubah Foto Profil"),
                IconButton(
                  icon: const Icon(Icons.close, color: Color.fromARGB(255, 0, 0, 0)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            content: const Text("Pilih sumber untuk foto profil Anda."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToCamera();
                },
                child: const Text(
                  "Buka Kamera",
                  style: TextStyle(color: kPrimaryColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
                child: const Text(
                  "Pilih dari Galeri",
                  style: TextStyle(color: kPrimaryColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _profileImage = null;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto profil dihapus.')),
                  );
                },
                child: const Text(
                  "Hapus Foto",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: kDefaultPadding * 2.5),
      height: widget.size.height * 0.2,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: kDefaultPadding,
              right: kDefaultPadding,
              bottom: 36 + kDefaultPadding,
            ),
            height: widget.size.height * 0.2 - 27,
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  "Hi Gloydius!",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _showProfileOptions,
                  child: Container(
                    width: 85,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image:
                            _profileImage != null
                                ? FileImage(_profileImage!)
                                : const AssetImage("assets/images/logo.png")
                                    as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
              padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 10),
                    blurRadius: 50,
                    color: kPrimaryColor.withAlpha(23),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {},
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(
                          color: kPrimaryColor.withOpacity(0.5),
                        ),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  SvgPicture.asset("assets/icons/search.svg"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
