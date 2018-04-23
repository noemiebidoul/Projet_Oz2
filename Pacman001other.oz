%% Pacman 000 other %%
functor
import
  Input
  Browser
  OS
export
  portPlayer:StartPlayer
define   
  StartPlayer
  TreatStream
	Spawn
	NG
	Find
	North
	South
	East
	West
	UpdateStatus
	UpdateStrat
	UpdateStratG
	Walkable
	Move
in

%%%%%%%%%%%%%%%%%%%
%%% DEFINITIONS %%%
%%%%%%%%%%%%%%%%%%%

	% We define here the following types :
	% <status> ::= status(p:<position> life:<lives> score:<score> m:<mode>)
	% <score> ::= 0|1|2|...
	% <strat> ::= strat(target:<position> priority:<prior> avoid:<surrounding>)
	% <prior> ::= 0 (no strategy)|1 (point)|2 (bonus)|3 (ghost in hunt mode)
	% <surrounding> ::= dir(n:<flee> s:<flee> e:<flee> w:<flee>)
	% <flee> ::= <IDnumG>|Input.NbGhost+1


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% NAVIGATION ON THE MAP %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Returns the type of point (0, 1, 2, 3 or 4) at <position> Position
	fun{Find Position}
		Row
		Col
	in
		fun{Col C N P}
			case C of nil then 1
			[] H|T then
				if N == P.y then H
				else {Col C N+1 P}
				end
		end
		fun{Row R M P}
			case R of nil then 1
			[] H|T then
				if M == P.x then {Col H 1 P}
				else {Row T M+1 P}
				end
			end
		end
		{Row Input.Map 1 Position}
	end

	% Returns the <position> north of <position> P
	fun{North P}
		if(P.y == 1) then pt(x:P.x y:Input.NRow)
		else pt(x:P.x y:P.y-1)
		end
	end

	% Returns the <position> south of <position> P
	fun{South P}
		if(P.y == Input.NRow) then pt(x:P.x y:1)
		else pt(x:P.x y:P.y+1)
		end
	end

	% Returns the <position> east of <position> P
	fun{East P}
		if(P.x == Input.NColumn) then pt(x:1 y:P.y)
		else pt(x:P.x+1 y:P.y)
		end
	end

	% Returns the <position> west of <position> P
	fun{West P}
		if(P.x == 1) then pt(x:Input.NColumn y:P.y)
		else pt(x:P.x-1 y:P.y)
		end
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% UPDATES OF PACMAN STATUS AND STRATEGY %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% status is a record that stores the <position>, the remainig lives,
	% the current score and the <mode>
	fun{UpdateStatus Position Life Score Mode}
		status(p:Position life:Life score:Score m:Mode)
	end

	% Update the target of the strategy only i:Input.NbGhost+1)f the priority is
	% greater than the current target's priority and if the position
	% is next to the pacman
	fun{UpdateStrat Position S P Priority}
		if(Priority > S.priority) then
			if P == {North Position} then strat(target:P priority:Priority avoid:S.avoid)
			elseif P == {South Position} then strat(target:P priority:Priority avoid:S.avoid)
			elseif P == {East Position} then strat(target:P priority:Priority avoid:S.avoid)
			elseif P == {West Position} then strat(target:P priority:Priority avoid:S.avoid)
			else S
			end
		else S 
		end
	end

	% Upadte the strategy. In hunt mod, the pacan must not avoid anything
	% try to catch ghost. In classic mode, if a ghost is next to the pacman,
	% the avoid field is set.
	fun{UpdateStratG ID Status S P}
		case Status.m
		of hunt then {UpdateStrat Status.p strat(target:S.target priority:S.priority avoid:dir(n:NG s:NG e:NG w:NG)) P 3}
		[] classic then
			if P == {North Status.p} then strat(S.target S.priority dir(n:ID s:S.s e:S.e w:S.w))
			elseif P == {South Status.p} then strat(S.target S.priority dir(n:S.n s:ID e:S.e w:S.w))
			elseif P == {East Status.p} then strat(S.target S.priority dir(n:S.n s:S.s e:ID w:S.w))
			elseif P == {West Status.p} then strat(S.target S.priority dir(n:S.n s:S.s e:S.e w:ID))
			%remove ghost from threats if not next to pacman
			elseif S.n == ID then strat(S.target S.priority dir(n:NG s:S.s e:S.e w:S.w))
			elseif S.s == ID then strat(S.target S.priority dir(n:n s:NG e:S.e w:S.w))
			elseif S.e == ID then strat(S.target S.priority dir(n:n s:S.s e:NG w:S.w))
			elseif S.w == ID then strat(S.target S.priority dir(n:n s:S.s e:S.e w:NG))
			end
		else S
		end
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MOVE FUNCTIONS AND AUXILARY FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Check if the <position> P is walkable. A position threatened by a ghost is
	% considered not walkable by pacman.
	% Returns 1 if not walkable, and 0, 2, 3 or 4 if walkable
	fun{Walkable Position P Avoid}
		if P == {North Position} andthen Avoid.n \= NG then 1
		elseif P == {South Position} andthen Avoid.s \= NG then 1
		elseif P == {East Position} andthen Avoid.e \= NG then 1
		elseif P == {West Position} andthen Avoid.w \= NG then 1
		else {Find P}
	end

	% Define what the pacman does when she recieves a move(?ID ?P) message
	% Position is the current <position> of the pacman
	% Status is the <tatus> of the pacman
	% Strat is a record that stores the target to reach and the points to avoid
	% Move returns the new <position> of the pacman
	fun{Move Position Strat}
		if Strat.priority == 0 orelse {Walkable Position Strat.target Strat.avoid} == 1 then
			if {Walkable Position {North Position} Strat.avoid} \= 1 then {North Position}
			elseif {Walkable Position {South Position} Strat.avoid} \= 1 then {South Position}
			elseif {Walkable Position {East Position} Strat.avoid} \= 1 then {East Position}
			elseif {Walkable Position {West Position} Strat.avoid} \= 1 then {West Position}
			end
		else Strat.target
		end
	end

