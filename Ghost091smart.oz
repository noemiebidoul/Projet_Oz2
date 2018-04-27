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
   Find
   North
   South
   East
   West
   UpdateStatus
   UpdateTarget
   UpdatePacPos
   RemovePac
   FindPac
   ThreatLevel
   Choose
   Random
   Move
   OutOfBoard = pt(x:Input.nColumn+2 y:Input.nRow+2)
in

   % We define here the following types :
    % <status> ::= status(p:<position> m:<mode> spawn:<position>)
   % <strategy> ::= strat(t:<position> p:<pacmans> m:<map>)
   % <map> ::= <map>
   %         | <edge>
   %         | nil
   % <pacmans> ::= <pacmans>
   %            | <pacman>
   %            | nil
   % <pacman> ::= p(id:<idNumG> p:<position>)
   % <graph> ::= <graph>
   %           | <node>
   %           | nil
   % <node> ::= node(p:<position> adj:<adjList>)
   % <adjList> ::= <adjList>
   %             | <position>
   %             | nil
   % <edge> ::= edge(v:<position> w:<position>)
   % <threat> ::= pos(p:<position> l:<level>)
   % <level> ::= ~1|0|1|2

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
   fun{UpdateStatus Position  Mode Spawn}
      status(p:Position m:Mode spawn:Spawn)
   end

   fun{UpdateTarget Position Target Strat}
      if Strat.t == OutOfBoard then strat(t:Target p:Strat.p m:Strat.m)
      else
         local P1 P2 in
            P1 = {Path Position Target Strat.m} 
            P2 = {Path Position Strat.t Strat.m}
            if P1 == nil then Strat
            elseif P2 == nil then strat(t:Target p:Strat.p m:Strat.m)
            elseif {Length P1} > {Length P2} then Strat
            else strat(t:Target p:Strat.p m:Strat.m)
            end
         end
      end
   end

   % Add the <pacman> with id:ID and p:P to the <pacmans> list if she is 
   % not already in there. If she is, then it updates it <position>
   % Returns a <pacmans> list
   fun{UpdatePacPos ID P L}
      case L of nil then p(id:ID p:P)|nil
      [] H|T then 
	      if H.id == ID then p(id:ID p:P)|T
	      else H|{UpdatePacPos ID P T}
	      end
      end
   end

   % If the <pacmans> with id:ID is in the <pacmans> list L, remmoves her
   % the list.
   % Returns a <pacmans> list.
   fun{RemovePac ID L}
      case L of nil then nil
      [] H|T then
	      if H.id == ID then {RemovePac ID T}
	      else H|{RemovePac ID T}
	      end
      end
   end

   % Set the target to the closest pacman
   fun{FindPac Position Strat}
      Pac
      fun{Closest L M P Acc}
         case L of nil then Acc
         [] H|T then 
            if Acc == none then {Closest T M P H}
            elseif {Length {Path P H.p M}} < {Length {Path P Acc.p M}} then {Closest T M P H}
            else {Closest T M P Acc}
            end
         end
      end
   in
      Pac = {Closest Strat.p Strat.m Position none}
      case Pac of none then strat(t:Position p:nil m:Strat.m)
      else {UpdateTarget Position Pac.p Strat}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% MOVE FUNCTIONS AND AUXILARY FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Evaluates the threats around the pacman.
   % Returns a list of <threat>.
   % A <level> of ~1 means a wall
   % A <level> of 0 means no threat
   % A <level> of 1 means a pacman is next to the <position>
   % A <level> of 2 means a pacman is on the <position>
   fun{ThreatLevel Position L}
      N S E W
      fun{IsThreatening P L}
         case L of nil then false
         [] H|T then
            if H.p == P then true
            else {IsThreatening P T}
            end
         end
      end
      fun{Threatened P L}
         if {IsThreatening {North P} L} then 1
         elseif {IsThreatening {South P} L} then 1
         elseif {IsThreatening {East P} L} then 1
         elseif {IsThreatening {West P} L} then 1
         else 0
         end
      end
      fun{Occupied P L}
         if {Find P} == 1 then ~1
         else
            case L of nil then {Threatened P L}
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
      [pos(p:N l:{Occupied N L})
       pos(p:S l:{Occupied S L})
       pos(p:E l:{Occupied E L})
       pos(p:W l:{Occupied W L})]
   end

   % Returns the safest <position> among the <threat> list Directions.
   % If none are safe, then returns a unsafe <position>
   % Target is the first step of the path to the target
   fun{Choose Directions Position}
      fun{State D N}
         case D of nil then nil
         [] H|T then 
            if H.l == N then H.p|{State T N}
            else {State T N}
            end
	      end
      end
      fun{Ext D P}
         S0 S1 S2
      in
         S0 = {State D 0}
         S1 = {State D 1}
         S2 = {State D 2}
         case S0 of nil then 
            case S1 of nil then 
               case S2 of nil then P %when ghost is between 4 walls...
               else
                  S2.1
               end
            else
               S1.1
            end
         else
            S0.1
         end
      end
   in
      {Ext Directions Position} 
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

   % Define what the ghost does when she recieves a move(?ID ?P) message
	% Position is the current <position> of the ghost
	% Status is the <tatus> of the ghost
	% Strat is a record that stores the target to reach and the points to avoid
	% Move returns the new <position> of the ghost
   fun{Move Position Strat Mode}
      P
      fun{Last L Acc}
         case L of nil then Acc
         [] H|T then {Last T H}
         end
      end
   in
      if Strat.p == nil then P = [{Random Position}]
      else P = {Path Position Strat.t Strat.m}
      end
      case Mode
      of hunt then {Choose {ThreatLevel Position Strat.p} Position}
      [] classic then {Last P {Random Position}}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%
