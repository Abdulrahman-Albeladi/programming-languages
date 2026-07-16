open LccTypes

(* Lexers for the lambda-calculus and English-like Boolean syntaxes. *)

let lex_lambda input =
  let len = String.length input in
  let rec lex pos =
    if pos >= len then
      [Lambda_EOF]
    else
      match input.[pos] with
      | '(' -> Lambda_LParen :: lex (pos + 1)
      | ')' -> Lambda_RParen :: lex (pos + 1)
      | '.' -> Lambda_Dot :: lex (pos + 1)
      | 'L' -> Lambda_Lambda :: lex (pos + 1)
      | ' ' | '\t' | '\n' -> lex (pos + 1)
      | 'a' .. 'z' as variable ->
          Lambda_Var (String.make 1 variable) :: lex (pos + 1)
      | _ -> raise (Failure "tokenizing failed")
  in
  lex 0

let lex_engl input =
  let len = String.length input in
  let starts_with pos token =
    let token_len = String.length token in
    pos + token_len <= len && String.sub input pos token_len = token
  in
  let rec lex pos =
    if pos >= len then
      [Engl_EOF]
    else if starts_with pos "true" then
      Engl_True :: lex (pos + 4)
    else if starts_with pos "false" then
      Engl_False :: lex (pos + 5)
    else if starts_with pos "if" then
      Engl_If :: lex (pos + 2)
    else if starts_with pos "then" then
      Engl_Then :: lex (pos + 4)
    else if starts_with pos "else" then
      Engl_Else :: lex (pos + 4)
    else if starts_with pos "and" then
      Engl_And :: lex (pos + 3)
    else if starts_with pos "or" then
      Engl_Or :: lex (pos + 2)
    else if starts_with pos "not" then
      Engl_Not :: lex (pos + 3)
    else if starts_with pos "end of string" then
      Engl_EOF :: lex (pos + 13)
    else
      match input.[pos] with
      | '(' -> Engl_LParen :: lex (pos + 1)
      | ')' -> Engl_RParen :: lex (pos + 1)
      | ' ' | '\t' | '\n' -> lex (pos + 1)
      | _ -> raise (Failure "tokenizing failed")
  in
  lex 0
