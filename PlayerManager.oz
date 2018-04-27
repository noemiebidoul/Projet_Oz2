%% Player Manager %%
functor
import
   Pacman123name
   Ghost123name
   Pacman091smart
   Ghost091smart
   Ghost037Angry
   Ghost047basic
   Ghost0055other
   Pacman0037Hungry
   Pacman047basic
   Pacman055superSmart
export
   playerGenerator:PlayerGenerator
define
   PlayerGenerator
in
   % Kind is one valid name to describe the wanted player, ID is either the <pacman> ID, either the <ghost> ID corresponding to the player
   fun{PlayerGenerator Kind ID}
      case Kind
      of pacman123name then {Pacman123name.portPlayer ID}
      [] ghost123name then {Ghost123name.portPlayer ID}
      [] pacman091smart then {Pacman091smart.portPlayer ID}
      [] ghost091smart then {Ghost091smart.portPlayer ID}
      [] ghost037Angry then {Ghost037Angry.portPlayer ID}
      [] ghost047basic then {Ghost047basic.portPlayer ID}
      [] ghost055other then {Ghost0055other.portPlayer ID}
      [] pacman037Hungry then {Pacman0037Hungry.portPlayer ID}
      [] pacman047basic then {Pacman047basic.portPlayer ID}
      [] pacman055superSmart then {Pacman055superSmart.portPlayer ID}
      end
   end
end
