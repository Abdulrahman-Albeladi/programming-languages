open LccTypes

let cntr = ref (-1)

let fresh () =
  cntr := !cntr + 1;
  !cntr

let rec lookup env var =
  match env with
  | [] -> None
  | (name, value) :: rest -> if name = var then value else lookup rest var

let variables expression =
  let rec collect names = function
    | Var variable -> variable :: names
    | Func (variable, body) -> collect (variable :: names) body
    | Application (left, right) -> collect (collect names left) right
  in
  collect [] expression

let free_variables expression =
  let rec collect bound free = function
    | Var variable ->
        if List.mem variable bound || List.mem variable free then free
        else variable :: free
    | Func (variable, body) -> collect (variable :: bound) free body
    | Application (left, right) -> collect bound (collect bound free left) right
  in
  collect [] [] expression

let rec fresh_avoiding forbidden =
  let candidate = fresh () in
  if List.mem candidate forbidden then fresh_avoiding forbidden else candidate

let alpha_convert expression =
  let rec convert env used = function
    | Var variable -> (
        match lookup env variable with
        | Some replacement -> Var replacement
        | None -> Var variable)
    | Func (variable, body) ->
        let replacement = fresh_avoiding used in
        let body' = convert ((variable, replacement) :: env) (replacement :: used) body in
        Func (replacement, body')
    | Application (left, right) ->
        Application (convert env used left, convert env used right)
  in
  convert [] (variables expression) expression

let isalpha expression1 expression2 =
  let rec alpha_equiv bindings left right =
    match (left, right) with
    | Var variable1, Var variable2 -> (
        match lookup bindings variable1 with
        | Some mapped_variable -> mapped_variable = variable2
        | None -> variable1 = variable2)
    | Func (variable1, body1), Func (variable2, body2) ->
        alpha_equiv ((variable1, variable2) :: bindings) body1 body2
    | Application (left1, right1), Application (left2, right2) ->
        alpha_equiv bindings left1 left2 && alpha_equiv bindings right1 right2
    | _ -> false
  in
  alpha_equiv [] expression1 expression2

let rec substitute_var old_var new_expr target_expr =
  match target_expr with
  | Var variable -> if variable = old_var then new_expr else target_expr
  | Func (variable, body) ->
      if variable = old_var then target_expr
      else if List.mem variable (free_variables new_expr) then
        let replacement = fresh_avoiding (variables body @ variables new_expr) in
        let renamed_body = substitute_var variable (Var replacement) body in
        Func (replacement, substitute_var old_var new_expr renamed_body)
      else Func (variable, substitute_var old_var new_expr body)
  | Application (left, right) ->
      Application
        (substitute_var old_var new_expr left, substitute_var old_var new_expr right)

let rec reduce env expression =
  match expression with
  | Var variable -> (
      match lookup env variable with
      | Some (Some replacement) -> replacement
      | Some None | None -> expression)
  | Func (variable, body) -> Func (variable, reduce ((variable, None) :: env) body)
  | Application (left, right) -> (
      match reduce env left with
      | Func (variable, body) ->
          let argument = reduce env right in
          reduce ((variable, Some argument) :: env) body
      | reduced_left -> Application (reduced_left, reduce env right))

let laze _env expression =
  match expression with
  | Application (Func (variable, body), argument) -> substitute_var variable argument body
  | _ -> expression

let rec eager env expression =
  match expression with
  | Application (Func (variable, body), argument) when lookup env variable = None ->
      substitute_var variable argument body
  | Application (left, right) -> Application (eager env left, eager env right)
  | Func (variable, body) -> Func (variable, eager env body)
  | Var _ -> expression

let rec convert tree =
  match tree with
  | Bool value -> if value then "(Lx.(Ly.x))" else "(Lx.(Ly.y))"
  | If (condition, then_branch, else_branch) ->
      "((" ^ convert condition ^ " " ^ convert then_branch ^ ") "
      ^ convert else_branch ^ ")"
  | And (left, right) ->
      "(((Lx.(Ly.((x y) (Lx.(Ly.y))))) " ^ convert left ^ ") "
      ^ convert right ^ ")"
  | Or (left, right) ->
      "(((Lx.(Ly.((x (Lx.(Ly.x))) y))) " ^ convert left ^ ") "
      ^ convert right ^ ")"
  | Not expression ->
      "((Lx.((x (Lx.(Ly.y))) (Lx.(Ly.x)))) " ^ convert expression ^ ")"

let rec readable tree =
  match tree with
  | Func (variable1, Func (variable2, Var variable3))
    when variable1 = variable3 && variable1 <> variable2 ->
      "true"
  | Func (variable1, Func (variable2, Var variable3)) when variable2 = variable3 ->
      "false"
  | Application
      ( Func
          ( variable1,
            Application
              ( Application (Var variable2, Func (variable3, Var variable4)),
                Func (variable5, Var variable6) ) ),
        argument )
    when variable1 = variable2 && variable2 = variable5 && variable5 = variable6
         && variable3 = variable4 ->
      "Not " ^ readable argument
  | Application
      ( Application
          ( Func
              ( variable1,
                Func
                  ( variable2,
                    Application
                      ( Application (Var variable3, Var variable4),
                        Func (variable5, Func (variable6, Var variable7)) ) ) ),
            left ),
        right )
    when variable1 = variable3 && variable2 = variable4 && variable4 = variable6
         && variable6 = variable7 && variable3 = variable5 ->
      readable left ^ " and " ^ readable right
  | Application
      ( Application
          ( Func
              ( variable1,
                Func
                  ( variable2,
                    Application
                      ( Application (Var variable3, Func (variable4, Var variable5)),
                        Var variable6 ) ) ),
            left ),
        right )
    when variable1 = variable3 && variable3 = variable4 && variable4 = variable5
         && variable2 = variable6 ->
      readable left ^ " or " ^ readable right
  | Application (Application (condition, then_branch), else_branch) ->
      "if " ^ readable condition ^ " then " ^ readable then_branch ^ " else "
      ^ readable else_branch
  | _ -> ""
