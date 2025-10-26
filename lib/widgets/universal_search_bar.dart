import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class UniversalSearchBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? controller;
  final bool showBackButton;

  const UniversalSearchBar({
    super.key,
    this.controller,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final TextEditingController textController =
        controller ?? TextEditingController();

    return AppBar(
      automaticallyImplyLeading: showBackButton,
      backgroundColor: const Color(0xFFB8E5E5),
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                onChanged: (query) =>
                    productProvider.searchProducts(query.trim()),
                decoration: InputDecoration(
                  hintText: "Search or ask a question",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_outlined),
                      SizedBox(width: 8),
                      Icon(Icons.mic_none),
                      SizedBox(width: 8),
                      Icon(Icons.qr_code_scanner),
                      SizedBox(width: 8),
                    ],
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
