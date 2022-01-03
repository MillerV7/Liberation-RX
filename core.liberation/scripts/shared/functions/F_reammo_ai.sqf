params ["_unit"];
private _primary_weapon = primaryWeapon _unit;
private _maxpri = 10;           // maximum magazines unit can take (primary weapon)
private _minpri = 6;            // minimal magazines before unit need to reload
private _remove_items = [       // remove all items from inventory
    "R3F_FlashBang_mag"
];

if (_primary_weapon == "") exitWith {};
{ _unit removeMagazines _x} foreach _remove_items;

if ( _primary_weapon find "LMG" >= 0 || _primary_weapon find "MMG" >= 0 || _primary_weapon find "RPK12" >= 0 ) then { _minpri = 1; _maxpri = 3 };
private _needammo1 = [_unit, _primary_weapon, _minpri] call F_UnitNeedAmmo;
if (_needammo1) then {
    _needammo1 = [_unit, _primary_weapon, _maxpri] call F_UnitAddAmmo;
};
