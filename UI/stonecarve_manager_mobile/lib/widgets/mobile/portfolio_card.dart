import 'package:flutter/material.dart';
import 'package:stonecarve_manager_mobile/models/product.dart';

class PortfolioCard extends StatelessWidget {
  final Product project;
  final VoidCallback? onTap;

  const PortfolioCard({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryImage = project.images?.isNotEmpty == true
        ? project.images!.first.imageUrl
        : null;

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: primaryImage != null
                      ? Image.network(
                          primaryImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 48,
                            );
                          },
                        )
                      : Icon(Icons.image, color: Colors.grey[400], size: 48),
                ),
              ),
            ),

            // Project Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    project.name ?? 'Unnamed Project',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (project.categoryName != null)
                    Text(
                      project.categoryName!,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (project.materialName != null)
                    Text(
                      project.materialName!,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (project.dimensions != null)
                    Text(
                      project.dimensions!,
                      style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (project.completionYear != null)
                    Text(
                      project.completionYear.toString(),
                      style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
