params ["_unit"];
private _kill = BTC_logic getVariable [getPlayerUID player, 0];

if (!isNil "_unit") then {
	private _msg = format [localize "STR_TK_INFO2", name _unit];
	[_msg, 0, 0, 5, 0, 0, 90] spawn BIS_fnc_dynamicText;
	sleep 5;
};

switch (true) do {
	case (_kill < GRLIB_tk_count) : {
		waitUntil {!(isNull (findDisplay 46))};
		private _msg = "STOP TEAMKILLING !!";
		[_msg, 0, 0, 5, 0, 0, 90] spawn BIS_fnc_dynamicText;
	};

	case (_kill == GRLIB_tk_count) : {
		waitUntil {!(isNull (findDisplay 46))};
		private _msg = format ["STOP TEAMKILLING, <t color='#ff0000'>LAST WARNING...</t>"];
		[_msg, 0, 0, 5, 0, 0, 90] spawn BIS_fnc_dynamicText;
	};

	case (_kill > GRLIB_tk_count) : {
		closeDialog 0;
		closeDialog 0;
		closeDialog 0;
		GRLIB_introduction = false;
		cinematic_camera_started = false;
		sleep 1;
		player enableSimulationGlobal false;
		player setpos [0,0,0];
		waitUntil {!(isNull (findDisplay 46))};
		createDialog "deathscreen";
		waitUntil { dialog };
		disableUserInput true;
		ctrlSetText [4867, "YOU HAVE BEEN BANNED"];
		sleep 3;
		ctrlSetText [4867, "FOR BAD GAMING..."];
		sleep 3;
		ctrlSetText [4867, "...YOU ARE NOT"];
		sleep 3;
		ctrlSetText [4867, "WELCOME ANYMORE."];
		sleep 3;
		ctrlSetText [4867, ""];
		sleep 3;
		disableUserInput false;
		disableUserInput true;
		disableUserInput false;
		endMission "LOSER";
		sleep 300;
	};
};