module C-SYNTAX
     // TODO(chathhorn): context attr required to work around weird bug in 3.4.
     syntax K ::= reval(K) [klabel('reval), context(reval)]
     syntax K ::= "reval'" "(" K ")"
          [strict(all(context('reval), result(RValue))), klabel('reval')]

     // the rest are syntactic
     syntax C ::= AttributeWrapper(K, K) [klabel('AttributeWrapper)]

     syntax C ::= CId

     syntax KResult ::= SpecifierElem
  
     syntax C ::= CabsLoc
     syntax C ::= TypeSpecifier
     syntax C ::= Storage
     syntax C ::= CVSpecifier
     syntax C ::= SpecifierElem
     syntax C ::= Specifier
     syntax C ::= DeclType
     syntax C ::= NameGroup
     syntax C ::= FieldGroup
     syntax C ::= InitNameGroup
     syntax C ::= Name
     syntax C ::= InitName
     syntax C ::= SingleName
     syntax C ::= Block
     syntax C ::= Statement
     syntax C ::= PureStatement
     syntax C ::= PureEnumItem
     syntax C ::= ForClause
     syntax C ::= Expression
     syntax C ::= Constant
     syntax C ::= InitExpression
     syntax C ::= TranslationUnit
     syntax C ::= IntConstant
     syntax C ::= InitFragment
     syntax C ::= FieldName
     syntax C ::= PureDefinition

     // -------------------------------------------------
     // Below, I give the declaration as found in cabs.ml first, followed by
     // the K version

     /*
     type cabsloc = {
          lineno : int;
          filename: string;
          lineOffsetStart: int;
          lineOffsetEnd : int;
     }
     */
     syntax CabsLoc ::= CabsLoc(String, Int, Int, Int)
          [klabel('CabsLoc)]

     /*
     type typeSpecifier = (* Merge all specifiers into one type *)
     Tvoid                             (* Type specifier ISO 6.7.2 *)
     | Tchar
     | Tbool
     | Tshort
     | Tint
     | Tlong
     | Tint64
     | Tfloat
     | Tdouble
     | Tsigned
     | Tunsigned
     | Tnamed of string
     */
     syntax TypeSpecifier ::= "Void"
     syntax TypeSpecifier ::= "Char"
     syntax TypeSpecifier ::= "Bool"
     syntax TypeSpecifier ::= "Short"
     syntax TypeSpecifier ::= "Int"
     syntax TypeSpecifier ::= "Long"
     syntax TypeSpecifier ::= "Float"
     syntax TypeSpecifier ::= "Double"
     syntax TypeSpecifier ::= "Signed"
     syntax TypeSpecifier ::= "Unsigned"
     syntax Float ::= "inf"
     syntax TypeSpecifier ::= Named(CId) [klabel('Named)]
     /*
     (* each of the following three kinds of specifiers contains a field
     * or item list iff it corresponds to a definition (as opposed to
     * a forward declaration or simple reference to the type); they
     * also have a list of __attribute__s that appeared between the
     * keyword and the type name (definitions only) *)
     | Tstruct of String * field_group list option * attribute list
     | Tunion of String * field_group list option * attribute list
     | Tenum of String * enum_item list option * attribute list
     | TtypeofE of expression                      (* GCC __typeof__ *)
     | TtypeofT of specifier * decl_type       (* GCC __typeof__ *)
     */
     syntax TypeSpecifier ::= StructRef(CId)
          [klabel('StructRef)] // new
     // new // CId, List
     syntax C ::= StructDef(CId, K)
          [strict(2), klabel('StructDef)]
     syntax TypeSpecifier ::= UnionRef(CId)
          [klabel('UnionRef)] // new
     // new // CId, List
     syntax C ::= UnionDef(CId, K)
          [strict(2), klabel('UnionDef)]
     syntax TypeSpecifier ::= EnumRef(CId)
          [klabel('EnumRef)] // new
     // new // CId, List
     syntax C ::= EnumDef(CId, K)
          [klabel('EnumDef)]
     syntax TypeSpecifier ::= TypeofExpression(K)
          [klabel('TypeofExpression)]
     syntax TypeSpecifier ::= TypeofType(K, K)
          [klabel('TypeofType)]

     syntax TypeSpecifier ::= "Complex"
     syntax TypeSpecifier ::= "Imaginary"
     syntax TypeSpecifier ::= TAtomic(K, K)
          [klabel('TAtomic)]
     syntax TypeSpecifier ::= AlignasExpression(K)
          [klabel('AlignasExpression)]
     syntax TypeSpecifier ::= AlignasType(K, K)
          [klabel('AlignasType)]

     /*
     and storage =
     NO_STORAGE | AUTO | STATIC | EXTERN | REGISTER
     */
     // this will be used as the actual atomic modifier
     syntax Storage ::= "Atomic"
     syntax Storage ::= "NoStorage"
     syntax Storage ::= "Auto"
     syntax Storage ::= "Static"
     syntax Storage ::= "Extern"
     syntax Storage ::= "Register"
     syntax Storage ::= "ThreadLocal"

     /*
     and cvspec =
     CV_CONST | CV_VOLATILE | CV_RESTRICT
     */
     syntax CVSpecifier ::= "Const"
     syntax CVSpecifier ::= "Volatile"
     syntax CVSpecifier ::= "Restrict"

     /*
     and spec_elem =
     SpecTypedef
     | SpecCV of cvspec            (* const/volatile *)
     | SpecAttr of attribute       (* __attribute__ *)
     | SpecStorage of storage
     | SpecInline
     | SpecType of typeSpecifier
     | SpecPattern of String       (* specifier pattern variable *)
     */
     syntax SpecifierElem ::= "SpecTypedef"
     // the following are because I flattened SpecifierElem
     syntax SpecifierElem ::= CVSpecifier
     syntax SpecifierElem ::= Storage
     syntax SpecifierElem ::= "Inline"
     syntax SpecifierElem ::= "Noreturn"
     syntax SpecifierElem ::= TypeSpecifier
     syntax SpecifierElem ::= SpecPattern(CId)
          [klabel('SpecPattern)]

     /*
     and specifier = spec_elem list
     */
     syntax Specifier ::= Specifier(K) [avoid, klabel('Specifier)]

     /*
     and decl_type =
     | JUSTBASE          (* Prints the declared name *)
     | PARENTYPE of attribute list * decl_type * attribute list
               (* Prints "(attrs1 decl attrs2)".
                * attrs2 are attributes of the
                * declared identifier and it is as
                * if they appeared at the very end
                * of the declarator. attrs1 can
                * contain attributes for the
                * identifier or attributes for the
                * enclosing type.  *)
     | ARRAY of decl_type * attribute list * expression
               (* Prints "decl [ attrs exp ]".
                * decl is never a PTR. *)
     | PTR of attribute list * decl_type      (* Prints "* attrs decl" *)
     | PROTO of decl_type * single_name list * bool
               (* Prints "decl (args[, ...])".
                * decl is never a PTR.*)
     */
     syntax K ::= "JustBase"
     syntax DeclType ::= FunctionType(K)
          [klabel('FunctionType), strict]
     // third argument should also be strict, but not doing anything with
     // [strict 5] yet
     syntax DeclType ::= ArrayType(K, K, K)
          [klabel('ArrayType), strict(1)]
     syntax DeclType ::= PointerType(Specifier, K)
          [klabel('PointerType), strict(2)]
     // K, List, Bool
     syntax DeclType ::= Prototype(K, K, Bool)
          [klabel('Prototype), strict(1)]
     syntax DeclType ::= NoPrototype(K, K, Bool)
          [klabel('NoPrototype), strict(1, 2)]

     syntax K ::= "NotVariadic"
     syntax K ::= "Variadic"

     /*
     and name_group = specifier * name list
     */ // K, List
     syntax NameGroup ::= NameGroup(K, K) [klabel('NameGroup), strict]

     /*
     (* The optional expression is the bitfield *)
     and field_group = specifier * (name * expression option) list
     */ // K, List
     syntax FieldGroup ::= FieldGroup(K, K) [klabel('FieldGroup), strict(1)]
     syntax FieldName ::= FieldName(K) [klabel('FieldName)]
     syntax FieldName ::= BitFieldName(K, K) [klabel('BitFieldName)]

     /*
     (* like name_group, except the declared variables are allowed to have
     initializers *)
     (* e.g.: Int x=1, y=2; *)
     and init_name_group = specifier * init_name list
     */
     // K, List
     syntax InitNameGroup ::= "InitNameGroup" "(" K "," K ")"
          [klabel('InitNameGroup), strict(1)]

     /*
     The decl_type is in the order in which they are printed. Only the name of
     the declared identifier is pulled out. The attributes are those that are
     printed after the declarator
     (* e.g: in "int *x", "*x" is the declarator; "x" will be pulled out as *)
     (* the string, and decl_type will be PTR([], JUSTBASE) *)
     and name = String * decl_type * attribute list * cabsloc
     */
     // TODO(chathhorn): better solution?
     // first argument is id, second is basetype
     syntax Name ::= Name(K, K) [avoid, klabel('Name)]
     syntax CId ::= "#NoName" // new
     syntax CId ::= "#NoName" "(" Int ")" [klabel('#NoName)] // new
     syntax CId ::= Identifier(String) [klabel('Identifier)] // new

     /*
     (* A variable declarator ("name") with an initializer *)
     and init_name = name * init_expression
     */
     syntax InitName ::= "InitName" "(" K "," K ")" [klabel('InitName)]
     context InitName(_, (HOLE => reval'(HOLE))) [ndheat]

     /*
     (* Single names are for declarations that cannot come in groups, like
      * function parameters and functions *)
     and single_name = specifier * name
     */
     syntax SingleName ::= "SingleName" "(" K "," K ")"
          [klabel('SingleName), strict(1)]

     /*
     and enum_item = String * expression * cabsloc
     */
     // this one has no init
     syntax PureEnumItem ::= "EnumItem" "(" CId ")"
          [klabel('EnumItem)]
     // this one has an init
     syntax PureEnumItem ::= "EnumItemInit" "(" CId "," K ")"
          [klabel('EnumItemInit)]

     /*
     (*
     ** Declaration definition (at toplevel)
     *)
     and definition =
        FUNDEF of single_name * block * cabsloc * cabsloc
      | DECDEF of init_name_group * cabsloc (* variable(s), or function prototype *)
      | TYPEDEF of name_group * cabsloc
      | ONLYTYPEDEF of specifier * cabsloc
      | GLOBASM of String * cabsloc
      | PRAGMA of expression * cabsloc
      | LINKAGE of String * cabsloc * definition list (* extern "C" { ... } *)
      (* toplevel form transformer, from the first definition to the *)
      (* second group of definitions *)
      | TRANSFORMER of definition * definition list * cabsloc
      (* expression transformer: source and destination *)
      | EXPRTRANSFORMER of expression * expression * cabsloc
     */
     syntax PureDefinition ::= "FunctionDefinition" "(" K "," K ")"
          [klabel('FunctionDefinition), strict(1)]
     syntax PureDefinition ::= "DeclarationDefinition" "(" K ")"
          [klabel('DeclarationDefinition)]
     syntax PureDefinition ::= "Typedef" "(" K ")" [klabel('Typedef)]
     syntax PureDefinition ::= "OnlyTypedef" "(" K ")" [klabel('OnlyTypedef)]
     syntax PureDefinition ::= "GlobAsm" "(" String ")" [klabel('GlobAsm)]
     syntax PureDefinition ::= "Pragma" "(" K ")" [klabel('Pragma)]
     syntax PureDefinition ::= "Linkage" "(" String "," K ")"
          [klabel('Linkage)]
     syntax PureDefinition ::= "Transformer" "(" K "," K ")"
          [klabel('Transformer)]
     syntax PureDefinition ::= "ExpressionTransformer" "(" K "," K ")"
          [klabel('ExpressionTransformer)]

     syntax PureDefinition ::= StaticAssert(K, K)
          [klabel('StaticAssert)]

     // name
     syntax PureDefinition ::= "LTLAnnotation" "(" CId "," K ")"
          [klabel('LTLAnnotation)]

     /*
     (* the String is a file name, and then the list of toplevel forms *)
     and file = String * definition list
     */
     // name, code, source
     // new: Filename, strings, ast, code
     syntax TranslationUnit ::= TranslationUnit(String, K, K)
          [klabel('TranslationUnit)]

     /*
     (* A block contains a list of local label declarations ( GCC's ({ __label__
      * l1, l2; ... }) ) , a list of definitions and a list of statements  *)
     and block =
     { blabels: String list;
       battrs: attribute list;
       bstmts: statement list
     }
     */
     // Int, list, list
     syntax Block ::= "Block" "(" Int "," K "," K ")" [avoid, klabel('Block)]

     /*
     and statement =
     NOP of cabsloc
     | COMPUTATION of expression * cabsloc
     | BLOCK of block * cabsloc
     | SEQUENCE of statement * statement * cabsloc
     */
     syntax PureStatement ::= "Nop"
     syntax PureStatement ::= "Computation" "(" K ")"
          [strict(all(context('reval), result(RValue))), klabel('Computation), latex({{#1}};)]
     syntax PureStatement ::= "BlockStatement" "(" K ")"
          [klabel('BlockStatement)]
     syntax PureStatement ::= "Sequence" "(" K "," K ")"
          [klabel('Sequence)]

     /*
     | IF of expression * statement * statement * cabsloc
     | WHILE of expression * statement * cabsloc
     | DOWHILE of expression * statement * cabsloc
     | FOR of for_clause * expression * expression * statement * cabsloc
     */
     syntax PureStatement ::= "IfThenElse" "(" K "," K "," K ")"
          [strict(1(context('reval), result(RValue))), klabel('IfThenElse)]
     syntax PureStatement ::= "While" "(" K "," K ")"
          [klabel('While)]
     syntax PureStatement ::= "DoWhile" "(" K "," K ")"
          [klabel('DoWhile)]
     // id, ...
     syntax PureStatement ::= "For" "(" Int "," K "," K "," K "," K ")"
          [klabel('For)]

     /*
     | BREAK of cabsloc
     | CONTINUE of cabsloc
     | RETURN of expression * cabsloc
     */
     syntax PureStatement ::= "Break" [klabel('Break)]
     syntax PureStatement ::= "Continue" [klabel('Continue)]
     syntax PureStatement ::= "Return" "(" K ")" [strict(all(context('reval), result(RValue))), klabel('Return)]

     syntax PureStatement ::= "Itisupdatepatch" [klable('Itisupdatepatch)]
     syntax PureStatement ::= "Hereisend" [klable('Hereisend)]
     syntax PureStatement ::= "Updatepoint" [klable('Updatepoint)]
     syntax PureStatement ::= "Inupdatepoint" [klable('Inupdatepoint)]	
     syntax PureStatement ::= "Inducedpoint" [klable('Inducedpoint)]
     syntax PureStatement ::= "Updatedpoint" [klable('Updatedpoint)]

     /*
     | SWITCH of expression * statement * cabsloc
     | CASE of expression * statement * cabsloc
     | CASERANGE of expression * expression * statement * cabsloc
     | DEFAULT of statement * cabsloc
     */
     // unique switch id
     syntax PureStatement ::= "Switch" "(" K "," K "," K ")" [strict(2(context('reval), result(RValue))), klabel('Switch)]
     // unique switch id, unique case id, exp, statement
     syntax PureStatement ::= "Case" "(" Int "," Int "," K "," K ")"
          [klabel('Case)]
     // gcc extension
     syntax PureStatement ::= "CaseRange" "(" K "," K "," K ")"
          [klabel('CaseRange)]
     // unique switch id, statement
     syntax PureStatement ::= "Default" "(" Int "," K ")" [klabel('Default)]

     /*
     | LABEL of String * statement * cabsloc
     | GOTO of String * cabsloc
     | COMPGOTO of expression * cabsloc (* GCC's "goto *exp" *)
     | DEFINITION of definition (*definition or declaration of a variable or type*)
     */
     syntax PureStatement ::= "Label" "(" CId "," K ")" [avoid, klabel('Label)]
     syntax PureStatement ::= "Goto" "(" K ")" [klabel('Goto)] // CId
     syntax PureStatement ::= "CompGoto" "(" K ")" [klabel('CompGoto)]

     /*
     and for_clause =
     FC_EXP of expression
     | FC_DECL of definition
     */
     syntax ForClause ::= "ForClauseExpression" "(" K ")"
          [klabel('ForClauseExpression)]

     /*
     and binary_operator =
     ADD | SUB | MUL | DIV | MOD
     | AND | OR
     | BAND | BOR | XOR | SHL | SHR
     | EQ | NE | LT | GT | LE | GE
     | ASSIGN
     | ADD_ASSIGN | SUB_ASSIGN | MUL_ASSIGN | DIV_ASSIGN | MOD_ASSIGN
     | BAND_ASSIGN | BOR_ASSIGN | XOR_ASSIGN | SHL_ASSIGN | SHR_ASSIGN

     and expression =
     NOTHING
     */
     syntax Expression ::= "OffsetOf" "(" K "," K "," K ")"
          [klabel('OffsetOf), strict(1)]
     syntax Expression ::= "ExpressionLoc" "(" K "," K ")"
          [klabel('ExpressionLoc)]

     syntax Expression ::= "NothingExpression" [function]

     /*
     | UNARY of unary_operator * expression

     and unary_operator =
     MINUS | PLUS | NOT | BNOT | MEMOF | ADDROF
     | PREINCR | PREDECR | POSINCR | POSDECR
     */
     syntax Expression ::= "-" K [prec(22), strict(all(context('reval), result(RValue)))]
                         | "+" K [prec(22), strict(all(context('reval), result(RValue)))]
                         | "!" K [prec(22), strict(all(context('reval), result(RValue)))]
                         | "~" K [prec(22), strict(all(context('reval), result(RValue)))]
                         | "*" K [prec(22), strict(all(context('reval), result(RValue)))]
                         | "&" K [prec(22), strict]
                         | "++" K [prec(22), prefer, strict]
                         | "--" K [prec(22), prefer, strict, latex(\terminal{-{}-}{#1})]
                         | K "++" [prefer, strict]
                         | K "--" [prefer, strict, latex({#1}\terminal{-{}-})]
     /* | BINARY of binary_operator * expression * expression */
                         > K "*" K [prec(31), left]
                         | K "/" K [prec(31), left]
                         | K "%" K [prec(31), left]
                         > K "+" K [prec(33), left]
                         | K "-" K [prec(33), left]
                         > K "<<" K [prec(35), left, latex({{#1}}\ll{{#2}})]
                         | K ">>" K [prec(35), left, latex({{#1}}\gg{{#2}})]
                         > K "<" K [prec(37), left]
                         | K "<=" K [prec(37), left]
                         | K ">" K [prec(37), left]
                         | K ">=" K [prec(37), left]
                         > K "==" K [prec(39), left]
                         | K "!=" K [prec(39), left]
                         > K "&" K [prec(41), left]
                         > K "^" K [prec(43), left]
                         > K "|" K [prec(45), left]
                         > K "&&" K [prec(47), prefer, left]
                         > K "||" K [prec(49), left]
     /* | QUESTION of expression * expression * expression */
                         // Ternary operator is right-associative.
                         > K "?" K ":" K
                              [prec(51),gather(e & E), strict(1(context('reval), result(RValue)))]
                         > K "*=" K
                              [prec(53), strict(1, 2(context('reval), result(RValue)))]
                         | K "/=" K
                              [prec(53), strict(1, 2(context('reval), result(RValue)))]
                         | K "%=" K
                              [prec(53), strict(1, 2(context('reval), result(RValue)))]
                         | K "+=" K
                              [prec(53), strict(1, 2(context('reval), result(RValue)))]
                         | K "-=" K
                              [prec(53), strict(1, 2(context('reval), result(RValue)))]
                         | K "<<=" K
                              [prec(53), strict(1, 2(context('reval), result(RValue))), latex({{#1}}\terminal{$\gg$=}{{#2}})]
                         | K "&=" K
                              [prec(53), strict(1, 2(context('reval), result(RValue)))]
                         | K "^=" K
                              [prec(53), strict(1, 2(context('reval), result(RValue)))]
                         | K "|=" K
                              [prec(53), strict(1, 2(context('reval), result(RValue)))]
                         | K ">>=" K
                              [prec(53), strict(1, 2(context('reval), result(RValue))), latex({{#1}}\terminal{$\ll$=}{{#2}})]
                         | K ":=" K [prec(53)]

     context (HOLE => reval'(HOLE)) * _ [ndheat]
     context _ * (HOLE => reval'(HOLE)) [ndheat]
     context (HOLE => reval'(HOLE)) / _ [ndheat]
     context _ / (HOLE => reval'(HOLE)) [ndheat]
     context (HOLE => reval'(HOLE)) % _ [ndheat]
     context _ % (HOLE => reval'(HOLE)) [ndheat]

     context (HOLE => reval'(HOLE)) + _ [addition]
     context _ + (HOLE => reval'(HOLE)) [addition]
     context (HOLE => reval'(HOLE)) - _ [ndheat]
     context _ - (HOLE => reval'(HOLE)) [ndheat]

     context (HOLE => reval'(HOLE)) << _ [ndheat]
     context _ << (HOLE => reval'(HOLE)) [ndheat]

     context (HOLE => reval'(HOLE)) >> _ [ndheat]
     context _ >> (HOLE => reval'(HOLE)) [ndheat]

     context (HOLE => reval'(HOLE)) < _ [ndheat]
     context _ < (HOLE => reval'(HOLE)) [ndheat]
     context (HOLE => reval'(HOLE)) <= _ [ndheat]
     context _ <= (HOLE => reval'(HOLE)) [ndheat]

     context (HOLE => reval'(HOLE)) > _ [ndheat]
     context _ > (HOLE => reval'(HOLE)) [ndheat]
     context (HOLE => reval'(HOLE)) >= _ [ndheat]
     context _ >= (HOLE => reval'(HOLE)) [ndheat]

     context (HOLE => reval'(HOLE)) == _ [ndheat]
     context _ == (HOLE => reval'(HOLE)) [ndheat]
     context (HOLE => reval'(HOLE)) != _ [ndheat]
     context _ != (HOLE => reval'(HOLE)) [ndheat]

     context (HOLE => reval'(HOLE)) & _ [ndheat]
     context _ & (HOLE => reval'(HOLE)) [ndheat]

     context (HOLE => reval'(HOLE)) ^ _ [ndheat]
     context _ ^ (HOLE => reval'(HOLE)) [ndheat]

     context (HOLE => reval'(HOLE)) | _ [ndheat]
     context _ | (HOLE => reval'(HOLE)) [ndheat]

     context (HOLE => reval'(HOLE)) && _ [ndheat]

     context (HOLE => reval'(HOLE)) || _ [ndheat]

     context HOLE := _ [ndheat]
     context _ := (HOLE => reval'(HOLE)) [ndheat]

     /*
     (* A CAST can actually be a constructor expression *)
     | CAST of (specifier * decl_type) * init_expression
     */

     // TODO(chathhorn): dupe klabel??
     syntax Expression ::= "Cast" "(" K "," K "," K ")"
          [strict(1), klabel('Cast)]
     syntax Expression ::= "Cast" "(" K "," K ")"
          [strict(1, 2(context('reval), result(RValue)))]

     // new // comp-lit id, spec, decl, init
     syntax Expression ::= "CompoundLiteral" "(" K "," K "," K "," K ")"
          [klabel('CompoundLiteral), strict(2)]
     /*
     (* There is a special form of CALL in which the function called
        __builtin_va_arg and the second argument is sizeof(T). This
        should be printed as just T *)
     | CALL of expression * expression list
     */

     syntax Expression ::= "Call" "(" K "," K ")" [klabel('Call)]
     context Call((HOLE => reval'(HOLE)), _) [ndheat]
     /*
     | COMMA of expression list
     */
     // List
     syntax Expression ::= "Comma" "(" K ")" [klabel('Comma)]
     /*
     | CONSTANT of constant
     | PAREN of expression
     | VARIABLE of string
     */
     syntax Expression ::= Constant(K) [klabel('Constant)]
     // String constants aren't revals
     // for paren, just putting parentheses
     syntax Expression ::= CId
     /*
     | EXPR_SIZEOF of expression
     | TYPE_SIZEOF of specifier * decl_type
     | EXPR_ALIGNOF of expression
     | TYPE_ALIGNOF of specifier * decl_type
     */
     syntax Expression ::= SizeofExpression(K)
          [klabel('SizeofExpression)]
     syntax Expression ::= SizeofType(K, K)
          [klabel('SizeofType), strict(1)]
     syntax Expression ::= AlignofExpression(K)
          [klabel('AlignofExpression)]
     syntax Expression ::= AlignofType(K, K)
          [klabel('AlignofType), strict(1)]
     /*
     | INDEX of expression * expression
     */
     syntax Expression ::= K "[" K "]"
     /*
     | MEMBEROF of expression * string
     | MEMBEROFPTR of expression * string
     */
     syntax Expression ::= K "." CId [left, strict(1)]
     syntax Expression ::= K "->" CId
          [left, strict(1(context('reval), result(RValue)))]
     /*
     | GNU_BODY of block
     | EXPR_PATTERN of String     (* pattern variable, and name *)
     */
     syntax Expression ::= GnuBody(K) [klabel('GnuBody)]
     syntax Expression ::= ExpressionPattern(String)
          [klabel('ExpressionPattern)]

     /*
     and constant =
     | CONST_INT of String   (* the textual representation *)
     | CONST_FLOAT of String (* the textual representaton *)
     | CONST_CHAR of int64 list
     | CONST_WCHAR of int64 list
     | CONST_STRING of string
     | CONST_WSTRING of int64 list
     */
     syntax IntConstant ::= DecimalConstant(K) [klabel('DecimalConstant)]
     syntax IntConstant ::= OctalConstant(K) [klabel('OctalConstant)]
     syntax IntConstant ::= HexConstant(K) [klabel('HexConstant)]

     // significand, exponent, approx
     syntax IntConstant ::= DecimalFloatConstant(String, Int, Float)
          [klabel('DecimalFloatConstant)]
     // significand, exponent, approx
     syntax IntConstant ::= HexFloatConstant(String, Int, Float)
          [klabel('HexFloatConstant)]

     syntax Constant ::= LitU(K) [klabel('LitU)]
     syntax Constant ::= LitL(K) [klabel('LitL)]
     syntax Constant ::= LitF(K) [klabel('LitF)]
     syntax Constant ::= LitLL(K) [klabel('LitLL)]
     syntax Constant ::= LitUL(K) [klabel('LitUL)]
     syntax Constant ::= LitULL(K) [klabel('LitULL)]

     syntax Constant ::= NoSuffix(K) [klabel('NoSuffix)]

     syntax Constant ::= CharLiteral(Int) [klabel('CharLiteral)]
     syntax Constant ::= WCharLiteral(Int) [klabel('WCharLiteral)]
     syntax Constant ::= StringLiteral(String) [klabel('StringLiteral)]
     syntax Constant ::= WStringLiteral(K) [klabel('WStringLiteral)]

     /*
     and init_expression =
     | NO_INIT
     | SINGLE_INIT of expression
     | COMPOUND_INIT of (initwhat * init_expression) list
     */
     syntax KResult ::= "NoInit" // InitExpression
     syntax InitExpression ::= SingleInit(K)
          [klabel('SingleInit), hybrid, strict]
     // List
     syntax InitExpression ::= CompoundInit(K)
          [klabel('CompoundInit), hybrid, strict]
     // new; (initwhat * init_expression)
     syntax InitFragment ::= InitFragment(K, K)
          [klabel('InitFragment)]

     /*
     and initwhat =
     NEXT_INIT
     | INFIELD_INIT of String * initwhat
     | ATINDEX_INIT of expression * initwhat
     | ATINDEXRANGE_INIT of expression * expression
     */
     syntax KResult ::= "NextInit"
     syntax KResult ::= InFieldInit(CId, K) [klabel('InFieldInit)]
     syntax KResult ::= AtIndexInit(K, K) [klabel('AtIndexInit)]
     syntax KResult ::= AtIndexRangeInit(K, K) [klabel('AtIndexRangeInit)]

     /*
     and attribute = String * expression list
     */
     // String, List
     syntax C ::= Attribute(String, K) [klabel('Attribute)]

     syntax K ::= CodeLoc(K, K) [klabel('CodeLoc)]

     syntax K ::= "struct-loc""(" CId "," K ")"
                | "LabelTM" "(" Map ")"           // type   for loop extract
                | "linfo" "(" K "," CId ")"       // label information    location , function id    for loop extract

endmodule
