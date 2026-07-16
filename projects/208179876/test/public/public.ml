open OUnit2
open P5.Nfa
open P5.Regexp
open TestUtils

let test_nfa_acceptance _ =
  let single_a =
    { qs = [ 0; 1 ]
    ; sigma = [ 'a'; 'b' ]
    ; delta = [ 0, Some 'a', 1 ]
    ; q0 = 0
    ; fs = [ 1 ]
    }
  in
  assert_nfa_deny single_a "";
  assert_nfa_accept single_a "a";
  assert_nfa_deny single_a "b";
  assert_nfa_deny single_a "ba";
  let accepts_b =
    { qs = [ 0; 1; 2 ]
    ; sigma = [ 'a'; 'b' ]
    ; delta = [ 0, Some 'a', 1; 0, Some 'b', 2 ]
    ; q0 = 0
    ; fs = [ 2 ]
    }
  in
  assert_nfa_deny accepts_b "";
  assert_nfa_deny accepts_b "a";
  assert_nfa_accept accepts_b "b";
  assert_nfa_deny accepts_b "ba"

let test_nfa_to_dfa _ =
  let nondeterministic_a =
    { qs = [ 0; 1; 2; 3 ]
    ; sigma = [ 'a'; 'b' ]
    ; delta = [ 0, Some 'a', 1; 0, Some 'a', 2; 2, Some 'b', 3 ]
    ; q0 = 0
    ; fs = [ 1; 3 ]
    }
  in
  let deterministic_a = nfa_to_dfa nondeterministic_a in
  assert_dfa deterministic_a;
  assert_nfa_deny deterministic_a "";
  assert_nfa_accept deterministic_a "a";
  assert_nfa_accept deterministic_a "ab";
  assert_nfa_deny deterministic_a "b";
  assert_nfa_deny deterministic_a "ba";
  let accepts_b =
    { qs = [ 0; 1; 2 ]
    ; sigma = [ 'a'; 'b' ]
    ; delta = [ 0, Some 'a', 1; 0, Some 'b', 2 ]
    ; q0 = 0
    ; fs = [ 2 ]
    }
  in
  let deterministic_b = nfa_to_dfa accepts_b in
  assert_dfa deterministic_b;
  assert_nfa_deny deterministic_b "";
  assert_nfa_deny deterministic_b "a";
  assert_nfa_accept deterministic_b "b";
  assert_nfa_deny deterministic_b "ba"

let test_nfa_closure _ =
  let no_epsilon_transitions =
    { qs = [ 0; 1 ]
    ; sigma = [ 'a' ]
    ; delta = [ 0, Some 'a', 1 ]
    ; q0 = 0
    ; fs = [ 1 ]
    }
  in
  assert_nfa_closure no_epsilon_transitions [ 0 ] [ 0 ];
  assert_nfa_closure no_epsilon_transitions [ 1 ] [ 1 ];
  let epsilon_transition =
    { qs = [ 0; 1 ]; sigma = []; delta = [ 0, None, 1 ]; q0 = 0; fs = [ 1 ] }
  in
  assert_nfa_closure epsilon_transition [ 0 ] [ 0; 1 ];
  assert_nfa_closure epsilon_transition [ 1 ] [ 1 ];
  let symbol_transitions =
    { qs = [ 0; 1; 2 ]
    ; sigma = [ 'a'; 'b' ]
    ; q0 = 0
    ; fs = [ 2 ]
    ; delta = [ 0, Some 'a', 1; 0, Some 'b', 2 ]
    }
  in
  assert_nfa_closure symbol_transitions [ 0 ] [ 0 ];
  assert_nfa_closure symbol_transitions [ 1 ] [ 1 ];
  assert_nfa_closure symbol_transitions [ 2 ] [ 2 ];
  let branching_epsilon_transitions =
    { qs = [ 0; 1; 2 ]
    ; sigma = [ 'a' ]
    ; q0 = 0
    ; fs = [ 2 ]
    ; delta = [ 0, None, 1; 0, None, 2 ]
    }
  in
  assert_nfa_closure branching_epsilon_transitions [ 0 ] [ 0; 1; 2 ];
  assert_nfa_closure branching_epsilon_transitions [ 1 ] [ 1 ];
  assert_nfa_closure branching_epsilon_transitions [ 2 ] [ 2 ]