%%%%%%%%%%%%%%%%%%%%%%%
%%% CORE PROCEDURES %%%
%%%%%%%%%%%%%%%%%%%%%%%
	
  % ID is a <pacman> ID
  fun{StartPlayer ID}
    Stream
		Port
		Status
		Strat
  in
		NG = Input.NbGhost+1
    {NewPort Stream Port}
    thread
			Status = status(p:pt(x:Input.NColumn+2 y:Input.NRow+2) life:Input.NbLives score:0 m:classic)
			Strat = strat(target:Status.p priority:0 avoid:dir(n:NG s:NG e:NG w:NG))
      {TreatStream Stream Status ID Strat}
    end
    Port
  end

  proc{TreatStream Stream Status IDP Strat} % has as many parameters as you want
    NStatus
		NStrat
	in
		case Stream
		of H|T then
			case H
			of getID(ID) then 
				ID = IDP
				{TreatStream T Status IDP}
			[] assignSpawn(P) then
				Spawn = P
				NStatus = {UpdateStatus P Status.life 0 classic}
				NStrat = strat(target:P priority:0 avoid:Strat.avoid)
				{TreatStream T NStatus IDP NStrat}
			[] Move(ID P) then
				ID = IDP
				P = {Move Status.p Strat}
				{TreatStream T Status IDP strat(target:Strat.target avoid:{n:1 s:1 e:1 w:1})}
			[] bonusSpawn(P) then
				NStrat = {UpdateStrat Status.p Strat P 2}
				{TreatStream T Status IDP NStrat}
			[] pointSpawn(P) then
				NStrat = {UpdateStrat Status.p Strat P 1}
				{TreatStream T Status IDP NStrat}
			[] bonusRemoved(P) then
				if P == Strat.target then 
					NStrat = strat(target:Strat.target priority:0 avoid:Strat.avoid)
				else NStrat = Strat
				end
				{TreatStream T Status IDP NStrat}
			[] pointRemoved(P) then
				if P == Strat.target then 
					NStrat = strat(target:Strat.target priority:0 avoid:Strat.avoid)
				else NStrat = Strat
				end
				{TreatStream T Status IDP NStrat}
			[] addPoint(Add ID NewScore) then
				NStatus = {UpdateStatus Status.p Status.life Status.score+Add Status.m}
				ID = IDP
				NewScore = NStatus.score
				{TreatStream T NStatus IDP Strat}
			[] gotKilled(ID NewLife NewScore) then
				NStatus = {UpdateStatus Spawn Status.life-1 Status.score-Input.PenalityKill Status.m}
				NStrat = strat(target:NStatus.p priority:0 avoid:dir(n:NG s:NG e:NG w:NG))
				Id = IDP
				NewLife = NStatus.life
				NewScore = NStatus.score
				{TreatStream T NStatus IDP NStrat}
			[] ghostPos(ID P) then
				NStrat = {UpdateStratG ID Status Strat P}
				{TreatStream T Status IDP NStrat}
			[] killGhost(IDg IDp NewScore) then
				NStatus = {UpdateStatus Status.p Status.life Status.Score+Input.RewardKill Status.m}
				NStrat = {UpdateStratG IDg NStatus Strat pt(x:Input.NColumn+1 y:Input.NRow+1)}
				IDp = IDP
				NewScore = NStatus.score
				{TreatStream T NStatus IDP NStrat}
			[] deathGhost(ID) then
				NStrat = {UpdateStrat ID Status Strat pt(x:Input.NColumn+1 y:Input.NRow+1)}
				{TreatStream T Status IDP NStrat}
			[] setMode(M) then 
				NStatus = {UpdateStatus Status.p Status.life Status.score M}
				{TreatStream T NStatus IDP Strat}
			else {TreatStream T Status IDP Strat}
			end
		else skip
    end
  end
end