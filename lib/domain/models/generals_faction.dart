import 'package:whichgame/core/constants/app_images.dart';
import 'package:whichgame/core/constants/app_strings.dart';

enum GeneralsFaction {
  superweapon,
  airForce,
  laser,
  stealth,
  toxin,
  demolition,
  gla,
  nuke,
  infantry,
  tank;

  String get label => switch (this) {
        GeneralsFaction.superweapon => AppStrings.factionSuperweapon,
        GeneralsFaction.airForce => AppStrings.factionAirForce,
        GeneralsFaction.laser => AppStrings.factionLaser,
        GeneralsFaction.stealth => AppStrings.factionStealth,
        GeneralsFaction.toxin => AppStrings.factionToxin,
        GeneralsFaction.demolition => AppStrings.factionDemolition,
        GeneralsFaction.gla => AppStrings.factionGla,
        GeneralsFaction.nuke => AppStrings.factionNuke,
        GeneralsFaction.infantry => AppStrings.factionInfantry,
        GeneralsFaction.tank => AppStrings.factionTank,
      };

  String get shortLabel => switch (this) {
        GeneralsFaction.superweapon => AppStrings.factionSuperweaponShort,
        GeneralsFaction.airForce => AppStrings.factionAirForceShort,
        GeneralsFaction.laser => AppStrings.factionLaserShort,
        GeneralsFaction.stealth => AppStrings.factionStealthShort,
        GeneralsFaction.toxin => AppStrings.factionToxinShort,
        GeneralsFaction.demolition => AppStrings.factionDemolitionShort,
        GeneralsFaction.gla => AppStrings.factionGlaShort,
        GeneralsFaction.nuke => AppStrings.factionNukeShort,
        GeneralsFaction.infantry => AppStrings.factionInfantryShort,
        GeneralsFaction.tank => AppStrings.factionTankShort,
      };

  String get assetPath => switch (this) {
        GeneralsFaction.superweapon => AppImages.generalsSuperweapon,
        GeneralsFaction.airForce => AppImages.generalsAirForce,
        GeneralsFaction.laser => AppImages.generalsLaser,
        GeneralsFaction.stealth => AppImages.generalsStealth,
        GeneralsFaction.toxin => AppImages.generalsToxin,
        GeneralsFaction.demolition => AppImages.generalsDemolition,
        GeneralsFaction.gla => AppImages.generalsGla,
        GeneralsFaction.nuke => AppImages.generalsNuke,
        GeneralsFaction.infantry => AppImages.generalsInfantry,
        GeneralsFaction.tank => AppImages.generalsTank,
      };
}