%%% CORE PROCEDURES %%%
%%%%%%%%%%%%%%%%%%%%%%%

   % ID is a <ghost> ID
   fun{StartPlayer ID}
      Stream
      Port
      Status
      Strat
   in
      Graph = {GenerateGraph Input.map}
      Status = status(p:OutOfBoard m:classic spawn:OutOfBoard)
      Strat = strat(t:OutOfBoard p:nil m:nil)
      {NewPort Stream Port}
      thread
	      {TreatStream Stream Status ID Strat}
      end
      Port
   end
   
   
   
   proc{TreatStream Stream St IDG S} % has as many parameters as you want
      NSt NS Pac
   in
      case Stream of H|T then
         case H of getId(ID) then
            ID = IDG
            {TreatStream T St IDG S}
         [] assignSpawn(P) then
            NSt = {UpdateStatus P St.m P}
            NS = strat(t:S.t p:S.p m:{Bfs P})
            {TreatStream T NSt IDG NS}
         [] spawn(ID P) then
            ID = IDG
            P = St.p
            {TreatStream T St IDG S}
         [] move(ID P) then
            if({Not Input.isTurnByTurn}) then
               {Delay ({OS.rand} mod (Input.thinkMax-Input.thinkMin))+Input.thinkMin}
            end
            ID = IDG
            P = {Move St.p S St.m}
            NSt = {UpdateStatus P St.m St.spawn}
            NS = strat(t:S.t p:S.p m:{Bfs P})
            {TreatStream T NSt IDG NS}
         [] gotKilled() then
            NSt = {UpdateStatus St.spawn St.m St.spawn}
            {TreatStream T NSt IDG S}
         [] pacmanPos(ID P) then
            Pac = {UpdatePacPos ID.id P S.p}
            NS = {UpdateTarget St.p P strat(t:S.t p:Pac m:S.m)}
            {TreatStream T St IDG NS}
         [] killPacman(ID) then
            Pac = {RemovePac ID.id S.p}
            NS = {FindPac St.p S}
            {TreatStream T St IDG NS}
         [] deathPacman(ID) then
            Pac = {RemovePac ID.id S.p}
            NS = {FindPac St.p S}
            {TreatStream T St IDG NS}
         [] setMode(M) then
            NSt = {UpdateStatus St.p M St.spawn}
            case M of classic then NS = {FindPac St.p S}
            else NS = S
            end
            {TreatStream T NSt IDG NS}
         else {TreatStream T St IDG S}
         end
      else skip
      end
   end
end
