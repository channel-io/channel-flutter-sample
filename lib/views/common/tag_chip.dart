import 'package:flutter/material.dart';

/// Common Chip widget for displaying tags
class TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback? onDeleted;
  final bool isDeleteEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? deleteIconColor;

  const TagChip({
    super.key,
    required this.tag,
    this.onDeleted,
    this.isDeleteEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.deleteIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      label: Text(
        tag,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: backgroundColor ?? theme.primaryColor,
      deleteIcon: isDeleteEnabled && onDeleted != null
          ? Icon(
              Icons.close,
              size: 16,
              color: deleteIconColor ?? Colors.white70,
            )
          : null,
      onDeleted: isDeleteEnabled ? onDeleted : null,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor:
          backgroundColor?.withValues(alpha: 0.3) ??
          theme.primaryColor.withValues(alpha: 0.3),
    );
  }
}

/// + button Chip for adding tags
class AddTagChip extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final String? tooltip;

  const AddTagChip({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final chip = ActionChip(
      label: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 16, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Add Tag',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onPressed: isEnabled ? onPressed : null,
      backgroundColor: isEnabled ? Colors.green : Colors.grey,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.green.withValues(alpha: 0.3),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: chip);
    }

    return chip;
  }
}

/// Widget that displays tag list using Wrap
class TagChipList extends StatelessWidget {
  final List<String> tags;
  final Function(String)? onTagDeleted;
  final VoidCallback? onAddTag;
  final bool isDeleteEnabled;
  final bool isAddEnabled;
  final String? emptyMessage;
  final double spacing;
  final double runSpacing;

  const TagChipList({
    super.key,
    required this.tags,
    this.onTagDeleted,
    this.onAddTag,
    this.isDeleteEnabled = true,
    this.isAddEnabled = true,
    this.emptyMessage,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        // Existing tags
        ...tags.map(
          (tag) => TagChip(
            tag: tag,
            onDeleted: isDeleteEnabled && onTagDeleted != null
                ? () => onTagDeleted!(tag)
                : null,
            isDeleteEnabled: isDeleteEnabled,
          ),
        ),

        // Add tag button (always displayed)
        if (isAddEnabled && onAddTag != null)
          AddTagChip(
            onPressed: onAddTag,
            isEnabled: isAddEnabled,
            tooltip: 'Add new tag',
          ),
      ],
    );
  }
}
