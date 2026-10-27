import 'dart:io';

import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// Grid pemilih foto standar CampuShift untuk 2–3 foto barang (BR-01, Section 4.3).
class PhotoPickerGrid extends StatelessWidget {
  const PhotoPickerGrid({
    super.key,
    required this.imageCount,
    required this.onPick,
    this.maxPhotos = 3,
    this.minPhotos = 2,
    this.imageFiles,
    this.onRemoveAt,
  });

  final int imageCount;
  final int maxPhotos;
  final int minPhotos;
  final VoidCallback onPick;
  final List<File>? imageFiles;
  final ValueChanged<int>? onRemoveAt;

  @override
  Widget build(BuildContext context) {
    final hasEnoughPhotos = imageCount >= minPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Foto Fisik Barang',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$imageCount dari $maxPhotos foto (Min. $minPhotos)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: hasEnoughPhotos ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageCount < maxPhotos ? imageCount + 1 : imageCount,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index < imageCount &&
                  imageFiles != null &&
                  index < imageFiles!.length) {
                return Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.medium,
                        border: Border.all(color: AppColors.outline),
                        image: DecorationImage(
                          image: FileImage(imageFiles![index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (onRemoveAt != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => onRemoveAt!(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }

              // Tombol Tambah Foto
              return InkWell(
                onTap: onPick,
                borderRadius: AppRadius.medium,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: AppRadius.medium,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 26,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tambah',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
