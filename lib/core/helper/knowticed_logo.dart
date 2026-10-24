/// The Knowticed logo for the current theme — ONE choice for every page, so a
/// phone and a tablet can never pick opposite files (Moataz 23/10/2026).
library;

String knowticedLogoAsset({required bool lightMode}) => lightMode
    ? 'assets/icons_assets/main_icons_assets/logo_knowticed.svg'
    : 'assets/icons_assets/main_icons_assets/logo_knowticed_badge_light.svg';
