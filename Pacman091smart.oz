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
   Move
   Mark
   Enqueue
   FindInGraph
   IsMarked
   WhileNotEmpty
   ForEachAdj
   EdgeTo
   Bfs
   Graph
   GenerateGraph
   Append
   Path
   Length
   FindGhost
   UpdateTarget
   UpdateGhostPos
   RemoveGhost
   ThreatLevel
   Choose
   Random
   UpdateBonuses
   FindBonus
in

%%%%%%%%%%%%%%%%%%%
%%% DEFINITIONS %%%
%%%%%%%%%%%%%%%%%%%

   % We define here the following types :
	% <status> ::= status(p:<position> life:<lives> score:<score> m:<mode> spawn:<position>)
	% <score> ::= 0|1|2|...
   % <strategy> ::= strat(t:<target> g:<ghosts> b:<bonuses> m:<map>)
   % <map> ::= <map>
   %         | <edge>
   %         | nil
   % <target> ::= t(p:<position> r:<rank>)
   % <rank> ::= ~2|~1|0|<idNumG>
   % <ghosts> ::= <ghosts>
   %            | <ghost>
   %            | nil
   % <ghost> ::= g(id:<idNumG> p:<position>)
   % <bonuses> ::= <bonuses>
   %             | <bonus>
   %             | nil
   % <bonus> ::= b(p:<position> v:<bool>)
   % <graph> ::= <graph>
   %           | <node>
   %           | nil
   % <node> ::= node(p:<position> adj:<adjList>)
   % <adjList> ::= <adjList>
   %             | <position>
   %             | nil
   % <edge> ::= edge(v:<position> w:<position>)
   % <threat> ::= pos(p:<position> l:<level>)
   % <level> ::= 0|1|2|3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PROCEDURES FOR GRAPH %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun{Append L1 L2}
      case L1 of nil then L2
      [] H|T then H|{Append T L2}
      end
   end

% Returns a <graph> generated from the Map
   fun{GenerateGraph Map}
   % Returns a <node> built from <position> (X,Y)
      fun{Node X Y}
	 Point
      % Returns the adjacency list of <point> P. This is a list of <position>.
	 fun{BuildAdj P Adj Acc}
	    case Acc of 4 then Adj
	    [] 0 then 
	       if {Find {North P}} \= 1 then {BuildAdj P {Append Adj [{North P}]} Acc+1}
	       else {BuildAdj P Adj Acc+1} end
	    [] 1 then 
	       if {Find {South P}} \= 1 then {BuildAdj P {Append Adj [{South P}]} Acc+1}
	       else {BuildAdj P Adj Acc+1} end
	    [] 2 then 
	       if {Find {East P}} \= 1 then {BuildAdj P {Append Adj [{East P}]} Acc+1}
	       else {BuildAdj P Adj Acc+1} end
	    [] 3 then 
	       if {Find {West P}} \= 1 then {BuildAdj P {Append Adj [{West P}]} Acc+1}
	       else {BuildAdj P Adj Acc+1} end
	    end
	 end
      in
	 Point = pt(x:X y:Y)
	 node(p:Point adj:{BuildAdj Point nil 0})
      end
   % Returns a list of <node> generated from <position> in de row
      fun{Col R X Y G}
	 case R of nil then G
	 [] H|T then
	    if H \= 1 then {Col T X+1 Y {Append G [{Node X Y}]}}
	    else {Col T X+1 Y G}
	    end
	 end
      end
   % Returns a list of <node>
      fun{Row Map Y G}
	 case Map of nil then G
	 [] H|T then {Row T Y+1 {Append G {Col H 1 Y nil}}}
	 end
      end
   in
      {Row Map 1 nil}
   end

% Updates the list of visited points
% Returns a new list of <position>
   fun{Mark Point M}
      case M of nil then Point|nil
      [] H|T then H|{Mark Point T}
      end
   end

% Pushes the point at the end of the list of
% points to be visited
% Returns a new list of <position>
   fun{Enqueue Point Q}
      case Q of nil then Point|nil
      [] H|T then H|{Enqueue Point T}
      end
   end

