%% Pacman 000 other %%
functor
import
   Tk
   Input
   Browser
   OS
export
   portPlayer:StartPlayer
define   
   StartPlayer
   TreatStream
   Find
   North
   South
   East
   West
   UpdateStatus
   Walkable
   Move
   W
   F
   BrowserObject

in

%%%%%%%%%%%%%%%%%%%
%%% DEFINITIONS %%%
%%%%%%%%%%%%%%%%%%%

	% We define here the following types :
	% <status> ::= status(p:<position> life:<lives> score:<score> m:<mode> spawn:<position>)
	% <score> ::= 0|1|2|...


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% NAVIGATION ON THE MAP %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Returns the type of point (0, 1, 2, 3 or 4) at <position> Position
   fun{Find Position}
      R C
   in
      fun{R Y P M}
	 case M of H|T then
	    if Y == P.y then {C 1 P.x H}
	    else {R Y+1 P T} end
	 [] nil then 0
	 end
      end
      fun{C X P Row}
	 case Row of H|T then
	    if X == P then H
	    else {C X+1 P T} end
	 [] nil then 0
	 end
      end
      {R 1 Position Input.map}
   end

	% Returns the <position> north of <position> P
   fun{North P}
      if P.y == 1 then pt(x:P.x y:Input.nRow)
      else pt(x:P.x y:P.y-1)
      end
   end

	% Returns the <position> south of <position> P
   fun{South P}
      if P.y == Input.nColumn then pt(x:P.x y:1)
      else pt(x:P.x y:P.y+1)
      end
   end

	% Returns the <position> east of <position> P
   fun{East P}
      if P.x == Input.nColumn then pt(x:1 y:P.y)
      else pt(x:P.x+1 y:P.y)
      end
   end

	% Returns the <position> west of <position> P
   fun{West P}
      if P.x == 1 then pt(x:Input.nColumn y:P.y)
      else pt(x:P.x-1 y:P.y)
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% UPDATES OF PACMAN STATUS AND EGY %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% status is a record that stores the <position>, the remainig lives,
	% the current score and the <mode>
   fun{UpdateStatus Position Life Score Mode Spawn}
      status(p:Position life:Life score:Score m:Mode spawn:Spawn)
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MOVE FUNCTIONS AND AUXILARY FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Define what the pacman does when she recieves a move(?ID ?P) message
	% Position is the current <position> of the pacman
	% Status is the <tatus> of the pacman
	%  is a record that stores the target to reach and the points to avoid
	% Move returns the new <position> of the pacman
   fun{Move Position}
      if {Find {North Position}} \= 1 then {North Position}
	  elseif {Find {South Position}} \= 1 then {South Position}
	  elseif {Find {East Position}} \= 1 then {East Position}
	  else {West Position}
	  end
   end

%%%%%%%%%%%%%%%%%%%%%%%
%%% CORE PROCEDURES %%%
%%%%%%%%%%%%%%%%%%%%%%%
	
   % Browser Object (debugging purpose)   
   W = {New Tk.toplevel tkInit(bg:ivory)}
   {Tk.send wm(geometry W "500x300")}
   F = {New Tk.frame tkInit(parent : W
			    bd     : 3
			    bg     : white
			    relief : groove
			    width  : 450  
			    height : 250)}
   {Tk.send pack(F fill:both padx:10 pady:10 expand:true)}
   BrowserObject = {New Browser.'class' init(origWindow: F)}
   {BrowserObject createWindow}

  % ID is a <pacman> ID
   fun{StartPlayer ID}
      Stream
      Port
      Status
	  OutOfBoard
   in
	  OutOfBoard = pt(x:Input.nColumn+2 y:Input.nRow+2)
      {NewPort Stream Port}
      thread
	 Status = status(p:OutOfBoard life:Input.nbLives score:0 m:classic spawn:OutOfBoard)
	 {TreatStream Stream Status ID }
      end
      Port
   end

   proc{TreatStream Stream Status IDP } % has as many parameters as you want
      NStatus
      
   in
      case Stream
      of H|T then
	 case H
	 of getID(ID) then 
	    ID = IDP
	    {TreatStream T Status IDP}
	 [] assignSpawn(P) then
	    NStatus = {UpdateStatus P Status.life 0 classic P}
	    {TreatStream T NStatus IDP}
	 [] move(ID P) then
	    ID = IDP
	    P = {Move Status.p}
		NStatus = {UpdateStatus P Status.life Status.score Status.m Status.spawn}
	    {TreatStream T NStatus IDP}
	 [] bonusSpawn(P) then
	    {TreatStream T Status IDP}
	 [] pointSpawn(P) then
	    {TreatStream T Status IDP}
	 [] bonusRemoved(P) then
	    {TreatStream T Status IDP}
	 [] pointRemoved(P) then
	    {TreatStream T Status IDP}
	 [] addPoint(Add ID NewScore) then
	    NStatus = {UpdateStatus Status.p Status.life Status.score+Add Status.m Status.spawn}
	    ID = IDP
	    NewScore = NStatus.score
	    {TreatStream T NStatus IDP}
	 [] gotKilled(ID NewLife NewScore) then
	    NStatus = {UpdateStatus Status.spawn Status.life-1 Status.score-Input.penalityKill Status.m Status.spawn}
	    ID = IDP
	    NewLife = NStatus.life
	    NewScore = NStatus.score
	    {TreatStream T NStatus IDP}
	 [] ghostPos(ID P) then
	    {TreatStream T Status IDP}
	 [] killGhost(IDg IDp NewScore) then
	    NStatus = {UpdateStatus Status.p Status.life Status.score+Input.rewardKill Status.m Status.spawn}
	    IDp = IDP
	    NewScore = NStatus.score
	    {TreatStream T NStatus IDP}
	 [] deathGhost(ID) then
	    {TreatStream T Status IDP}
	 [] setMode(M) then 
	    NStatus = {UpdateStatus Status.p Status.life Status.score M Status.spawn}
	    {TreatStream T NStatus IDP}
	 else {TreatStream T Status IDP}
	 end
      else skip
      end
   end

end