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
   
   IsTurnByTurn = false

%%%% Description of the map %%%%
   
   NRow = 7
   NColumn = 12
   Map = [[1 1 1 1 1 1 1 1 1 1 1 1]
	  [1 0 0 4 0 0 3 0 0 0 0 1]
	  [1 2 1 1 1 0 1 1 0 1 0 1]
	  [1 0 0 0 1 0 0 1 0 1 0 1]
	  [1 0 1 0 1 1 0 1 0 1 0 1]
	  [1 0 1 4 2 4 0 0 0 0 0 1]
	  [1 1 1 1 1 1 1 1 1 1 1 1]]

%%%% Respawn times %%%%
   
   RespawnTimePoint = 7000
   RespawnTimeBonus = 15000
   RespawnTimePacman = 5000
   RespawnTimeGhost = 5000

%%%% Rewards and penalities %%%%

   RewardPoint = 1
   RewardKill = 5
   PenalityKill = 5

%%%%

   NbLives = 2
   HuntTime = 50000
   
%%%% Players description %%%%

   NbPacman = 2
   Pacman = [pacman091smart pacman091smart]
   ColorPacman = [yellow red]
   NbGhost = 1
   Ghost = [ghost091smart]
   ColorGhost = [green]% black red white]

%%%% Thinking parameters (only in simultaneous) %%%%
   
   ThinkMin = 500
   ThinkMax = 3000
   
end