% Returns the node corresponding to
% the Point in Graph
   fun{FindInGraph G Point}
      case G of nil then error
      [] H|T then
	 if H.p == Point then H
	 else {FindInGraph T Point}
	 end
      end
   end

% Returns true if P is in M, false if not
   fun{IsMarked P M}
      case M of nil then false
      [] H|T then
	 if P == H then true
	 else {IsMarked P T}
	 end
      end
   end

% Inner function of Bfs that returns the list
% shortest edges
   fun{WhileNotEmpty E M Q}
      V
      Node
      L
      NQ
      fun{DeleteFirst Q}
	 case Q of _|T then T
	 else nil
	 end
      end
      proc{Dequeue Q Head NQueue}
	 case Q of H|_ then Head = H
	 else skip
	 end
	 NQueue = {DeleteFirst Q}
      end
   in
      case Q of nil then E
      else
	 {Dequeue Q V NQ}
	 Node = {FindInGraph Graph V}
	 L = {ForEachAdj V Node.adj E M NQ}
	 {WhileNotEmpty L.1 L.2 L.3}
      end
   end

% Inner function of WhileNotEmpty
   fun{ForEachAdj Point Adj E M Q}
      NEdges
      NMarked
      NQueue
   in
      case Adj of nil then E#M#Q
      [] H|T then
	 if {Not {IsMarked H M}} then
	    NEdges = {EdgeTo H Point E}
	    NMarked = {Mark H M}
	    NQueue = {Enqueue H Q}
	 else
	    NEdges = E
	    NMarked = M
	    NQueue = Q
	 end
	 {ForEachAdj Point T NEdges NMarked NQueue}
      end
   end

   fun{EdgeTo V W E}
      case E of nil then edge(v:V w:W)|nil
      [] H|T then
	 if H.v == V then edge(v:V w:W)|T
	 else H|{EdgeTo V W T}
	 end
      end
   end

% Returns a list of <egde> that can be used to find paths
   fun{Bfs Point}
      NMarked
      NQueue
   in
      NMarked = {Mark Point nil}
      NQueue = {Enqueue Point nil}
      {WhileNotEmpty nil NMarked NQueue}
   end

% Returns the shortest path from From to To, which is
% a list of <position>
   fun{Path To From Edges}
      fun{FindEdge P E}
	 case E of H|T then
	    if H.v == P then H
	    else {FindEdge P T}
	    end
	 else none
	 end
      end
      fun{Loop E P}
	 if E == none then nil
	 elseif E.w == P then E.v|nil
	 else
	    E.v|{Loop {FindEdge E.w Edges} P}
	 end
      end
   in
      {Loop {FindEdge From Edges} To}
   end

