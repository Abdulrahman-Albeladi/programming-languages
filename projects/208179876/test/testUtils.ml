open OUnit2
open P5.Nfa
open P5.Regexp

let re_to_str regexp =
  let surround parts = "(" :: parts @ [ ")" ] in
  let rec to_parts = function
    | Empty_String -> [ "E" ]
    | Char character -> [ String.make 1 character ]
    | Union (left, right) ->
        surround (to_parts left) @ ("|" :: surround (to_parts right))
    | Concat (left, right) ->
        surround (to_parts left) @ surround (to_parts right)
    | Star expression -> surround (to_parts expression) @ [ "*" ]
  in
  String.concat "" (to_parts regexp)

let assert_true value = assert_equal true value

let assert_false value = assert_equal false value

let assert_pass () = assert_equal true true

let assert_fail () = assert_equal false false

let string_of_int_list values =
  Printf.sprintf "[%s]" (String.concat "; " (List.map string_of_int values))

let string_of_int_list_list values =
  Printf.sprintf "[%s]" (String.concat "; " (List.map string_of_int_list values))

let assert_dfa automaton =
  let is_nondeterministic =
    List.fold_left
      (fun found_nondeterminism (state, symbol, _) ->
        match symbol with
        | None -> true
        | Some _ ->
            let matching_transitions =
              List.filter
                (fun (other_state, other_symbol, _) ->
                  state = other_state && symbol = other_symbol)
                automaton.delta
            in
            found_nondeterminism || List.length matching_transitions > 1)
      false automaton.delta
  in
  if is_nondeterministic then assert_failure "NFA is not a DFA"

let assert_nfa_accept nfa input =
  if not (accept nfa input) then
    assert_failure
      (Printf.sprintf "NFA should accept string '%s', but did not" input)

let assert_nfa_deny nfa input =
  if accept nfa input then
    assert_failure
      (Printf.sprintf "NFA should not accept string '%s', but did" input)

let assert_nfa_closure nfa states expected_states =
  let expected = List.sort compare expected_states in
  let received = List.sort compare (e_closure nfa states) in
  if expected <> received then
    assert_failure
      (Printf.sprintf "Closure failure: expected %s, received %s"
         (string_of_int_list expected) (string_of_int_list received))

let assert_nfa_move nfa states symbol expected_states =
  let expected = List.sort compare expected_states in
  let received = List.sort compare (move nfa states symbol) in
  if expected <> received then
    assert_failure
      (Printf.sprintf "Move failure: expected %s, received %s"
         (string_of_int_list expected) (string_of_int_list received))

let assert_set_set_eq actual expected =
  let normalize values =
    List.sort_uniq compare (List.map (List.sort compare) values)
  in
  assert_equal (normalize actual) (normalize expected)

let assert_trans_eq actual expected =
  let normalize transitions =
    List.sort_uniq compare
      (List.map
         (fun (source, symbol, destination) ->
           (List.sort compare source, symbol, List.sort compare destination))
         transitions)
  in
  assert_equal (normalize actual) (normalize expected)

let assert_set_eq actual expected =
  let normalize = List.sort_uniq compare in
  assert_equal (normalize actual) (normalize expected)

let assert_regex_string_equiv regexp =
  assert_equal regexp (string_to_regexp (re_to_str regexp))
