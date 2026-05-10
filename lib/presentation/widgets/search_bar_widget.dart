import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cafescope_sby/app/theme/app_colors.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const SearchBarWidget({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Cari kafe...',
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.mutedForeground,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.primary,
          size: 20,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onChanged('');
                },
                child: Icon(
                  Icons.close,
                  color: AppColors.mutedForeground,
                  size: 20,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.input,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.foreground,
      ),
      onChanged: widget.onChanged,
    );
  }
}