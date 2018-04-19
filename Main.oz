%% Main %%
functor
import
   Tk
   GUI
   Input
   PlayerManager
   Browser
   OS
define
   WindowPort
   InitPlayers
   FirstSpawns
   Pacmans
   Ghosts
   Order
   Shuffle
   Nth
   PortMain
   Stream
   NbPlayer
   Start
   ReadStream
   Turn
   W
   F
   BrowserObject
in

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

   fun {Shuffle L Length}
      local E Tail N in
	 case L
	 of nil then nil
	 else
	    N = ({OS.rand} mod Length) + 1
	    Tail = {Nth L N E}
	    E|{Shuffle Tail Length-1}
	 end
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
		  Port#ID|{Aux T1#T2 I+1}
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
	    local ID Pos in

	       % Walkable place i.e. spawn for point
	       if H==0 then
		  {Send WindowPort initPoint(P)}
		  {Send WindowPort spawnPoint(P)}

               % Spawn for pacman  
	       elseif H==2 then
		  case @ToSpawnP
		  of nil then skip % Each pacman already has a spawn
		  [] (P1|P2) then
		     {Send WindowPort initPacman(P1.2)}
		     {Send WindowPort spawnPacman(P1.2 P)}
		     {Send P1.1 assignSpawn(P)}
		     {Send P1.1 spawn(ID Pos)}

		     ToSpawnP := P2
		  
		  end

	       % Spawn for ghost
	       elseif H==3 then
		  case @ToSpawnG
		  of nil then skip % Each ghost already has a spawn
		  [] G1|G2 then
		     {Send WindowPort initGhost(G1.2)}
		     {Send WindowPort spawnGhost(G1.2 P)}
		     {Send G1.1 assignSpawn(P)}
		     {Send G1.1 spawn(ID Pos)}

		     ToSpawnG := G2
		  
		  end

	       % Spawn for bonus
	       elseif H==4 then
		  {Send WindowPort initBonus(P)}
		  {Send WindowPort spawnBonus(P)}
	    
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
   
   proc {Start Order PortMain}
      local State in
	 case Order of H|T then
	    {Send PortMain start(H.2 State)}
	    case State
	    of 'active' then {Send PortMain wait(H.2 (NbPlayer-1))}
	    [] 'idle' then {Send PortMain idle(H.2 (Input.respawnTimePacman+1))}		    
	    end
	    {Start T PortMain}
	 [] nil then skip
	 end
      end
   end
 
   proc {ReadStream St PortMain}
      case St of H|T then
	 case H
	 % First turn of a player   
	 of start(ID State) then
	    State = {Turn ID}
	 % Player is re-playing   
	 [] begin(ID) then
	    local Result in
	       Result = {Turn ID}
	       if Result == 'active' then
		  {Send PortMain wait(ID (NbPlayer-1))}
	       elseif Result == 'idle' then
		  {Send PortMain idle(ID (Input.respawnTimePacman+1))}
	       elseif Result == 'dead' then
		  skip
	       end
	    end
	 % Player is waiting for it's turn   
	 [] wait(ID N) then
	    if (N==0) then
	       {Send PortMain begin(ID)}
	    else
	       {Send PortMain wait(ID N-1)}
	    end
	 % Player is idle   
	 [] idle(ID N) then
	    if (N==0) then
	       {Send PortMain begin(ID)}
	    else
	       {Send PortMain idle(ID N-1)}
	    end
	 end
	 {ReadStream T PortMain}
      [] nil then
	 {Send WindowPort displayWinner(Order.1.2)}
      end
   end

   fun {Turn ID}
      local N in
	 N = ({OS.rand} mod 2)
	 if N==1 then
	    'active'
	 else
	    'idle'
	 end
      end
   end
   
      % Create port for window
   WindowPort = {GUI.portWindow}

      % Open window
   {Send WindowPort buildWindow}

      % Create two lists of tuples 'Port#ID' for pacmans and ghosts respectively
      % (with random order)
   Pacmans = {Shuffle {InitPlayers 'P'} Input.nbPacman}
   Ghosts  = {Shuffle {InitPlayers 'G'} Input.nbGhost} 

      % Initialize and spawn players and items onto their positions
   {FirstSpawns Input.map WindowPort {NewCell Pacmans} {NewCell Ghosts}}

      % Define a random order between players (shuffling ghost and pacmans)
   Order = {Shuffle {List.append Pacmans Ghosts} Input.nbPacman+Input.nbGhost}

      % Creation of a Port object for the Main
   {NewPort Stream PortMain}
   NbPlayer = Input.nbPacman + Input.nbGhost

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
   {BrowserObject browse([Order Stream])}
   
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
