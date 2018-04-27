%% Player Manager %%
functor
import
   Pacman000random
   Pacman091smart
   Pacman020Controlled
   Pacman037Hungry
   Pacman055superSmart
   Ghost000random
   Ghost091smart
   Ghost037Angry
   Ghost047basic
   Ghost055other
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   % Kind is one valid name to describe the wanted player, ID is either the <pacman> ID, either the <ghost> ID corresponding to the player
   fun{PlayerGenerator Kind ID}
      case Kind
      of pacman000random then {Pacman000random.portPlayer ID}
      [] pacman091smart then {Pacman091smart.portPlayer ID}
      [] pacman020Controlled then {Pacman020Controlled.portPlayer ID}
      [] pacman037Hungry then {Pacman037Hungry.portPlayer ID}
      [] pacman055superSmart then {Pacman055superSmart.portPlayer ID}
      [] ghost091smart then {Ghost091smart.portPlayer ID}
      [] ghost000random then {Ghost000random.portPlayer ID}
      [] ghost037Angry then {Ghost037Angry.portPlayer ID}
      [] ghost047basic then {Ghost047basic.portPlayer ID}
      [] ghost055other then {Ghost055other.portPlayer ID}
      end
   end
end
