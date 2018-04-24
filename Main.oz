%% Main %%
functor
import
   Tk
   GUI
   Input
   PlayerManager
   Browser
   OS
   Stack
define
   WindowPort
   InitPlayers
   FirstSpawns
   Pacmans
   Ghosts
   Order
   Shuffle
   PortMain
   StreamMain
   PortPacmans
   StreamPacmans
   PortGhosts
   StreamGhosts
   ReadStreamPlayers
   ReadStreamMain
   NbPlayer
   Start
   Turn
   W
   F
   BrowserObject
   CreateMap
   Board
   HuntMode
   SpawnsP
   SpawnsG
   Respawn
   Move
   GetSpawn
   EatPoint
   EatBonus
   GhostEatPacman
in

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% HELPER FUNCTIONS FOR INITIALIZATION %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % @PRE: L the list of the 'Length' players
   % @POST: Returns a shuffled list of L
   fun {Shuffle L Length}
      local E Tail N Nth in

	 fun {Nth L N E}
	    case L
	    of nil then nil
	    [] H|T then
	       if N==1 then
		  E = H
		  T
	       else
		  H|{Nth T N-1 E}
	       end
	    end
	 end
	    
	 case L
	 of nil then nil
	 else
	    N = ({OS.rand} mod Length) + 1
	    Tail = {Nth L N E}
	    E|{Shuffle Tail Length-1}
	 end
      end
   end

   % @PRE: M, Input.nRow
   %       N, Input.nColumn
   % @POST: Returns an empty dynamic map of the right dimensions,
   % whose elements are empty stacks
   fun {CreateMap M N}
      local Rows in

	 Rows = {Tuple.make 'r' M}

	 for I in 1..M do
	    Rows.I = {Tuple.make 'c' N}
	    for J in 1..N do
	       Rows.I.J = {Stack.new}
	    end
	 end
      
	 Rows
      end
   end

   % @PRE:  'Kind' le type de joueurs dont on souhaite générer les ID
   % ('P' pour les pacman, 'G' pour les ghost)
   %
   % @RETURN: Liste permettant d'identifier et contacter chaque
   % joueur du type précisé.
   % Chaque élément est un tuple de forme 'port#ID'
   % où 'port' est le port permettant de contacter le joueur
   %    'ID' est l'ID de type <pacman>/<ghost du joueur
   fun {InitPlayers Kind}
      local Aux in
	 
	 fun {Aux L I}
	    local ID Port in
	       case L
	       of nil#nil then nil
	       [] (K|T1)#(C|T2) then
		  if Kind=='P' then
		     ID = pacman(id:I color:C name:p)
		  else
		     ID = ghost(id:I color:C name:g)
		  end
		  Port = {PlayerManager.playerGenerator K ID}
		  player(port:Port id:ID)|{Aux T1#T2 I+1}
	       end
	    end
	 end
	 
	 if Kind=='P' then
	    {Aux Input.pacman#Input.colorPacman 1}
	 else
	    {Aux Input.ghost#Input.colorGhost 1}
	 end
	 
      end
   end

   proc {FirstSpawns Map WindowPort ToSpawnP ToSpawnG}
      local HandlePos SpawnColumn SpawnRow in

	 proc {HandlePos H P}
	    local N M in

	       N = P.x
	       M = P.y

	       % Walkable place i.e. spawn for point
	       if H==0 then

		  {Stack.push Board.M.N 'walkable'}
		  {Stack.push Board.M.N 'point'}
		  
		  {Send WindowPort initPoint(P)}
		  {Send WindowPort spawnPoint(P)}

               % Spawn for pacman  
	       elseif H==2 then
		  case @ToSpawnP
		  of nil then skip % Each pacman already has a spawn
		  [] (P1|P2) then

		     SpawnsP.(P1.id.id) = P
		     
		     {Send WindowPort initPacman(P1.id)}
		     {Send P1.port assignSpawn(P)}

		     {Stack.push Board.M.N 'walkable'}
		     {Respawn P1 P}

		     ToSpawnP := P2
		  
		  end

	       % Spawn for ghost
	       elseif H==3 then
		  case @ToSpawnG
		  of nil then skip % Each ghost already has a spawn
		  [] G1|G2 then

		     SpawnsG.(G1.id.id) = P
		     
		     {Send WindowPort initGhost(G1.id)}
		     {Send G1.port assignSpawn(P)}

		     {Stack.push Board.M.N 'walkable'}
		     {Respawn G1 P}
		     
		     ToSpawnG := G2
		  
		  end

	       % Spawn for bonus
	       elseif H==4 then

		  {Stack.push Board.M.N 'walkable'}
		  {Stack.push Board.M.N 'bonus'}
		  
		  {Send WindowPort initBonus(P)}
		  {Send WindowPort spawnBonus(P)}

	       % Wall
	       elseif H==1 then
		  {Stack.push Board.M.N 'wall'}

	       else skip
	       end
	    end
	 end

	 proc{SpawnColumn Column M N}
	    local P in
	       case Column
	       of nil then skip
	       [] T|End then
	 
		  P = pt(x:N y:M)
		  {HandlePos T P}
	 
		  {SpawnColumn End M N+1}
	       end
	    end
	 end

	 proc{SpawnRow Row M}
	    case Row
	    of nil then
	       % If still unplaced players after browsing through
	       % the whole map: re-browse from the start
	       if @ToSpawnP\=nil orelse @ToSpawnG\=nil then
		  {SpawnRow Map 1}
	       else
		  skip
	       end
	       
	    [] T|End then
	       {SpawnColumn T M 1}
	       {SpawnRow End M+1}
	    end
	 end

	 {SpawnRow Map 1}
	 
      end
   
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FUNCTIONS USED BY BOTH MODES %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   % @PRE: Player a record of type 'player(port:P id:ID)'
   % @POST: Spawns player onto it's spawn, on the GUI and
   %        on the local dynamic Board + warns the concerned
   %        player, and all the players of the opposite kind.
   proc {Respawn Player Spawn}
      {Stack.push Board.(Spawn.y).(Spawn.x) Player}
      case Player.id of pacman(id:_ color:_ name:_) then
	 {Send WindowPort spawnPacman(Player.id Spawn)}
	 {Send PortGhosts pacmanPos(Player.id Spawn)}
      else
	 {Send WindowPort spawnGhost(Player.id Spawn)}
	 {Send PortPacmans ghostPos(Player.id Spawn)}
      end

      local ID P in
	 {Send Player.port spawn(ID P)}
      end
   end

   % Moves the player of player id 'Player' from
   % 'CurPos' to 'NextPos' on the GUI and the local
   % Board, and warns the players from the opposite kind.
   proc {Move Player CurPos NextPos}   
      {Stack.erase Board.(CurPos.y).(CurPos.x) Player}
      {Stack.push Board.(NextPos.y).(NextPos.x) Player}
      case Player.id of pacman(id:_ color:_ name:_) then
	 {Send WindowPort movePacman(Player.id NextPos)}
	 {Send PortGhosts pacmanPos(Player.id NextPos)}
      else
	 {Send WindowPort moveGhost(Player.id NextPos)}
	 {Send PortPacmans ghostPos(Player.id NextPos)}
      end
   end

   % Hides the point on the GUI and the local Board,
   % update player's score &  warns pacman of point's
   % disapearing
   proc {EatPoint Pacman Pos}    
      {Send WindowPort hidePoint(Pos)}
      {Stack.erase Board.(Pos.y).(Pos.x) 'point'}
      local RespawnTimePoint ID NewScore in
	 RespawnTimePoint = Input.respawnTimePoint-1
	 {Send PortMain spawnPoint(Pos RespawnTimePoint)}
	 {Send Pacman.port addPoint(Input.rewardPoint ID NewScore)}
	 {Send WindowPort scoreUpdate(Pacman.id NewScore)}
      end
      {Send PortPacmans pointRemoved(Pos)}     
   end

   proc {EatBonus Pacman Pos}
      HuntMode:=true
      {Send WindowPort hideBonus(Pos)}
      {Send WindowPort setMode('hunt')}
      {Stack.erase Board.(Pos.y).(Pos.x) 'bonus'}
      local RespawnTimeBonus in
	 RespawnTimeBonus = Input.respawnTimeBonus-1
	 {Send PortMain spawnBonus(Pos RespawnTimeBonus)}
      end
      {Send PortMain huntTime(Input.huntTime-1)}
      {Send PortPacmans bonusRemoved(Pos)}
      {Send PortPacmans setMode('hunt')}
      {Send PortGhosts setMode('hunt')}
   end

   fun {Turn Player CurPos}
      local ID NextPos O in
	 
	 {Send Player.port move(ID NextPos)}

	 % Checks the answer's format & provider
	 if ID==Player.id then
	    case NextPos of pt(x:N y:M) then

	       % Item on position where the player wants to move
	       O = {Stack.peek Board.M.N}

	       % Reacts based upon this position, and
	       % wether the player is a Pacman or Ghost
	       case O
	       of 'wall' then
		  result(state:'active' nextPos:CurPos)
	       else

		  {Move Player CurPos NextPos}
		  
		  case Player.id
		  of pacman(id:_ color:_ name:_) then
		     case O
		     of 'point' then
			{EatPoint Player NextPos}
			result(state:'active' nextPos:NextPos)
			
		     [] 'bonus' then
			{EatBonus Player NextPos}
			result(state:'active' nextPos:NextPos)
			
		     [] player(port:_ id:ghost(id:_ color:_ name:_)) then
			result(state:'active' nextPos:NextPos)
		     else
			result(state:'active' nextPos:NextPos)
		     end
		     
		  [] ghost(id:_ color:_ name:_) then
		     case O
		     of player(port:_ id:pacman(id:_ color:_ name:_)) then
			result(state:'active' nextPos:NextPos)
		     else
			result(state:'active' nextPos:NextPos)
		     end
		  end
	       end
	    end
	 end
      end
   end

   fun {GetSpawn PlayerID}
      case PlayerID of pacman(id:IDp color:_ name:_) then
	 SpawnsP.IDp
      [] ghost(id:IDg color:_ name:_) then
	 SpawnsG.IDg
      end
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% HELPER FUNCTIONS FOR TURN-BY-TURN %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Sends a first ordered shot of message from
   % player asking to start their turn, following
   % the 'Order' order.
   proc {Start Order}
      case Order of H|T then
	 {Send PortMain start(H)}
	 {Start T}
      [] nil then skip
      end
   end
   
   proc {ReadStreamMain St}
      local Play in
	 
	 proc {Play Player CurPos}
	    local Result in
	       Result = {Turn Player CurPos}
	       if Result.state == 'active' then
		  {Send PortMain replay(Player Result.nextPos)}
	       elseif Result.state == 'idle' then
		  local RespawnTime in
		     case Player.id of pacman(id:_ color:_ name:_) then
			RespawnTime = Input.respawnTimePacman-1
		     else
			RespawnTime = Input.respawnTimeGhost-1
		     end
		     {Send PortMain idle(Player RespawnTime)}
		  end
	       elseif Result.state == 'dead' then
		  skip
	       end
	    end
	 end
	 
	 case St of H|T then
	    case H

	    % First turn of a player   
	    of start(Player) then
	       {Play Player {GetSpawn Player.id}}

	    % Player can replay   
	    [] replay(Player CurPos) then
	       %if {Stack.contains Board.(CurPos.y).(CurPos.x) Player} then
	       {Play Player CurPos}
	       % Player has been killed before it's turn	  
	       %else
		%  skip
	       %end
  
	    [] idle(Player N) then
	       % Player can be respawn, and replay
	       if (N==0) then
		  {Respawn Player {GetSpawn Player.id}}
		  {Play Player {GetSpawn Player.id}}
	       % Player is idle
	       else
		  {Send PortMain idle(Player N-1)}
	       end

	    [] spawnPoint(Pos N) then
	       % Point can be respawn
	       if (N==0) then
		  {Stack.push Board.(Pos.y).(Pos.x) 'point'}
		  {Send WindowPort spawnPoint(Pos)}
		  {Send PortPacmans pointSpawn(Pos)}
	       % Point stay hidden	  
	       else  
		  {Send PortMain spawnPoint(Pos N-1)}
	       end
	    
	    [] spawnBonus(Pos N) then
	       % Bonus can be respawn
	       if (N==0) then
		  {Stack.push Board.(Pos.y).(Pos.x) 'bonus'}
		  {Send WindowPort spawnBonus(Pos)}
		  {Send PortPacmans bonusSpawn(Pos)}
	       % Bonus stay hidden  
	       else
		  {Send PortMain spawnBonus(Pos N-1)}
	       end
	       
	    [] huntTime(N) then
	       % HuntTime is over
	       if (N==0) then
		  HuntMode:=false
		  {Send WindowPort setMode('classic')}
		  {Send PortPacmans setMode('classic')}
		  {Send PortGhosts setMode('classic')}
	       % HuntTime continues  
	       else
		  {Send PortMain huntTime(N-1)}
	       end
		  
	    end
	    {ReadStreamMain T}
	 [] nil then
	    {Send WindowPort displayWinner(Order.1.2)}
	 end
      end
   end

   proc {ReadStreamPlayers Stream ListPlayer}
      local TellPlayer in
	 
	 proc {TellPlayer ListPlayer Message }
	    case ListPlayer of H|T then
	       {Send H.port Message}
	       {TellPlayer T Message}
	    [] nil then skip
	    end
	 end

	 case Stream of H|T then
	    {TellPlayer ListPlayer H}
	    {ReadStreamPlayers T ListPlayer}
	 end
      end    
   end
   
%%%%%%%%%%%%
%%% MAIN %%%
%%%%%%%%%%%%

   % Create port for window
   WindowPort = {GUI.portWindow}

   % Open window
   {Send WindowPort buildWindow}

   % Create port objects for Main, Pacmans and Ghosts
   {NewPort StreamMain PortMain}
   {NewPort StreamPacmans PortPacmans}
   {NewPort StreamGhosts PortGhosts}

   % Create random order between players
   Pacmans = {Shuffle {InitPlayers 'P'} Input.nbPacman}
   Ghosts  = {Shuffle {InitPlayers 'G'} Input.nbGhost}
   Order = {Shuffle {List.append Pacmans Ghosts} Input.nbPacman+Input.nbGhost}

   % Create local dynamic Board
   Board = {CreateMap Input.nRow Input.nColumn}

   % Useful variables
   NbPlayer = Input.nbPacman + Input.nbGhost
   HuntMode = {NewCell false}
   SpawnsP = {Tuple.make 's' Input.nbPacman}
   SpawnsG = {Tuple.make 's' Input.nbGhost}
   
   % Initialize and spawn players/items on GUI & local Board
   {FirstSpawns Input.map WindowPort {NewCell Pacmans} {NewCell Ghosts}}

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
   
   if Input.isTurnByTurn then
   
      {Start Order}
   
      thread
	 {ReadStreamMain StreamMain}
      end
      thread
	 {ReadStreamPlayers StreamPacmans Pacmans}
      end
      thread
	 {ReadStreamPlayers StreamGhosts Ghosts}
      end
	 
   else
      skip
   end

end
