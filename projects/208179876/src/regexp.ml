open Nfa
open Sets

(** Abstract syntax tree for regular expressions. *)
type regexp_t =
  | Empty_String
  | Char of char
  | Union of regexp_t * regexp_t
  | Concat of regexp_t * regexp_t
  | Star of regexp_t

let fresh =
  let counter = ref 0 in
  fun () ->
    counter := !counter + 1;
    !counter

let rec cet (states : 'q list) ((symbol, destination) : 's option * 'q) :
    ('q, 's) transition list =
  match states with
  | [] -> []
  | state :: rest -> (state, symbol, destination) :: cet rest (symbol, destination)

(** Build an epsilon-NFA equivalent to a regular expression. *)
let rec regexp_to_nfa (regexp : regexp_t) : (int, char) nfa_t =
  match regexp with
  | Empty_String ->
      let initial = fresh () in
      let final = fresh () in
      {
        sigma = [];
        qs = [ initial; final ];
        q0 = initial;
        fs = [ final ];
        delta = [ (initial, None, final) ];
      }
  | Char character ->
      let initial = fresh () in
      let final = fresh () in
      {
        sigma = [ character ];
        qs = [ initial; final ];
        q0 = initial;
        fs = [ final ];
        delta = [ (initial, Some character, final) ];
      }
  | Union (left, right) ->
      let left_nfa = regexp_to_nfa left in
      let right_nfa = regexp_to_nfa right in
      let initial = fresh () in
      {
        sigma = union left_nfa.sigma right_nfa.sigma;
        qs = union [ initial ] (union left_nfa.qs right_nfa.qs);
        q0 = initial;
        fs = union left_nfa.fs right_nfa.fs;
        delta =
          union
            [ (initial, None, left_nfa.q0); (initial, None, right_nfa.q0) ]
            (union left_nfa.delta right_nfa.delta);
      }
  | Concat (left, right) ->
      let left_nfa = regexp_to_nfa left in
      let right_nfa = regexp_to_nfa right in
      {
        sigma = union left_nfa.sigma right_nfa.sigma;
        qs = union left_nfa.qs right_nfa.qs;
        q0 = left_nfa.q0;
        fs = right_nfa.fs;
        delta =
          union
            (cet left_nfa.fs (None, right_nfa.q0))
            (union left_nfa.delta right_nfa.delta);
      }
  | Star expression ->
      let nfa = regexp_to_nfa expression in
      {
        sigma = nfa.sigma;
        qs = nfa.qs;
        q0 = nfa.q0;
        fs = union [ nfa.q0 ] nfa.fs;
        delta = union (cet nfa.fs (None, nfa.q0)) nfa.delta;
      }

exception IllegalExpression of string

type token =
  | Tok_Char of char
  | Tok_Epsilon
  | Tok_Union
  | Tok_Star
  | Tok_LParen
  | Tok_RParen
  | Tok_END

let tokenize str =
  let re_var = Str.regexp "[a-z]" in
  let re_epsilon = Str.regexp "E" in
  let re_union = Str.regexp "|" in
  let re_star = Str.regexp "\\*" in
  let re_lparen = Str.regexp "(" in
  let re_rparen = Str.regexp ")" in
  let rec tok position input =
    if position >= String.length input then [ Tok_END ]
    else if Str.string_match re_var input position then
      let token = Str.matched_string input in
      Tok_Char token.[0] :: tok (position + 1) input
    else if Str.string_match re_epsilon input position then
      Tok_Epsilon :: tok (position + 1) input
    else if Str.string_match re_union input position then
      Tok_Union :: tok (position + 1) input
    else if Str.string_match re_star input position then
      Tok_Star :: tok (position + 1) input
    else if Str.string_match re_lparen input position then
      Tok_LParen :: tok (position + 1) input
    else if Str.string_match re_rparen input position then
      Tok_RParen :: tok (position + 1) input
    else raise (IllegalExpression ("tokenize: " ^ input))
  in
  tok 0 str

let tok_to_str = function
  | Tok_Char value -> Char.escaped value
  | Tok_Epsilon -> "E"
  | Tok_Union -> "|"
  | Tok_Star -> "*"
  | Tok_LParen -> "("
  | Tok_RParen -> ")"
  | Tok_END -> "END"

(** Parse union, concatenation, Kleene star, grouping, and epsilon. *)
let parse_regexp (tokens : token list) =
  let lookahead = function
    | [] -> raise (IllegalExpression "lookahead")
    | token :: remaining -> (token, remaining)
  in
  let rec parse_S tokens =
    let left, remaining = parse_A tokens in
    let token, following = lookahead remaining in
    match token with
    | Tok_Union ->
        let right, rest = parse_S following in
        (Union (left, right), rest)
    | _ -> (left, remaining)
  and parse_A tokens =
    let left, remaining = parse_B tokens in
    let token, _ = lookahead remaining in
    match token with
    | Tok_Char _ | Tok_Epsilon | Tok_LParen ->
        let right, rest = parse_A remaining in
        (Concat (left, right), rest)
    | _ -> (left, remaining)
  and parse_B tokens =
    let expression, remaining = parse_C tokens in
    let token, following = lookahead remaining in
    match token with
    | Tok_Star -> (Star expression, following)
    | _ -> (expression, remaining)
  and parse_C tokens =
    let token, remaining = lookahead tokens in
    match token with
    | Tok_Char character -> (Char character, remaining)
    | Tok_Epsilon -> (Empty_String, remaining)
    | Tok_LParen ->
        let expression, following = parse_S remaining in
        let closing, rest = lookahead following in
        if closing = Tok_RParen then (expression, rest)
        else raise (IllegalExpression "parse_C 1")
    | _ -> raise (IllegalExpression "parse_C 2")
  in
  let regexp, remaining = parse_S tokens in
  match remaining with
  | [ Tok_END ] -> regexp
  | _ -> raise (IllegalExpression "parse didn't consume all tokens")

let string_to_regexp str = parse_regexp @@ tokenize str
let string_to_nfa str = regexp_to_nfa @@ string_to_regexp str
