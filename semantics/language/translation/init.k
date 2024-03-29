module C-TRANSLATION-INIT-SYNTAX
     syntax K ::= load(Bag, Bag)
     syntax K ::= "link" | "cleanup"

     syntax TransOpts ::= "DEBUG" | "NOLINK"

endmodule

module C-TRANSLATION-INIT
     imports C-TRANSLATION-INIT-SYNTAX

     imports C-BUILTIN-SYNTAX
     imports C-DECL-DEFINITION-SYNTAX
     imports C-DECL-GLOBAL-SYNTAX
     imports C-DECL-INITIALIZER-SYNTAX
     imports C-DECL-RESOLUTION-SYNTAX
     imports C-DYNAMIC-SYNTAX
     imports C-ENV-SYNTAX
     imports C-ERROR-SYNTAX
     imports C-FUNCTION-DEF-SYNTAX
     imports C-SYMLOC-SYNTAX
     imports C-SYNTAX
     imports C-TYPING-COMPATIBILITY-SYNTAX
     imports C-TYPING-SYNTAX
     imports DEBUG-SYNTAX
     imports C-CONFIGURATION

     imports COMPAT-SYNTAX

     rule <k> link
               => TranslationUnit("builtin", list(.List),
                    list(ListItem(addBuiltins(builtins))))
               ~> resolveReferences
               ~> printSuccess
          ...</k>
          <options> Opts:Set </options>
          when notBool (NOLINK in Opts)

     rule load(Obj1:Bag, Obj2:Bag)
               => checkMerge(Obj1, Obj2)
               ~> load'(mergeObj(Obj1, Obj2))

     syntax K ::= "load'" "(" Bag ")"
     rule <k> load'(Merged:Bag)
               => checkMerge(Merged, <global> ThisObj </global>)
               ~> loadObj(mergeObj(Merged, <global> ThisObj </global>))
          ...</k>
          <global> ThisObj:Bag </global>

     rule <k> link => printSuccess ...</k>
          <options> SetItem(NOLINK) ...</options>

     rule (<T>...
               <k> cleanup </k>
               <options> Opts:Set </options>
          ...</T> => .Bag)
          when notBool (DEBUG in Opts)
          [structural]

     // TODO(chathhorn): prevent duplicate TUs or TU name clashes.
     rule <k> TranslationUnit(TU:String, list(Strings:List), list(Decls:List)) 
               => preDeclareStrings(Strings)
               ~> listToK(Decls)
               ~> LoopExtract
               ~> allocateIncompleteTentatives
          ...</k>
          <curr-tu> _ => TU </curr-tu>
          <translation-units>...
               (.Bag => <tu>...
                    <tu-id> TU </tu-id>
                    <next-link-loc> 0 @ link(TU) </next-link-loc>
                    <next-static-loc> 0 @ static(TU) </next-static-loc>
               ...</tu>)
          ...</translation-units>
          [structural]

     syntax K ::= preDeclareStrings(List)

     rule preDeclareStrings(ListItem(K:K) L:List)
          => allowInit(K ~> discard)
          ~> preDeclareStrings(L)
          [structural]
     rule preDeclareStrings(.List) => .K
          [structural]

     syntax K ::= addBuiltins(Map)

     // Only add a builtin if it has an external type (that is, it's been
     // declared somewhere) and if it doesn't already have a definition.
     // Therefore, if someone redefines a builtin, we won't co-opt it (although
     // redefining it should probably be an error).
     rule <k> (.K => declare(
               typedDeclaration(T, Identifier(B)), 
               initializer(initFunction(
                    &(Identifier(B)),
                    functionObject(Identifier(B), .List, T, handleBuiltin)
               ))))
               ~> addBuiltins((B:String |-> T:Type => .Map) _)
          ...</k>
          <external-types>... Identifier(B) |-> _ ...</external-types>
          <external-defs> Defs:Map </external-defs>
          when notBool Identifier(B) in keys(Defs)

     rule <k> addBuiltins((B:String |-> _ => .Map) _) ...</k>
          <external-types> Types:Map </external-types>
          <external-defs> Defs:Map </external-defs>
          when (Identifier(B) in keys(Defs))
               orBool (notBool Identifier(B) in keys(Types))
     rule addBuiltins(.Map) => .

     syntax K ::= checkMerge(Bag, Bag)
     rule checkMerge(_, .Bag) => .
     rule checkMerge(.Bag, _) => .
     rule checkMerge(
          (<global>...
               <external-types>... X:CId |-> _ => .Map </external-types>
          ...</global>),
          (<global>...
               <external-types> Types:Map </external-types>
          ...</global>))
          when notBool (X in keys Types)
     rule checkMerge(
          (<global>...
               <external-defs>... X:CId |-> _ => .Map </external-defs>
          ...</global>),
          (<global>...
               <external-defs> Defs:Map </external-defs>
          ...</global>))
          when notBool (X in keys Defs)
     rule checkMerge(
          (<global>...
               <external-types> Types:Map </external-types>
          ...</global>),
          (<global>...
               <external-types>... X:CId |-> _ => .Map </external-types>
          ...</global>))
          when notBool (X in keys Types)
     rule checkMerge(
          (<global>...
               <external-defs> Defs:Map </external-defs>
          ...</global>),
          (<global>...
               <external-defs>... X:CId |-> _ => .Map </external-defs>
          ...</global>))
          when notBool (X in keys Defs)
     rule checkMerge(
          (<global>...
               <external-types>... X:CId |-> T:Type => .Map </external-types>
          ...</global>),
          (<global>...
               <external-types>... X |-> T':Type => .Map </external-types>
          ...</global>))
          when areCompatible(T, T')
     rule checkMerge(
          (<global>...
               <external-types> .Map </external-types>
               <external-defs> .Map </external-defs>
          ...</global>),
          (<global>...
               <external-types> .Map </external-types>
               <external-defs> .Map </external-defs>
          ...</global>)) => .
     rule (. => UNDEF("TIN1",
               "Identifier " +String idToString(X) +String " declared with incompatble types in different translation units.",
               "6.2.7:2"))
          ~> checkMerge(
          (<global>...
               <external-types>... X:CId |-> T:Type  ...</external-types>
          ...</global>),
          (<global>...
               <external-types>... X |-> T':Type  ...</external-types>
          ...</global>))
          when notBool areCompatible(T, T')
     rule (. => UNDEF("TIN2",
               "Multiple external definitions for " +String idToString(X) +String ".",
               "6.9"))
          ~> checkMerge(
          (<global>...
               <external-defs>... X:CId |-> _ ...</external-defs>
          ...</global>),
          (<global>...
               <external-defs>... X |-> _  ...</external-defs>
          ...</global>))

     // TODO(chathhorn): should fix this so it doesn't create duplicates keys
     // in the external-types cell. I'm not entirely sure what the right fix
     // is, though -- I suppose it must be to take the composite type. It's not
     // terribly important, though, this is just to catch incompatible
     // declarations across TUs, so duplicates vs. composite types probably
     // doesn't change too much.
     syntax Bag ::= mergeObj(Bag, Bag) [function]
     rule mergeObj(B:Bag, .Bag) => B
     rule mergeObj(.Bag, B:Bag) => B
     rule mergeObj(
          (<global>
               <mem> M1:Map </mem>
               <functions> F1:Map </functions>

               <external-types> ExtTypes1:Map </external-types>
               <external-defs> ExtDefs1:Map </external-defs>

               <linking-state>
                    <external-decls> ExtDecls1:Map </external-decls>
                    <external-uses> ExtUses1:Set </external-uses>
               </linking-state>

               <linkings> Links1:Map </linkings>

               <main-tu> Main1:Set </main-tu>
	       <patch-unit> Patch1:Set </patch-unit>
            <ptr-map> Rho11:Map </ptr-map>
			<meettimes> I1:Int </meettimes>

               <translation-units> TUs1:Bag </translation-units>
          </global>),
          (<global>
               <mem> M2:Map </mem>
               <functions> F2:Map </functions>

               <external-types> ExtTypes2:Map </external-types>
               <external-defs> ExtDefs2:Map </external-defs>

               <linking-state>
                    <external-decls> ExtDecls2:Map </external-decls>
                    <external-uses> ExtUses2:Set </external-uses>
               </linking-state>

               <linkings> Links2:Map </linkings>

               <main-tu> Main2:Set </main-tu>
			<patch-unit> Patch2:Set </patch-unit>
            <ptr-map> Rho12:Map </ptr-map>
			<meettimes> I2:Int </meettimes>
			
               <translation-units> TUs2:Bag </translation-units>
          </global>))
          =>
          <global>
               <mem> M1 M2 </mem>
               <functions> F1 F2 </functions>

               <external-types> ExtTypes1 ExtTypes2 </external-types>
               <external-defs> ExtDefs1 ExtDefs2 </external-defs>

               <linking-state>
                    <external-decls> ExtDecls1 ExtDecls2 </external-decls>
                    <external-uses> ExtUses1 ExtUses2 </external-uses>
               </linking-state>

               <linkings> Links1 Links2 </linkings>

               <main-tu> Main1 Main2 </main-tu>
	       <patch-unit> Patch1 Patch2 </patch-unit>
            <ptr-map> Rho11 Rho12 </ptr-map>
			<meettimes> I1 +Int I2 </meettimes>

               <translation-units> TUs1 TUs2 </translation-units>
          </global>

     syntax K ::= "printSuccess"
     rule printSuccess => #write(#stdout, "Translation successful!\n")


	rule  (HALT => .K) ~> checkMerge(
          (<global>...
               <external-types>... X:CId |-> t(Q:Set,structType(Y:CId,I:Int,_)) => .Map </external-types>
          ...</global>),
          (<global>...
               <external-types>... X |-> t(Q,structType(Y,I,_)) => .Map </external-types>
          ...</global>))
	

endmodule
