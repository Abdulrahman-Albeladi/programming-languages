(*
   Property-based regression test for regular-expression compilation.

   Generated strings are constructed from their source expressions, then checked
   against the DFA produced from the corresponding NFA.
*)
open QCheck
open P5.Nfa
open P5.Regexp
open TestUtils

let epsilon _ = Empty_String
let symbol character = Char character
let union left right = Union (left, right)

let concat left right =
  match (left, right) with
  | Empty_String, expression | expression, Empty_String -> expression
  | _ -> Concat (left, right)

let star expression = Star expression

let rec regex_gen depth =
  let open Gen in
  match depth with
  | 0 ->
      frequency
        [ (1, map epsilon char); (9, map symbol (char_range 'a' 'z')) ]
  | _ ->
      oneof
        [ map2 union (regex_gen (depth - 1)) (regex_gen (depth - 1));
          map2 concat (regex_gen (depth - 1)) (regex_gen (depth - 1));
          map star (regex_gen (depth - 1)) ]

(* Generate a string accepted by the given regular expression. *)
let rec string_gen expression =
  let open Gen in
  match expression with
  | Empty_String -> return ""
  | Char character -> return (String.make 1 character)
  | Union (left, right) -> oneof [ string_gen left; string_gen right ]
  | Concat (left, right) ->
      string_gen left >>= fun left_string ->
      string_gen right >>= fun right_string ->
      return (left_string ^ right_string)
  | Star expression ->
      int_range 1 5 >>= fun repetitions ->
      string_gen expression >>= fun generated ->
      return (String.concat "" (List.init repetitions (fun _ -> generated)))

let regex_string_arbitrary =
  make
    (let open Gen in
     regex_gen 5 >>= fun expression ->
     pair (return expression) (string_gen expression))
  |> set_print (fun (expression, string) ->
         "Regex: " ^ re_to_str expression ^ "\nString: " ^ string)

let regex_to_nfa_accepts_generated_strings =
  Test.make
    ~name:"regex_to_nfa_accept"
    ~count:100
    regex_string_arbitrary
    (fun (expression, string) ->
      let nfa = regexp_to_nfa expression in
      let dfa = nfa_to_dfa nfa in
      accept dfa string)

let () =
  QCheck_runner.run_tests
    ~verbose:true
    [ regex_to_nfa_accepts_generated_strings ]
