import 'package:flutter/material.dart';

// 1. Component Interface
abstract class PhotoComponent {
  Widget render();
}

// 2. Concrete Component
class BasePhoto implements PhotoComponent {
  final String imageUrl;
  final VoidCallback onTap;

  BasePhoto({required this.imageUrl, required this.onTap});

  @override
  Widget render() {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

// 3. Decorator base
abstract class PhotoDecorator implements PhotoComponent {
  final PhotoComponent component;
  PhotoDecorator(this.component);

  @override
  Widget render() => component.render();
}

// 4a. BorderDecorator
// 4a. BorderDecorator in photo_component.dart
class BorderDecorator extends PhotoDecorator {
  final bool isSelected;
  final Color borderColor;
  final double borderWidth;

  BorderDecorator(
      PhotoComponent component, {
        required this.isSelected,
        this.borderColor = Colors.amber,
        this.borderWidth = 4,
      }) : super(component);

  @override
  Widget render() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? borderColor : Colors.transparent,
          width: borderWidth,
        ),
      ),
      // Use Expand so the image inside also fills the container
      child: component.render(),
    );
  }
}

// 4b. CheckmarkDecorator
class CheckmarkDecorator extends PhotoDecorator {
  final bool isSelected;

  CheckmarkDecorator(PhotoComponent component, {required this.isSelected})
      : super(component);

  @override
  Widget render() {
    if (!isSelected) return component.render();

    return Stack(
      fit: StackFit.expand,
      children: [
        component.render(),
        const Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.amber,
            radius: 12,
            child: Icon(Icons.check, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