% Returns the length of the path
   fun{Length Path}
      fun{Len Path Acc}
	 case Path of nil then Acc
	 [] _|T then {Len T Acc+1}
	 end
      end
   in
      {Len Path 0}
   end

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

	% Returns the <position> south of <falseposition> P
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
%%% UPDATES OF PACMAN STATUS AND STRATEGY%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% status is a record that stores the <position>, the remainig lives,
	% the current score and the <mode>
   fun{UpdateStatus Position Life Score Mode Spawn}
      status(p:Position life:Life score:Score m:Mode spawn:Spawn)
   end

   % Returns a <strategy> where the <traget> is updated if it is a better <target>.
   fun{UpdateTarget Position Target Rank Strat Mode}
      fun{UT Position Target Rank Strat}
         R
      in
         if Strat.t.r > 0 then R = ~2
         else R = Strat.t.r
         end
         % Better rank
         if Rank > R then strat(t:t(p:Target r:Rank) g:Strat.g b:Strat.b m:Strat.m)
               % Lower rank
         elseif Rank < R then Strat
         else
            local P1 P2 in
               P1 = {Path Position Target Strat.m} 
               P2 = {Path Position Strat.t.p Strat.m}
               if P1 == nil then Strat
               elseif P2 == nil then strat(t:t(p:Target r:Rank) g:Strat.g b:Strat.b m:Strat.m)
                     % Same rank but further
               elseif {Length P1} > {Length P2} then Strat
                     % Same rank but closer
               else strat(t:t(p:Target r:Rank) g:Strat.g b:Strat.b m:Strat.m)
               end
            end
         end
      end
      fun{UTH Position Target ID Strat}
	 if ID < 1 then Strat
	 elseif Strat.t.r < 1 then strat(t:t(p:Target r:ID) g:Strat.g b:Strat.b m:Strat.m)
	 else
	    local P1 P2 in
	       P1 = {Path Position Target Strat.m} 
	       P2 = {Path Position Strat.t.p Strat.m}
	       if P1 == nil then strat(t:t(p:Target r:ID) g:Strat.g b:Strat.b m:Strat.m)
	       elseif P2 == nil then Strat
	       elseif {Length P1} > {Length P2} then Strat
	       else strat(t:t(p:Target r:ID) g:Strat.g b:Strat.b m:Strat.m)
	       end
	    end
	 end
      end
   in
      if Mode == hunt andthen Strat.g \= nil then {UTH Position Target Rank Strat}
      else {UT Position Target Rank Strat}
      end
   end

   % Add the <ghost> with id:ID and p:P to the <ghosts> list if she is 
   % not already in there. If she is, then it updates it <position>
   % Returns a <ghosts> list
   fun{UpdateGhostPos ID P G}
      case G of nil then g(id:ID p:P)|nil
      [] H|T then 
	 if H.id == ID then g(id:ID p:P)|T
	 else H|{UpdateGhostPos ID P T}
	 end
      end
   end

   % If the <ghost> with id:ID is in the <ghosts> list G, remmoves her
   % the list.
   % Returns a <ghosts> list.
   fun{RemoveGhost ID G}
      case G of nil then nil
      [] H|T then
	 if H.id == ID then {RemoveGhost ID T}
	 else H|{RemoveGhost ID T}
	 end
      end
   end

   % P is the position of the bonus
   % Bool is the state of the bonus
   % B is the list of bonuses in Strat
   fun{UpdateBonuses P Bool B}
      case B of nil then b(p:P v:Bool)|nil
      [] H|T then 
	 if H.p == P then b(p:P v:Bool)|T
	 else H|{UpdateBonuses P Bool T}
	 end
      end
   end
   
   % Set the target to the closest bonus if it is better than current target
   fun{FindBonus Position Strat Mode}
      Bonus
      fun{Closest B M P Acc}
	 case B of nil then Acc
	 [] H|T then 
	    if Acc == none then {Closest T M P H} 
	    elseif {Length {Path P H.p M}} < {Length {Path P Acc.p M}} then {Closest T M P H}
	    else {Closest T M P Acc}
	    end
	 end
      end
   in
      Bonus = {Closest Strat.b Strat.m Position none}
      case Bonus of none then {UpdateTarget Position Position ~2 Strat Mode}
      else {UpdateTarget Position Bonus.p 0 Strat Mode}
      end
   end

    % Set the target to the closest ghost if it is better than current target
   fun{FindGhost Position Strat Mode}
      Ghost
      fun{Closest G M P Acc}
         case G of nil then Acc
         [] H|T then 
            if Acc == none then {Closest T M P H}
            elseif {Length {Path P H.p M}} < {Length {Path P Acc.p M}} then {Closest T M P H}
            else {Closest T M P Acc}
            end
         end
      end
   in
      Ghost = {Closest Strat.g Strat.m Position none}
      case Ghost of none then {FindBonus Position Strat Mode}
      else {UpdateTarget Position Ghost.p Ghost.id Strat Mode}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MOVE FUNCTIONS AND AUXILARY FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Evaluates the threats around the pacman.
   % Returns a list of <threat>.
   % A <level> of ~1 means a wall
   % A <level> of 0 means no threat
   % A <level> of 1 means a ghost is next to the <position>
   % A <level> of 2 means a ghost is on the <position>
   fun{ThreatLevel Position G}
      N S E W
      fun{IsThreatening P G}
	 case G of nil then false
	 [] H|T then
	    if H.p == P then true
	    else {IsThreatening P T}
	    end
	 end
      end
      fun{Threatened P G}
	 if {IsThreatening {North P} G} then 1
	 elseif {IsThreatening {South P} G} then 1
	 elseif {IsThreatening {East P} G} then 1
	 elseif {IsThreatening {West P} G} then 1
	 else 0
	 end
      end
      fun{Occupied P G}
	 if {Find P} == 1 then ~1
	 else
	    case G of nil then {Threatened P G}
	    [] H|T then
	       if H.p == P then 2
	       else {Occupied P T}
	       end
	    end
	 end
      end
   in
      N = {North Position}
      S = {South Position}
      E = {East Position}
      W = {West Position}
      [pos(p:N l:{Occupied N G})
       pos(p:S l:{Occupied S G})
       pos(p:E l:{Occupied E G})
       pos(p:W l:{Occupied W G})]
   end

   % Returns the safest <position> among the <threat> list Directions.
   % If 2 <positions> are equally safe, returns the one that's on
   % path to the pacman's target if possible, and a random one if
   % not.
   % If none are safe, then returns a unsafe <position>
   % Target is the first step of the path to the target
   fun{Choose Directions Position Target}
      fun{State D N}
	 case D of nil then nil
	 [] H|T then 
	    if H.l == N then H.p|{State T N}
	    else {State T N}
	    end
	 end
      end
      fun{LoopInt D Tar}
	 case D of nil then none
	 [] H|T then 
	    if H == Tar then H
	    else {LoopInt T Tar}
	    end
	 end
      end
      fun{Ext D P Tar}
	 S0 S1 S2 L0 L1 L2
      in
	 S0 = {State D 0}
	 S1 = {State D 1}
	 S2 = {State D 2}
	 case S0 of nil then 
	    case S1 of nil then 
	       case S2 of nil then P %when pacman is between 4 walls...
	       else
		  L2 = {LoopInt S2 Tar}
		  if L2 == none then S2.1
		  else L2
		  end
	       end
	    else
	       L1 = {LoopInt S1 Tar}
	       if L1 == none then S1.1
	       else L1
	       end
	    end
	 else
	    L0 = {LoopInt S0 Tar}
	    if L0 == none then S0.1
	    else L0
	    end
	 end
      end
   in
      {Ext Directions Position Target} 
   end

   % Returns a random <position> next to P
   % The returned <position> is never a wall.
   fun{Random P}
      I J
   in
      {OS.rand I}
      J = I mod 3
      if J == 0 andthen {Find {North P}} \= 1 then {North P}
      elseif J == 1 andthen {Find {South P}} \= 1 then {South P}
      elseif J == 2 andthen {Find {East P}} \= 1 then {East P}
      elseif J == 2 andthen {Find {West P}} \= 1 then {West P}
      else {Random P}
      end
   end

	% Define what the pacman does when she recieves a move(?ID ?P) message
	% Position is the current <position> of the pacman
	% Status is the <tatus> of the pacman
	%  is a record that stores the target to reach and the points to avoid
	% Move returns the new <position> of the pacman
   fun{Move Position Strat Mode}
      P
      fun{Last L Acc}
	 case L of nil then Acc
	 [] H|T then {Last T H}
	 end
      end
   in
      if Strat.t.r == ~2 then P = [{Random Position}]
      else P = {Path Position Strat.t.p Strat.m}
      end
      case Mode
      of classic then {Choose {ThreatLevel Position Strat.g} Position {Last P {Random Position}}}
      [] hunt then {Last P {Random Position}}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%
