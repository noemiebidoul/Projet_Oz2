functor
export
   new:New
   push:Push
   peek:Peek
   pop:Pop
   isEmpty:IsEmpty
   erase:Erase
define
   New
   Push
   Peek
   Pop
   IsEmpty
   Erase
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
      case @S of H|T then
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
	    end
	 end
	 S := {Remove @S X}
      end
   end

end
