# what will be generated 
```dart
// title is configurable
class AppTheme {
    
}

// title is configurable
class AppColors extends ThemeExtension<AppColors> {
    const AppColors({
        required this.primary,
    });

    final Color primary;
}

class AppTextStyles extends ThemeExtension<AppTextStyles> {
    const AppTextStyles({
        required this.h1,
    });

    final TextStyle h1;
}
```