%%% CORE PROCEDURES %%%
%%%%%%%%%%%%%%%%%%%%%%%

  % ID is a <pacman> ID
   fun{StartPlayer ID}
      Stream
      Port
      MStream
      MPort
      Status
      Strat
      OutOfBoard
   in
      Graph = {GenerateGraph Input.map}
      OutOfBoard = pt(x:Input.nColumn+2 y:Input.nRow+2)
      {NewPort Stream Port}
      {NewPort MStream MPort}
      thread
	      Status = status(p:OutOfBoard life:Input.nbLives score:0 m:classic spawn:OutOfBoard)
	      Strat = strat(t:t(p:OutOfBoard r:~2) g:nil b:nil m:nil)
	      {TreatStream Stream Status ID Strat Input.isTurnByTurn}
      end
      thread {ReadStream MStream} end
      Port
   end

   proc{ReadStream Stream}
      case Stream
      of H|T then
         case H of move(P Current Strat Mode Wait) then 
            if Wait then
               local I J in
                  {OS.rand I}
                  J = I mod (Input.thinkMax-Input.thinkMin)
                  {Delay J+Input.thinkMin}
               end
            end
            P = {Move Current Strat Mode}
         else skip
         end 
      else skip
      end
   end
   proc{TreatStream Stream St IDP S TbT} % has as many parameters as you want
      NSt
      NS
      G
   in
      case Stream
      of H|T then
	 case H
	 of getID(ID) then 
	    ID = IDP
	    {TreatStream T St IDP S TbT}
	 [] assignSpawn(P) then
	    NSt = {UpdateStatus P St.life 0 classic P}
	    {TreatStream T NSt IDP S TbT}
	 [] spawn(ID P) then
	    ID = IDP
	    P = St.p
	    {TreatStream T St IDP S TbT}
	 [] move(ID P) then
	    ID = IDP 
	    {Send MPort move(P St.p S St.m {Not TbT})}
	    NSt = {UpdateStatus P St.life St.score St.m St.spawn}
	    NS = strat(t:S.t g:S.g b:S.b m:{Bfs P})
	    {TreatStream T NSt IDP NS TbT}
	 [] bonusSpawn(P) then
	    NS = {UpdateTarget St.p P 0 strat(t:S.t g:S.g b:{UpdateBonuses P true S.b} m:S.m) St.m}
	    {TreatStream T St IDP NS TbT}
	 [] pointSpawn(P) then
	    NS = {UpdateTarget St.p P ~1 S St.m}
	    {TreatStream T St IDP NS TbT}
	 [] bonusRemoved(P) then
      % current target is a bonus at position P
	    if S.t.r == 0 andthen S.t.p == P then 
	       NS = {FindBonus St.p strat(t:S.t g:S.g b:{UpdateBonuses P false S.b} m:S.m) St.m}
	    else NS = S end
	    {TreatStream T St IDP NS TbT}
	 [] pointRemoved(P) then
      % current target is a point at position P
        if S.t.r == ~1 andthen S.t.p == P then NS = {FindBonus St.p S St.m}
        else NS = S end
	    {TreatStream T St IDP NS TbT}
	 [] addPoint(Add ID NewScore) then
	    NSt = {UpdateStatus St.p St.life St.score+Add St.m St.spawn}
	    ID = IDP
	    NewScore = NSt.score
	    {TreatStream T NSt IDP S TbT}
	 [] gotKilled(ID NewLife NewScore) then
	    NSt = {UpdateStatus St.spawn St.life-1 St.score-Input.penalityKill St.m St.spawn}
       ID = IDP
	    NewLife = NSt.life
	    NewScore = NSt.score
	    {TreatStream T NSt IDP S TbT}
	 [] ghostPos(ID P) then
	    G = {UpdateGhostPos ID.id P S.g}
	    if St.m == hunt then NS = {UpdateTarget St.p P ID.id strat(t:S.t g:G b:S.b m:S.m) St.m}
	    else NS = strat(t:S.t g:G b:S.b m:S.m) end
	    {TreatStream T St IDP NS TbT}
	 [] killGhost(IDg IDp NewScore) then
	    G = {RemoveGhost IDg.id S.g}
	    NS = {FindGhost St.p strat(t:S.t g:G b:S.b m:S.m) St.m}
	    NSt = {UpdateStatus St.p St.life St.score+Input.rewardKill St.m St.spawn}
	    IDp = IDP
	    NewScore = NSt.score
	    {TreatStream T NSt IDP NS TbT}
	 [] deathGhost(ID) then
	    G = {RemoveGhost ID.id S.g}
	    NS = {FindGhost St.p strat(t:S.t g:G b:S.b m:S.m) St.m}
	    {TreatStream T St IDP NS TbT}
	 [] setMode(M) then 
	    NSt = {UpdateStatus St.p St.life St.score M St.spawn}
       case M of classic then NS = {FindBonus NSt.p S NSt.m}
       else NS = {FindGhost NSt.p S NSt.m}
       end
	    {TreatStream T NSt IDP NS TbT}
	 else {TreatStream T St IDP S TbT}
	 end
      else skip
      end
   end
end