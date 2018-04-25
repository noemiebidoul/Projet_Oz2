%% Input %%
functor
export
   isTurnByTurn:IsTurnByTurn
   nRow:NRow
   nColumn:NColumn
   map:Map
   respawnTimePoint:RespawnTimePoint
   respawnTimeBonus:RespawnTimeBonus
   respawnTimePacman:RespawnTimePacman
   respawnTimeGhost:RespawnTimeGhost
   rewardPoint:RewardPoint
   rewardKill:RewardKill
   penalityKill:PenalityKill
   nbLives:NbLives
   huntTime:HuntTime
   nbPacman:NbPacman
   pacman:Pacman
   colorPacman:ColorPacman
   nbGhost:NbGhost
   ghost:Ghost
   colorGhost:ColorGhost
   thinkMin:ThinkMin
   thinkMax:ThinkMax
define
   IsTurnByTurn
   NRow
   NColumn
   Map
   RespawnTimePoint
   RespawnTimeBonus
   RespawnTimePacman
   RespawnTimeGhost
   RewardPoint
   RewardKill
   PenalityKill
   NbLives
   HuntTime
   NbPacman
   Pacman
   ColorPacman
   NbGhost
   Ghost
   ColorGhost
   ThinkMin
   ThinkMax
in

%%%% Style of game %%%%
   
   IsTurnByTurn = true

%%%% Description of the map %%%%
   
   NRow = 7
   NColumn = 12
   Map = [[1 1 1 1 1 1 1 1 1 1 1 1]
	  [1 0 0 0 0 0 0 0 0 0 0 1]
	  [1 0 1 1 1 0 1 1 0 1 0 1]
	  [1 0 0 0 1 0 0 1 0 1 0 1]
	  [1 2 1 0 1 1 0 1 0 1 0 1]
	  [1 3 1 0 1 1 0 0 2 0 0 1]
	  [1 1 1 1 1 1 1 1 1 1 1 1]]

%%%% Respawn times %%%%
   
   RespawnTimePoint = 4
   RespawnTimeBonus = 4
   RespawnTimePacman = 3
   RespawnTimeGhost = 3

%%%% Rewards and penalities %%%%

   RewardPoint = 1
   RewardKill = 5
   PenalityKill = 5

%%%%

   NbLives = 2
   HuntTime = 15
   
%%%% Players description %%%%

   NbPacman = 2
   Pacman = [pacman000random pacman000random]
   ColorPacman = [yellow red]
   NbGhost = 1
   Ghost = [ghost000random]
   ColorGhost = [green]% black red white]

%%%% Thinking parameters (only in simultaneous) %%%%
   
   ThinkMin = 500
   ThinkMax = 3000
   
end
