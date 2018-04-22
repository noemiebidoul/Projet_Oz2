functor
export
   new:New
   push:Push
   peek:Peek
   pop:Pop
   isEmpty:IsEmpty
define
   New
   Push
   Peek
   Pop
   IsEmpty
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

   fun {Pop S}
      case @S of H|T then
	 S:=T
	 H
      else
	 nil
      end
   end

   fun {IsEmpty S}
      @S==nil
   end

end
