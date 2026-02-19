const iconPath = 'assets/icons/';
const imagePath = 'assets/images/';
const configPath = 'assets/config/';

final String appIcon = 'app-icon'.png;

final sunflowerIcon = 'assets/sunflower_icon.png';

extension ImageExtension on String {
  String get svg => '$iconPath$this.svg';
  String get png => '$imagePath$this.png';
}
