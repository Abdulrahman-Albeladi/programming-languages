open LccTypes

let match_token (tokens : 'a list) (token : 'a) : 'a list =
  match tokens with
  | [] -> raise (Failure "List was empty")
  | head :: tail when head = token -> tail
  | _ ->
      raise
        (Failure
           "Token passed in does not match first token in list")

let lookahead = function
  | token :: _ -> token
  | [] -> raise (Failure "Empty input to lookahead")

let parse_lambda tokens =
  let rec parse_expression tokens =
    match tokens with
    | Lambda_Var variable :: _ ->
        let remaining = match_token tokens (Lambda_Var variable) in
        (remaining, Var variable)
    | Lambda_LParen :: Lambda_Lambda :: Lambda_Var variable :: Lambda_Dot :: body ->
        let remaining, expression = parse_expression body in
        let remaining = match_token remaining Lambda_RParen in
        (remaining, Func (variable, expression))
    | Lambda_LParen :: _ ->
        let remaining = match_token tokens Lambda_LParen in
        let remaining, function_expression = parse_expression remaining in
        let remaining, argument_expression = parse_expression remaining in
        let remaining = match_token remaining Lambda_RParen in
        (remaining, Application (function_expression, argument_expression))
    | _ -> raise (Failure "parsing failed")
  in
  let remaining, expression = parse_expression tokens in
  if remaining <> [ Lambda_EOF ] then raise (Failure "parsing failed") else expression

let parse_engl tokens =
  let rec parse_sentence tokens =
    let remaining, expression = parse_and tokens in
    if remaining <> [ Engl_EOF ] then raise (Failure "parsing failed") else expression

  and parse_and tokens =
    let remaining, left = parse_or tokens in
    match lookahead remaining with
    | Engl_And ->
        let remaining = match_token remaining Engl_And in
        let remaining, right = parse_and remaining in
        (remaining, And (left, right))
    | _ -> (remaining, left)

  and parse_or tokens =
    let remaining, left = parse_term tokens in
    match lookahead remaining with
    | Engl_Or ->
        let remaining = match_token remaining Engl_Or in
        let remaining, right = parse_or remaining in
        (remaining, Or (left, right))
    | _ -> (remaining, left)

  and parse_term tokens =
    match lookahead tokens with
    | Engl_Not ->
        let remaining = match_token tokens Engl_Not in
        let remaining, expression = parse_term remaining in
        (remaining, Not expression)
    | _ -> parse_conditional tokens

  and parse_conditional tokens =
    match lookahead tokens with
    | Engl_If ->
        let remaining = match_token tokens Engl_If in
        let remaining, condition = parse_conditional remaining in
        let remaining = match_token remaining Engl_Then in
        let remaining, consequent = parse_conditional remaining in
        let remaining = match_token remaining Engl_Else in
        let remaining, alternative = parse_conditional remaining in
        (remaining, If (condition, consequent, alternative))
    | _ -> parse_atom tokens

  and parse_atom tokens =
    match lookahead tokens with
    | Engl_True ->
        let remaining = match_token tokens Engl_True in
        (remaining, Bool true)
    | Engl_False ->
        let remaining = match_token tokens Engl_False in
        (remaining, Bool false)
    | Engl_LParen ->
        let remaining = match_token tokens Engl_LParen in
        let remaining, expression = parse_and remaining in
        let remaining = match_token remaining Engl_RParen in
        (remaining, expression)
    | _ -> raise (Failure "parsing failed")
  in
  parse_sentence tokens