let test_nfa_move _ =
  let single_transition =
    { qs = [ 0; 1 ]
    ; sigma = [ 'a' ]
    ; delta = [ 0, Some 'a', 1 ]
    ; q0 = 0
    ; fs = [ 1 ]
    }
  in
  assert_nfa_move single_transition [ 0 ] (Some 'a') [ 1 ];
  assert_nfa_move single_transition [ 1 ] (Some 'a') [];
  let epsilon_transition =
    { qs = [ 0; 1 ]
    ; sigma = [ 'a' ]
    ; delta = [ 0, None, 1 ]
    ; q0 = 0
    ; fs = [ 1 ]
    }
  in
  assert_nfa_move epsilon_transition [ 0 ] (Some 'a') [];
  assert_nfa_move epsilon_transition [ 1 ] (Some 'a') [];
  let symbol_transitions =
    { qs = [ 0; 1; 2 ]
    ; sigma = [ 'a'; 'b' ]
    ; q0 = 0
    ; fs = [ 2 ]
    ; delta = [ 0, Some 'a', 1; 0, Some 'b', 2 ]
    }
  in
  assert_nfa_move symbol_transitions [ 0 ] (Some 'a') [ 1 ];
  assert_nfa_move symbol_transitions [ 1 ] (Some 'a') [];
  assert_nfa_move symbol_transitions [ 2 ] (Some 'a') [];
  assert_nfa_move symbol_transitions [ 0 ] (Some 'b') [ 2 ];
  assert_nfa_move symbol_transitions [ 1 ] (Some 'b') [];
  assert_nfa_move symbol_transitions [ 2 ] (Some 'b') [];
  let mixed_transitions =
    { qs = [ 0; 1; 2 ]
    ; sigma = [ 'a'; 'b' ]
    ; q0 = 0
    ; fs = [ 2 ]
    ; delta = [ 0, None, 1; 0, Some 'a', 2 ]
    }
  in
  assert_nfa_move mixed_transitions [ 0 ] (Some 'a') [ 2 ];
  assert_nfa_move mixed_transitions [ 1 ] (Some 'a') [];
  assert_nfa_move mixed_transitions [ 2 ] (Some 'a') [];
  assert_nfa_move mixed_transitions [ 0 ] (Some 'b') [];
  assert_nfa_move mixed_transitions [ 1 ] (Some 'b') [];
  assert_nfa_move mixed_transitions [ 2 ] (Some 'b') []

let subset_construction_example =
  { qs = [ 0; 1; 2; 3; 4 ]
  ; sigma = [ 'a'; 'b' ]
  ; delta =
      [ 0, Some 'a', 1
      ; 0, Some 'a', 2
      ; 2, Some 'b', 3
      ; 2, None, 4
      ; 4, Some 'a', 4
      ]
  ; q0 = 0
  ; fs = [ 1; 3 ]
  }

let test_nfa_new_states _ =
  assert_set_set_eq [ []; [] ] (new_states subset_construction_example []);
  assert_set_set_eq [ [ 1; 2; 4 ]; [] ] (new_states subset_construction_example [ 0 ]);
  assert_set_set_eq [ [ 4 ]; [] ] (new_states subset_construction_example [ 3; 4 ]);
  assert_set_set_eq
    [ [ 1; 2; 4 ]; [ 3 ] ]
    (new_states subset_construction_example [ 0; 2 ]);
  assert_set_set_eq
    [ [ 1; 2; 4 ]; [ 3 ] ]
    (new_states subset_construction_example [ 0; 1; 2; 3 ])

let test_nfa_new_transitions _ =
  assert_trans_eq
    [ [ 0 ], Some 'a', [ 1; 2; 4 ]; [ 0 ], Some 'b', [] ]
    (new_trans subset_construction_example [ 0 ]);
  assert_trans_eq
    [ [ 0; 2 ], Some 'a', [ 1; 2; 4 ]; [ 0; 2 ], Some 'b', [ 3 ] ]
    (new_trans subset_construction_example [ 0; 2 ])

let test_nfa_new_finals _ =
  assert_set_set_eq [] (new_finals subset_construction_example [ 0; 2 ]);
  assert_set_set_eq [ [ 1 ] ] (new_finals subset_construction_example [ 1 ]);
  assert_set_set_eq [ [ 1; 3 ] ] (new_finals subset_construction_example [ 1; 3 ])

let test_regexp_to_nfa _ =
  let single_a = regexp_to_nfa (Char 'a') in
  assert_nfa_deny single_a "";
  assert_nfa_accept single_a "a";
  assert_nfa_deny single_a "b";
  assert_nfa_deny single_a "ba";
  let either_a_or_b = regexp_to_nfa (Union (Char 'a', Char 'b')) in
  assert_nfa_deny either_a_or_b "";
  assert_nfa_accept either_a_or_b "a";
  assert_nfa_accept either_a_or_b "b";
  assert_nfa_deny either_a_or_b "ba"

let test_string_to_regexp_to_nfa _ =
  let machine = string_to_regexp "ab" |> regexp_to_nfa in
  assert_nfa_deny machine "a";
  assert_nfa_deny machine "b";
  assert_nfa_accept machine "ab";
  assert_nfa_deny machine "bb"

let test_string_to_regexp_with_empty_expression _ =
  let machine = string_to_regexp "((E)|(E))*" |> regexp_to_nfa in
  assert_nfa_deny machine "jujujuju"

let suite =
  "automata"
  >::: [ "nfa_acceptance" >:: test_nfa_acceptance
       ; "nfa_closure" >:: test_nfa_closure
       ; "nfa_move" >:: test_nfa_move
       ; "nfa_to_dfa" >:: test_nfa_to_dfa
       ; "regexp_to_nfa" >:: test_regexp_to_nfa
       ; "string_to_regexp_to_nfa" >:: test_string_to_regexp_to_nfa
       ; "nfa_new_states" >:: test_nfa_new_states
       ; "nfa_new_transitions" >:: test_nfa_new_transitions
       ; "nfa_new_finals" >:: test_nfa_new_finals
       ; "string_to_regexp_with_empty_expression"
         >:: test_string_to_regexp_with_empty_expression
       ]

let () = run_test_tt_main suite
