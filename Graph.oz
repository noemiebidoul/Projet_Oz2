declare Mark Enqueue FindInGraph IsMarked WhileNotEmpty ForEachAdj EdgeTo Bfs Path Graph in

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

fun{Bfs Point}
   NMarked
   NQueue
in
   NMarked = {Mark Point nil}
   NQueue = {Enqueue Point nil}
   {WhileNotEmpty nil NMarked NQueue}
end

%%%%%%%%%%%%%%%%%%%%%
%%% SHORTEST PATH %%%
%%%%%%%%%%%%%%%%%%%%%

fun{Path To From Edges}
   fun{FindEdge P E}
      case E of H|T then
	 if H.v == P then H
	 else {FindEdge P T}
	 end
      end
   end
   fun{Loop E P}
      if E.w == P then E.v|nil
      else
	 E.v|{Loop {FindEdge E.w Edges} P}
      end
   end
in
   {Loop {FindEdge From Edges} To}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENEREATE GRAPH FROM MAP %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%
%%% MAIN %%%
%%%%%%%%%%%%

Graph = [node(p:1 adj:[1 2])
	 node(p:2 adj:[1 3 4])
	 node(p:3 adj:[1 2])
	 node(p:4 adj:[2])]
{Browse {Path 1 4 {Bfs 1}}}