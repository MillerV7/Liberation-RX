params ["_unit", "_pos"];
private [ "_backpack", "_backpackcontents", "_is_mobilerespawn" ];

_unit allowDamage false;
_backpack = backpack _unit;
if ( _backpack != "" && _backpack != "B_Parachute" ) then {
	_is_mobilerespawn = (backpackContainer _unit) getVariable ["GRLIB_mobile_respawn_bag", false];
	_backpackcontents = backpackItems _unit;
	removeBackpack _unit;
	sleep 0.1;
};
_unit addBackpack "B_Parachute";
_unit setpos _pos vectorAdd [floor(random 20), floor(random 20), 0];
sleep 3;
_unit allowDamage true;
halojumping = false;

while {alive _unit && !isTouchingGround _unit} do {
	if ((getPosATL _unit) select 2 <= 50 && !(isPlayer _unit)) then {_unit allowDamage false};
	sleep 0.5;
};
removeBackpack _unit;
sleep 0.1;
if ( _backpack != "" && _backpack != "B_Parachute" ) then {
	_unit addBackpack _backpack;
	clearAllItemsFromBackpack _unit;
	{_unit addItemToBackpack _x} foreach _backpackcontents;
	if (_is_mobilerespawn) then {
		(backpackContainer _unit) setVariable ["GRLIB_mobile_respawn_bag", true, true];
	};
};
_unit allowDamage true;
_unit doFollow leader player;
