// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: mission_capture_VIP.sqf

if (!isServer) exitwith {};
#include "sideMissionDefines.sqf"

private [ "_citylist", "_vehicleClass", "_vip", "_vehicle1", "_vehicle2", "_vehicle3", "_waypoint", "_vehicleName", "_numWaypoints"];

_setupVars =
{
	_missionType = "Capture VIP";
	_citylist = [] call cityList;
	_locationsArray = nil; // locations are generated on the fly from towns
};

_setupObjects =
{
	_missionPos = markerPos ((selectRandom _citylist) select 0);
	_vehicleClass = "C_Offroad_01_covered_F";

	_aiGroup = createGroup [GRLIB_side_enemy, true];

	// veh1 + squad
	_vehicle1 = [_missionPos, _vehicleClass, false, false, true] call F_libSpawnVehicle;
	_vehicle1 allowCrewInImmobile [true, true];
	_vehicle1 addEventHandler ["HandleDamage", { private [ "_damage" ]; if ( side (_this select 3) != GRLIB_side_friendly ) then { _damage = 0 } else { _damage = _this select 2 }; _damage }];
	_grp = createGroup [GRLIB_side_enemy, true];
	[_grp, _missionPos, 5, "guard"] call createCustomGroup;
	{ _x moveInAny _vehicle1; [_x] joinSilent _aiGroup } forEach (units _grp);
	(driver _vehicle1) limitSpeed 70;
	sleep 2;

	// veh2 + vip + squad
	_vehicle2 = [_missionPos, _vehicleClass, false, false, true] call F_libSpawnVehicle;
	_vehicle2 allowCrewInImmobile [true, true];
	_vehicle2 addEventHandler ["HandleDamage", { private [ "_damage" ]; if ( side (_this select 3) != GRLIB_side_friendly ) then { _damage = 0 } else { _damage = _this select 2 }; _damage }];
	_vehicle2 setConvoySeparation 30;
	_grp = createGroup [GRLIB_side_enemy, true];
	[_grp, _missionPos, 4, "guard"] call createCustomGroup;
	_vip = _grp createUnit ["O_Officer_Parade_Veteran_F", _missionPos, [], 0, "NONE"];
	_vip addMPEventHandler ["MPKilled", {_this spawn kill_manager}];
	[_vip, false, true] spawn prisonner_ai;
	_vip setrank "COLONEL";
	{ _x moveInAny _vehicle2; [_x] joinSilent _aiGroup } forEach (units _grp);
	sleep 2;

	// veh3 + squad
	_vehicle3 = [_missionPos, _vehicleClass, false, false, true] call F_libSpawnVehicle;
	_vehicle3 allowCrewInImmobile [true, true];
	_vehicle3 addEventHandler ["HandleDamage", { private [ "_damage" ]; if ( side (_this select 3) != GRLIB_side_friendly ) then { _damage = 0 } else { _damage = _this select 2 }; _damage }];
	_vehicle3 setConvoySeparation 30;
	_grp = createGroup [GRLIB_side_enemy, true];
	[_grp, _missionPos, 5, "guard"] call createCustomGroup;
	{ _x moveInAny _vehicle3; [_x] joinSilent _aiGroup } forEach (units _grp);
	sleep 2;	

	_aiGroup setFormation "COLUMN";
	_aiGroup setBehaviour "SAFE";
	_aiGroup setCombatMode "GREEN";
	_aiGroup setSpeedMode "LIMITED";

	// behaviour on waypoints
	while {(count (waypoints _aiGroup)) != 0} do {deleteWaypoint ((waypoints _aiGroup) select 0);};
	{
		_waypoint = _aiGroup addWaypoint [markerPos (_x select 0), 0];
		_waypoint setWaypointType "MOVE";
		_waypoint setWaypointCompletionRadius 100;
		_waypoint setWaypointCombatMode "GREEN";
		_waypoint setWaypointBehaviour "SAFE";
		_waypoint setWaypointFormation "COLUMN";
	} forEach (_citylist call BIS_fnc_arrayShuffle);

	sleep 15;
	_missionPos = getPosATL leader _aiGroup;
	_missionPicture = getText (configFile >> "CfgVehicles" >> (_vehicleClass param [0,""]) >> "picture");
	_vehicleName = getText (configFile >> "CfgVehicles" >> (_vehicleClass param [0,""]) >> "displayName");
	_missionHintText = format ["An important <t color='%1'>V.I.P</t> is travelling the island. Intercept his convoy and capture him <t color='%1'>ALIVE</t>!", sideMissionColor];
	_numWaypoints = count waypoints _aiGroup;
	true;
};

_waitUntilMarkerPos = {getPosATL _vip};
_waitUntilExec = nil;
_waitUntilCondition = {
	if (combatMode _aiGroup != "GREEN") then {
		{ 
			_veh = objectParent _x;
			if (driver _veh == _x) then { doStop _x };
			if (!(isNull _veh) && speed vehicle _veh < 5) then {
				unAssignVehicle _x;
				_x action ["eject", vehicle _x];
				_x action ["getout", vehicle _x];
				[_x] orderGetIn false;
				[_x] allowGetIn false;
				sleep 0.2;
			};
			if (driver _veh == _x) then { _x doFollow (leader _aiGroup) };
		} forEach (units _aiGroup);
		_aiGroup setBehaviour "COMBAT";
		_aiGroup setCombatMode "RED";
	};
	{
		if ((vectorUp _x) select 2 < 0.60) then {
			_x setpos [(getposATL _x) select 0,(getposATL _x) select 1, 0.5];
			_x setVectorUp surfaceNormal position _x;
			sleep 3;
		};
		_veh_leader = vehicle (leader _aiGroup);
		if  (speed _x < 5 && (speed _veh_leader > 5 || _x == _veh_leader) && combatMode _aiGroup != "RED") then {
			_x setFuel 1;
			[_x] execVM "scripts\client\actions\do_unflip.sqf";
			if (_x != _veh_leader) then { (driver _x) doFollow (leader _aiGroup) };
			sleep 10;
		};
	} foreach [_vehicle1, _vehicle2, _vehicle3];
	!(alive _vip) || currentWaypoint _aiGroup >= _numWaypoints;
};
_waitUntilSuccessCondition = { side group _vip == GRLIB_side_friendly };

_failedExec = {
	// Mission failed
	_failedHintMessage = format ["The V.I.P is <br/><t color='%1'>DEAD</t>!!.<br/>We have lost a valuable source of information.<br/><br/>Better luck next time!", sideMissionColor];
	{ deleteVehicle _x } forEach [_vehicle1, _vehicle2, _vehicle3] + (units _aiGroup);
};

_successExec =
{
	// Mission completed
	_successHintMessage = "Congratulation the V.I.P has been captured!<br/>Bring him back to any FOB for interrogation.";
};

_this call sideMissionProcessor;
