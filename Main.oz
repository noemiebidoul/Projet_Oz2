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
   Stream
   NbPlayer
   Start
   ReadStream
   Turn
   W
   F
   BrowserObject
   CreateMap
   Board
   HuntMode
   Spawns
   TellAll
   Respawn
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
   fun {InitPlayers Kind FirstI}
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
	    {Aux Input.pacman#Input.colorPacman FirstI}
	 else
	    {Aux Input.ghost#Input.colorGhost FirstI}
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
		  
		  {Stack.push Board.M.N 'point'}
		  
		  {Send WindowPort initPoint(P)}
		  {Send WindowPort spawnPoint(P)}

               % Spawn for pacman  
	       elseif H==2 then
		  case @ToSpawnP
		  of nil then skip % Each pacman already has a spawn
		  [] (P1|P2) then

		     Spawns.(P1.id.id) = P
		     %{Stack.push Board.M.N P1.id}
		     
		     {Send WindowPort initPacman(P1.id)}
		     %{Send WindowPort spawnPacman(P1.id P)}
		     {Send P1.port assignSpawn(P)}
		     %{Send P1.port spawn(ID Pos)}

		     {Respawn P1}

		     ToSpawnP := P2
		  
		  end

	       % Spawn for ghost
	       elseif H==3 then
		  case @ToSpawnG
		  of nil then skip % Each ghost already has a spawn
		  [] G1|G2 then

		     Spawns.(G1.id.id) = P
		     
		     {Send WindowPort initGhost(G1.id)}
		     %{Send WindowPort spawnGhost(G1.id P)}
		     {Send G1.port assignSpawn(P)}
		     %{Send G1.port spawn(ID Pos)}

		     {Respawn G1}
		     
		     ToSpawnG := G2
		  
		  end

	       % Spawn for bonus
	       elseif H==4 then

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

   % @PRE: 'K' the kind of player (either
   %           'P' or 'G'
   % @POST: Sends message M to all players
   %        of the list L
   proc {TellAll K M}
      local Aux in
	 proc {Aux L}
	    case L of H|T then
	       {Send H.port M}
	       {Aux T}
	    [] nil then skip
	    end
	 end
	 
	 if K=='P' then
	    {Aux Pacmans}
	 elseif K=='G' then
	    {Aux Ghosts}
	 end
      end
   end

   % @PRE: Player a record of type 'player(port:P id:ID)'
   % @POST: Spawns player onto it's spawn, on the GUI and
   %        on the local dynamic Board + warns the concerned
   %        player, and all the players of the opposite kind.
   proc {Respawn Player}
      local Spawn in
	 Spawn = Spawns.(Player.id.id)
	 
	 {Stack.push Board.(Spawn.y).(Spawn.x) Player.id}

	 case Player.id of pacman(id:_ color:_ name:_) then
	    {Send WindowPort spawnPacman(Player.id Spawn)}
	    {TellAll 'G' pacmanPos(Player.id Spawn)}
	 else
	    {Send WindowPort spawnGhost(Player.id Spawn)}
	    {TellAll 'P' ghostPos(Player.id Spawn)}
	 end

	 local ID P in
	    {Send Player.port spawn(ID P)}
	    
	 end
      end
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% HELPER FUNCTIONS FOR TURN-BY-TURN %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
   proc {Start Order PortMain}
      local State NextPos in
	 case Order of H|T then
	    {Send PortMain start(H State NextPos)}
	    case State
	    of 'active' then {Send PortMain wait(H (NbPlayer-1) NextPos)}
	    [] 'idle' then {Send PortMain idle(H (Input.respawnTimePacman+1))}		    
	    end
	    {Start T PortMain}
	 [] nil then skip
	 end
      end
   end
 
   proc {ReadStream St PortMain}
      case St of H|T then
	 {Delay 1000}
	 case H
	    
	 % First turn of a player   
	 of start(Player ?State ?NextPos) then
	    local Result in
	       Result = {Turn Player Spawns.(Player.id.id)}
	       NextPos = Result.2
	       State = Result.1
	    end
	    
	 % Player is re-playing   
	 [] begin(Player CurPos Reborn) then
	    if Reborn then
	       {Respawn Player}
	    end
	    local Result in
	       Result = {Turn Player CurPos}
	       if Result.1 == 'active' then
		  {Send PortMain wait(Player (NbPlayer-1) Result.2)}
	       elseif Result.1 == 'idle' then
		  {Send PortMain idle(Player (Input.respawnTimePacman+1))}
	       elseif Result.1 == 'dead' then
		  skip
	       end
	    end
	    
	 % Player is waiting for its turn   
	 [] wait(Player N CurPos) then
	    if (N==0) then
	       {Send PortMain begin(Player CurPos false)}
	    else
	       {Send PortMain wait(Player N-1 CurPos)}
	    end
	    
	 % Player is idle   
	 [] idle(Player N) then
	    if (N==0) then
	       {Send PortMain begin(Player Spawns.(Player.id.id) true)}
	    else
	       {Send PortMain idle(Player N-1)}
	    end
	 end
	 {ReadStream T PortMain}
      [] nil then
	 {Send WindowPort displayWinner(Order.1.2)}
      end
   end


%%%%%%%%%%%%
%%% MAIN %%%
%%%%%%%%%%%%
   
      % Create port for window
   WindowPort = {GUI.portWindow}

      % Open window
   {Send WindowPort buildWindow}

      % Create two lists of tuples 'Port#ID' for pacmans and ghosts respectively
      % (with random order)
   Pacmans = {Shuffle {InitPlayers 'P' 1} Input.nbPacman}
   Ghosts  = {Shuffle {InitPlayers 'G' Input.nbPacman+1} Input.nbGhost}

      % Creation of empty dynamic map
   Board = {CreateMap Input.nRow Input.nColumn}
   NbPlayer = Input.nbPacman + Input.nbGhost
   
      % Initialize and spawn players and items onto their positions
   Spawns = {Tuple.make 's' NbPlayer}
   {FirstSpawns Input.map WindowPort {NewCell Pacmans} {NewCell Ghosts}}

      % Define a random order between players (shuffling ghost and pacmans)
   Order = {Shuffle {List.append Pacmans Ghosts} Input.nbPacman+Input.nbGhost}

      % Creation of a Port object for the Main
   {NewPort Stream PortMain}

   HuntMode = {NewCell false}

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
   {BrowserObject browse([Order Spawns])}
   
   if Input.isTurnByTurn then
   
      thread
	 {Start Order PortMain}
      end
   
      thread
	 {ReadStream Stream PortMain}
      end
	 
   else
      skip
   end

end
