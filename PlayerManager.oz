%% Player Manager %%
functor
import
   Pacman000random
   Ghost000random
   Pacman020Controlled
   Pacman123name
   Ghost123name
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   % Kind is one valid name to describe the wanted player, ID is either the <pacman> ID, either the <ghost> ID corresponding to the player
   fun{PlayerGenerator Kind ID}
      case Kind
      of pacman000random then {Pacman000random.portPlayer ID}
      [] ghost000random then {Ghost000random.portPlayer ID}
      [] pacman020Controlled then {Pacman020Controlled.portPlayer ID}
      [] pacman123name then {Pacman123name.portPlayer ID}
      [] ghost123name then {Ghost123name.portPlayer ID}
      end
   end
end
