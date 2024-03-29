module C-FUNCTION-DEF-SYNTAX
     syntax K ::= initFunction(K, K) [strict]
     syntax Bool ::= hasDupParams(Type) [function]
     syntax K ::= "declareM""(" K "," K ")"
endmodule

module C-FUNCTION-DEF
     imports C-FUNCTION-DEF-SYNTAX

     imports C-DECL-DEFINITION-SYNTAX
     imports C-DECL-INITIALIZER-SYNTAX
     imports C-DYNAMIC-SYNTAX
     imports C-ENV-SYNTAX
     imports C-ERROR-SYNTAX
     imports C-MEMORY-ALLOC-SYNTAX
     imports C-PROCESS-LABEL-SYNTAX
     imports C-SYMBOLIC-VALUE-SYNTAX
     imports C-SYMLOC-SYNTAX
     imports C-SYNTAX
     imports C-TYPING-SYNTAX
     imports C-BINDING-SYNTAX

     imports COMPAT-SYNTAX

     rule <k> FunctionDefinition(typedDeclaration(T:Type, Identifier(S:String)), Blk:K)
          => declare(
               typedDeclaration(toPrototype(T), Identifier(S)),
               initializer(initFunction(
                    &(Identifier(S)),
                    functionObject(Identifier(S),
                         // The sanitized declared parameters.
                         elideList(getParams(emptyToVoid(T))),
                         // The "prototype" -- basically a type with the same
                         // parameters as above, but the parameters are set to
                         // .List if there isn't actually a prototype.
                         toPrototype(T),
                         Goto(funLabel(Identifier(S))))
               ))
          )
          ~> calculateGotoMap(Identifier(S), Label(funLabel(Identifier(S)), safeBody(Identifier(S), Blk)))
          ~> processFunDef(Identifier(S), Blk)
          ~> declareM(typedDeclaration(t(.Set,pointerType(T)),Identifier(S +String "_ptr")),SingleInit(Identifier(S)))    //declare a global for each function
 	  ... </k>
	  <patch-tu> .Set </patch-tu>
	  <cap-points> .Set => SetItem(Identifier(S)) ... </cap-points>
          when isFunctionType(T) andBool notBool hasDupParams(T) andBool (notBool(S ==String "main"))
          [structural]

     rule <k> FunctionDefinition(typedDeclaration(T:Type, Identifier(S:String)), Blk:K)
          => declare(
               typedDeclaration(toPrototype(T), Identifier(S)),
               initializer(initFunction(
                    &(Identifier(S)),
                    functionObject(Identifier(S),
                         // The sanitized declared parameters.
                         elideList(getParams(emptyToVoid(T))),
                         // The "prototype" -- basically a type with the same
                         // parameters as above, but the parameters are set to
                         // .List if there isn't actually a prototype.
                         toPrototype(T),
                         Goto(funLabel(Identifier(S))))
               ))
          )
          ~> calculateGotoMap(Identifier(S), Label(funLabel(Identifier(S)), safeBody(Identifier(S), Blk)))
          ~> processFunDef(Identifier(S), Blk)
       ... </k>
       <patch-tu> .Set </patch-tu>
       <cap-points> .Set => SetItem(Identifier(S)) ... </cap-points>
          when isFunctionType(T) andBool notBool hasDupParams(T) andBool (S ==String "main")
          [structural]

     rule <k> FunctionDefinition(typedDeclaration(T:Type, Identifier(S:String)), Blk:K)
          => declare(
               typedDeclaration(toPrototype(T), Identifier(S)),
               initializer(initFunction(
                    &(Identifier(S)),
                    functionObject(Identifier(S),
                         // The sanitized declared parameters.
                         elideList(getParams(emptyToVoid(T))),
                         // The "prototype" -- basically a type with the same
                         // parameters as above, but the parameters are set to
                         // .List if there isn't actually a prototype.
                         toPrototype(T),
                         Goto(funLabel(Identifier(S))))
               ))
          )
          ~> calculateGotoMap(Identifier(S), Label(funLabel(Identifier(S)), safeBody(Identifier(S), Blk)))
          ~> processFunDef(Identifier(S), Blk) 
          ~> declareM(typedDeclaration(t(.Set,pointerType(T)),Identifier(S +String "_ptr")),SingleInit(Identifier(S)))    //declare a global for each function
	  ... </k>
	  <tu-id> Patch:String </tu-id>
	  <patch-tu> SetItem(Patch) </patch-tu>
          when isFunctionType(T) andBool notBool hasDupParams(T)
          [structural]

     rule <k> declareM(K1:K, SingleInit(Identifier(S:String))) => declare(K1,SingleInit(Identifier(S))) ... </k>
          <ptr-map> Rho:Map(.Map => Identifier(S) |-> Identifier(S +String "_ptr")) </ptr-map>
          when notBool(Identifier(S) in keys(Rho)) 

     rule (. => ERROR("FD1", "duplicate parameters in "
               +String "function definition."))
          ~> FunctionDefinition(typedDeclaration(T:Type, _), _)
          when hasDupParams(T)

     // TODO(chathhorn): possibly check that old-style declarations are
     // promoted types?

     // Turns empty param list into void and turns an old-style param list into
     // the empty list so that arguments will be promoted on call.
     syntax Type ::= toPrototype(Type) [function]
     rule toPrototype(T:Type) => elideDeclParams(emptyToVoid(T))
          when notBool isOldStyleFunctionType(T)
     rule toPrototype(T:Type) => setParams(T, .List)
          when isOldStyleFunctionType(T)

     syntax Type ::= emptyToVoid(Type) [function]
     rule emptyToVoid(T:Type)
          => setParams(T, ListItem(typedDeclaration(t(.Set, void), #NoName)))
          when isFunctionType(T)
               andBool (getParams(T) ==List .List)
     rule emptyToVoid(T:Type) => T
          when notBool isFunctionType(T)
               orBool (getParams(T) =/=List .List)

     syntax K ::= processFunDef(CId, K)
     rule <k> processFunDef(X:CId, Blk:K)
               => checkFunDefType(X, Proto)
               ~> staticEval(X, Params, Blk)
          ...</k>
          <env>... X |-> Base:SymBase ...</env>
          <functions>...
               Base |-> functionObject(_, Params:List, Proto:Type, _)
          ...</functions>
          [structural]

     syntax K ::= checkFunDefType(CId, Type)
     rule checkFunDefType(X:CId, T:Type) => .
          when notBool isFunctionType(getReturn(T))
               andBool notBool isArrayType(getReturn(T))
               andBool areVoidOrComplete(getParams(T))
               andBool (X =/=K Identifier("main"))
          [structural]
     rule checkFunDefType(X:CId, T:Type) => checkMainDef(T)
          when isVoidOrComplete(getReturn(T))
               andBool areVoidOrComplete(getParams(T))
               andBool (X ==K Identifier("main"))
          [structural]
     rule (. => UNDEF("FD2", "invalid return type in function definition.",
               "6.7.6.3:1"))
          ~> checkFunDefType(_, T:Type)
          when isFunctionType(getReturn(T)) orBool isArrayType(getReturn(T))
          [structural]
     rule (. => UNDEF("FD3", "incomplete parameter type in "
               +String "function definition.", "6.7.6.3:4"))
          ~> checkFunDefType(_, T:Type)
          when notBool areVoidOrComplete(getParams(T))
          [structural]

     syntax Bool ::= isVoidOrComplete(Type) [function]
     rule isVoidOrComplete(T:Type)
          => isCompleteType(T)
          orBool isVoidType(T)
          orBool isIncompleteArrayType(T)

     syntax Bool ::= areVoidOrComplete(List) [function]
     rule areVoidOrComplete(L:List) => all(L, 'isVoidOrComplete) ==K true

     syntax K ::= checkMainDef(Type)
     rule checkMainDef(t(_, functionType(t(_, int),
               ListItem(t(_, void)))))
          => .
          [structural]
     rule checkMainDef(t(_, functionType(t(_, int),
               ListItem(t(_, int)) ListItem(T:Type))))
          => .
          when #isArgvType(T) ==K true
          [structural]
     rule (. => ERROR("FD4", "definition of main requires a prototype (5.1.2.2.1p1)."))
          ~> checkMainDef(T:Type)
          when isOldStyleFunctionType(T)
          [structural]
     rule (. => ERROR("FD5", "main must return an int.", 4) )
          ~> checkMainDef(t(_, functionType(t(_, T:SimpleType), _)))
          when T =/=K int
          [structural]
     rule (. => ERROR("FD6", "if main has arguments, the type of the first argument must be equivalent to int.", 4) )
          ~> checkMainDef(t(_, functionType(_, ListItem(t(_, T:SimpleType)) _)))
          when T =/=K int andBool T =/=K void
          [structural]
     rule (. => ERROR("FD7", "if main has arguments, the type of the second argument must be equivalent to char**.") )
          ~> checkMainDef(t(_, functionType(_, ListItem(_:Type) ListItem(T:Type))))
          when #isArgvType(T) =/=K true
          [structural]
     rule (. => ERROR("FD8", "main must have zero or two parameters.") )
          ~> checkMainDef(t(_, functionType(_, Params:List)))
          when lengthList(Params) >Int 2
          [structural]
     rule (. => ERROR("FD9", "main must have zero or two parameters.") )
          ~> checkMainDef(t(_, functionType(_, ListItem(t(_, T:SimpleType)))))
          when T =/=K void
          [structural]

     syntax Bool ::= "#isArgvType" "(" Type ")" [function]
     rule #isArgvType(t(_, incompleteArrayType(t(_, pointerType(t(_, T:SimpleType))))))
          => true
          when T ==K char // char is an alias.
     rule #isArgvType(t(_, pointerType(t(_, pointerType(t(_, T:SimpleType))))))
          => true
          when T ==K char

     rule <k> initFunction(
               tv(Loc:SymLoc, t(_, pointerType(T:Type))), Fun:KResult)
               => .
          ...</k>
          <functions> M:Map => M[Fun <- base(Loc)] </functions>
          when isFunctionType(T) andBool (notBool base(Loc) in keys(M))
          [structural]

     syntax K ::= safeBody(CId, K) [function]

     rule safeBody(X:CId, Blk:K)
          => Blk ~> Return(NothingExpression)
          when X =/=K Identifier("main")
     rule safeBody(Identifier("main"), Blk:K)
          => Blk ~> Return(tv(0, t(.Set, int)))

     syntax K ::= "returnToFileScope"

     syntax K ::= staticEval(CId, List, K)
     rule <k> staticEval(X:CId, Params:List, Blk:K)
               => pushBlock
               ~> dummyBind(Params)
               ~> Blk
               ~> popBlock
               ~> returnToFileScope
          ...</k>
          <curr-function> _ => X </curr-function>
          [structural]

     rule <k> returnToFileScope => . ...</k>
          <curr-function> _ => file-scope </curr-function>
          [structural]

     syntax Bool ::= "#hasDupParams'" "(" Type ")" [function]
     rule hasDupParams(T:Type) => #hasDupParams'(T) ==K true
     rule #hasDupParams'(typedDeclaration(T:Type, _)) => #hasDupParams'(T)
     rule #hasDupParams'(t(_, functionType(_, P:List))) => #hasDupIds'(P)

     syntax Bool ::= hasDupIds(List) [function]
     syntax Bool ::= "#hasDupIds'" "(" List ")" [function]
     rule hasDupIds(P:List) => #hasDupIds'(P) ==K true
     rule #hasDupIds'(
               _
               ListItem(typedDeclaration(_, X:CId))
               _
               ListItem(typedDeclaration(_, X:CId))
               _
          ) => true

     syntax K ::= dummyBind(List)
     rule dummyBind(.List) => .
          [structural]
     rule dummyBind(ListItem(variadic)) => .
          [structural]
     rule dummyBind(ListItem(typedDeclaration(T:Type, _))) => .
          when isVoidType(T)
          [structural]
     rule dummyBind(ListItem(typedDeclaration(T:Type, X:CId)) Params:List)
          => addToEnv(X, symVal)
          ~> giveType(X, T)
          ~> dummyBind(Params)
          when notBool isVoidType(T)
          [structural]
endmodule
