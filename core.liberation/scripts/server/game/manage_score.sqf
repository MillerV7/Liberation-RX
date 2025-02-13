private [ "_cur", "_last", "_msg", "_msg2", "_rank", "_new_rank", "_uid", "_firework" ];

waitUntil { !isNil "GRLIB_player_scores" };
waitUntil { !isNil "save_is_loaded" };

CHG_Perm = {
 params ["_uid", "_perms"];
 {
  if ( _x select 0 == _uid ) exitWith {
	  _x set [1,_perms];
   };
 } foreach GRLIB_permissions;
 publicVariable "GRLIB_permissions";
};

while { true } do {
	{
		_rank = _x getVariable ["GRLIB_Rank", ""];
		if (isPlayer _x && _rank != "") then {
			_cur = score _x;
			_last = _x getVariable["GREUH_score_last",0];
			if (_cur != _last) then {
				// score has changed for player _x

				_uid = getPlayerUID _x;
				_new_rank = [_cur] call get_rank;

				if (_cur <= GRLIB_perm_ban || !([] call F_getValid)) exitWith {
					BTC_logic setVariable [_uid, 99, true];
					[_x] remoteExec ["LRX_tk_actions", owner _x];
					diag_log format ["--- LRX TK: BAN for player %1 - UID: %2", name _x,  _uid];
				};

				if (_new_rank == "None" && _cur < _last) exitWith {
					_msg = format ["Warning <t color='#00ff00'>%1</t> !!<br />You Play Wrong !! <t color='#ff0000'>Read the Manual</t>.<br /><br />%2", name _x, localize "STR_RANK_LVL0"];
					[_msg, 0, 0, 5, 0, 0, 90] remoteExec ["BIS_fnc_dynamicText", owner _x];
					[_uid, [false,false,false,false,false,false]] call CHG_Perm;
					_x setVariable ["GRLIB_Rank", "None", true];
				};

				if (_cur >= 0 && _new_rank != _rank) then {
					// new rank for player _x

					_firework = true;
					switch (_new_rank) do {
						case "Private" : {
							_msg2 = localize "STR_RANK_LVL1";
							[_uid, [true,false,false,true,false,true]] call CHG_Perm;
						};
						case "Corporal" : {
							_msg2 = localize "STR_RANK_LVL2";
							[_uid, [true,true,false,true,false,true]] call CHG_Perm;
						};
						case "Sergeant" : {
							_msg2 = localize "STR_RANK_LVL3";
							[_uid, [true,true,true,true,false,true]] call CHG_Perm;
						};
						case "Captain" : {
							_msg2 = localize "STR_RANK_LVL4";
							[_uid, [true,true,true,true,true,true]] call CHG_Perm;
						};
						case "Major" : {
							_msg2 = localize "STR_RANK_LVL5";
							[_uid, [true,true,true,true,true,true]] call CHG_Perm;
						};
						case "Colonel" : {
							_msg2 = localize "STR_RANK_LVL6";
							[_uid, [true,true,true,true,true,true]] call CHG_Perm;
						};
						case "Super Colonel" : {
							_msg2 = localize "STR_RANK_LVL7";
							[_uid, [true,true,true,true,true,true]] call CHG_Perm;
							_firework = false;
						};
					};

					_msg = format ["Congratulation <t color='#00ff00'>%1</t> !!<br />You have been promoted to : <t color='#ff0000'>%2</t>.<br /><br />%3", name _x,  _new_rank, _msg2];
					[_msg, 0, 0, 5, 0, 0, 90] remoteExec ["BIS_fnc_dynamicText", owner _x];
					["FD_Finish_F"] remoteExec ["playSound", owner _x];

					// set player rank
					[] remoteExec ["set_rank", owner _x];
					_x setVariable ["GRLIB_Rank", _new_rank, true];

					// if rank colonel global greet
					if (_new_rank == "Colonel") then {
						["FD_Finish_F"] remoteExec ["playSound", 0];
						_text = "Good news soldiers...";
						[gamelogic, _text] remoteExec ["globalChat", 0];
						_text = "We have a new Colonel !!";
						[gamelogic, _text] remoteExec ["globalChat", 0];
						_text = format ["Congratulation to %1 for his fight !!", name _x];
						[gamelogic, _text] remoteExec ["globalChat", 0];
						_text = "Over.";
						[gamelogic, _text] remoteExec ["globalChat", 0];
						// fireworks !
						if (_firework) then {
							[getPosATL _x, 'normal','blue'] spawn GRAD_fireworks_fnc_prepareFireworks;
							sleep 2;
							[getPosATL _x, 'normal','white'] spawn GRAD_fireworks_fnc_prepareFireworks;
							sleep 2;
						};
					};

					// fireworks !
					if (_firework) then {
						[getPosATL _x, 'normal','red'] spawn GRAD_fireworks_fnc_prepareFireworks;
					};
				};			
			};
			_x setVariable ["GREUH_score_last", _cur];
		};
	} forEach (AllPlayers - (entities "HeadlessClient_F"));
	sleep 5;
};