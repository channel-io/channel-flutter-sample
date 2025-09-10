import 'package:flutter/material.dart';
import 'boot_required_mixin.dart';
import 'snackbar_helper.dart';

/// Common expansion tile with boot status checking
class SectionExpansionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String Function(bool) subtitleBuilder;
  final bool isBooted;
  final String bootRequiredMessage;
  final List<Widget> children;
  final bool requiresBoot;

  const SectionExpansionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitleBuilder,
    required this.isBooted,
    required this.bootRequiredMessage,
    required this.children,
    this.requiresBoot = false,
  });

  @override
  State<SectionExpansionTile> createState() => _SectionExpansionTileState();
}

class _SectionExpansionTileState extends State<SectionExpansionTile>
    with BootRequiredMixin {
  bool _isExpanded = false;

  @override
  void didUpdateWidget(SectionExpansionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update expansion state when boot status changes
    if (oldWidget.isBooted != widget.isBooted && !widget.isBooted) {
      // If booted state is released, collapse the section
      setState(() {
        _isExpanded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(widget.icon, color: getStatusColor(widget.isBooted)),
      title: Text(
        widget.title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(widget.subtitleBuilder(widget.isBooted)),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (expanded) {
        if (expanded && widget.requiresBoot && !widget.isBooted) {
          // Show warning message and prevent expansion when not booted
          SnackBarHelper.showWarning(context, widget.bootRequiredMessage);
        } else {
          // Allow expansion
          setState(() {
            _isExpanded = expanded;
          });
        }
      },
      children: widget.isBooted || !widget.requiresBoot
          ? [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.children,
                ),
              ),
            ]
          : [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    widget.bootRequiredMessage,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
    );
  }
}
