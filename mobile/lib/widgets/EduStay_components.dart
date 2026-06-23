import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/theme/EduStay_design.dart';
import '../models/property.dart';

class EduStayIconButton extends StatelessWidget {
  const EduStayIconButton({
    required this.icon,
    required this.onPressed,
    this.badge,
    this.selected = false,
    super.key,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final int? badge;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: selected
                ? EduStayColors.darkGreen
                : Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? EduStayColors.darkGreen : EduStayColors.line),
          ),
          child: IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: EduStayIconSizes.medium,
            color: selected ? Colors.white : EduStayColors.darkGreen,
            onPressed: onPressed,
            icon: Icon(icon),
          ),
        ),
        if ((badge ?? 0) > 0)
          Positioned(
            right: -2,
            top: -2,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.7, end: 1),
              duration: const Duration(milliseconds: 260),
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                    color: EduStayColors.error,
                    borderRadius: BorderRadius.circular(10)),
                child: Text('$badge',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ),
      ],
    );
  }
}

class EduStayPrimaryButton extends StatefulWidget {
  const EduStayPrimaryButton({
    required this.label,
    required this.onPressed,
    this.color = EduStayColors.orange,
    this.loading = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool loading;

  @override
  State<EduStayPrimaryButton> createState() => _EduStayPrimaryButtonState();
}

class _EduStayPrimaryButtonState extends State<EduStayPrimaryButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) => setState(() => pressed = false),
      child: AnimatedScale(
        scale: pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 110),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 54,
          decoration: BoxDecoration(
            color: widget.onPressed == null ? EduStayColors.line : widget.color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: pressed ? [] : EduStayShadows.soft,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: widget.loading ? null : widget.onPressed,
              child: Center(
                child: widget.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(widget.label,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EduStayTextField extends StatelessWidget {
  const EduStayTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
    super.key,
  });
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: EduStayColors.text)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                icon == null ? null : Icon(icon, size: EduStayIconSizes.small),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn(
      {required this.child, this.delay = Duration.zero, super.key});
  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value.clamp(0, 1),
        child: Transform.translate(
            offset: Offset(0, (1 - value) * 18), child: child),
      ),
      child: child,
    );
  }
}

class FigmaPropertyCard extends StatefulWidget {
  const FigmaPropertyCard(
      {required this.property,
      required this.onTap,
      this.onFavorite,
      this.favorite = false,
      super.key});
  final Property property;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool favorite;

  @override
  State<FigmaPropertyCard> createState() => _FigmaPropertyCardState();
}

class _FigmaPropertyCardState extends State<FigmaPropertyCard> {
  bool down = false;

  @override
  Widget build(BuildContext context) {
    final image =
        widget.property.images.isNotEmpty ? widget.property.images.first : null;
    return GestureDetector(
      onTapDown: (_) => setState(() => down = true),
      onTapCancel: () => setState(() => down = false),
      onTapUp: (_) => setState(() => down = false),
      child: AnimatedScale(
        scale: down ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              color: EduStayColors.card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: EduStayShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(14)),
                      child: image == null || image.isEmpty
                          ? Container(
                              height: 162,
                              color: const Color(0xFFEDEDED),
                              child: const Center(
                                  child: Icon(Icons.apartment, size: 52)))
                          : Image.network(
                              image,
                              height: 162,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 162,
                                  color: const Color(0xFFEDEDED),
                                  child: const Center(
                                    child: Icon(Icons.home_work_outlined,
                                        size: 52, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: GestureDetector(
                        onTap: widget.onFavorite,
                        child: AnimatedScale(
                          scale: widget.favorite ? 1.12 : 1,
                          duration: const Duration(milliseconds: 160),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(
                                widget.favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: widget.favorite
                                    ? EduStayColors.error
                                    : EduStayColors.darkGreen,
                                size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(widget.property.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14))),
                          const Icon(Icons.star,
                              color: EduStayColors.orange, size: 16),
                          Text(widget.property.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 15, color: EduStayColors.secondaryText),
                          const SizedBox(width: 3),
                          Expanded(
                              child: Text(widget.property.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: EduStayColors.secondaryText))),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$${widget.property.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: EduStayColors.darkGreen)),
                          const Text('/month',
                              style: TextStyle(
                                  color: EduStayColors.secondaryText,
                                  fontSize: 12)),
                          const Spacer(),
                          Text('(${widget.property.reviewCount} reviews)',
                              style: const TextStyle(
                                  color: EduStayColors.secondaryText,
                                  fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
