functor
export
   new:New
   push:Push
   peek:Peek
   pop:Pop
   isEmpty:IsEmpty
   erase:Erase
   contains:Contains
define
   New
   Push
   Peek
   Pop
   IsEmpty
   Erase
   Contains
in
   fun {New}
      {NewCell nil}
   end

   proc {Push S X}
      S := X|@S
   end

   fun {Peek S}
      case @S of H|_ then H
      else nil
      end
   end

   proc {Pop S}
      case @S of _|T then
	 S:=T
      else
	 skip
      end
   end

   fun {IsEmpty S}
      @S==nil
   end

   proc {Erase S X}
      local Remove in
	 fun {Remove L X}
	    case L
	    of H|T then
	       if H==X then T
	       else
		  H|{Remove T X}
	       end
	    [] nil then nil
	    end
	 end
	 S := {Remove @S X}
      end
   end

   fun {Contains S X}
      local Aux in
	 fun {Aux L X}
	    case L of H|T then
	       if H==X then true
	       else
		  {Aux T X}
	       end
	    [] nil then false
	    end
	 end
	 {Aux @S X}
      end
   end

end
