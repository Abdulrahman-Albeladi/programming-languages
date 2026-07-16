open OUnit2
open Lcc.Lexer
open Lcc.Parser
open Lcc.Eval
open Lcc.LccTypes

let assert_cases name evaluate cases expected_results =
  if List.length cases <> List.length expected_results then
    assert_failure (name ^ ": test-case and expected-result counts differ")
  else
    List.iter
      (fun (input, expected) ->
        assert_equal expected (evaluate input) ~msg:(name ^ ": " ^ input))
      (List.combine cases expected_results)

let assert_alpha_equivalent_cases name evaluate cases expected_results =
  if List.length cases <> List.length expected_results then
    assert_failure (name ^ ": test-case and expected-result counts differ")
  else
    List.iter
      (fun (input, expected) ->
        assert_bool (name ^ ": " ^ input) (isalpha (evaluate input) expected))
      (List.combine cases expected_results)

let lex_lambda_test _ =
  let cases = ["(Lx.x)"; "..."; "L L.x y.x L)"] in
  let expected_results =
    [
      [
        Lambda_LParen;
        Lambda_Lambda;
        Lambda_Var "x";
        Lambda_Dot;
        Lambda_Var "x";
        Lambda_RParen;
        Lambda_EOF;
      ];
      [Lambda_Dot; Lambda_Dot; Lambda_Dot; Lambda_EOF];
      [
        Lambda_Lambda;
        Lambda_Lambda;
        Lambda_Dot;
        Lambda_Var "x";
        Lambda_Var "y";
        Lambda_Dot;
        Lambda_Var "x";
        Lambda_Lambda;
        Lambda_RParen;
        Lambda_EOF;
      ];
    ]
  in
  assert_cases "lex_lambda" lex_lambda cases expected_results

let lex_engl_test _ =
  let cases =
    [
      "true and or false";
      "not  not     not)";
      "(( if not ) and true false";
    ]
  in
  let expected_results =
    [
      [Engl_True; Engl_And; Engl_Or; Engl_False; Engl_EOF];
      [Engl_Not; Engl_Not; Engl_Not; Engl_RParen; Engl_EOF];
      [
        Engl_LParen;
        Engl_LParen;
        Engl_If;
        Engl_Not;
        Engl_RParen;
        Engl_And;
        Engl_True;
        Engl_False;
        Engl_EOF;
      ];
    ]
  in
  assert_cases "lex_engl" lex_engl cases expected_results

let parse_lambda_test _ =
  let cases = ["(Lx.x)"; "((Lx.x) a)"; "((Lx.x) (Ly.y))"] in
  let expected_results =
    [
      Func ("x", Var "x");
      Application (Func ("x", Var "x"), Var "a");
      Application (Func ("x", Var "x"), Func ("y", Var "y"));
    ]
  in
  assert_cases "parse_lambda" (fun input -> parse_lambda (lex_lambda input))
    cases expected_results

let parse_engl_test _ =
  let cases =
    ["not true"; "if true then false else true"; "false and (true or false)"]
  in
  let expected_results =
    [
      Not (Bool true);
      If (Bool true, Bool false, Bool true);
      And (Bool false, Or (Bool true, Bool false));
    ]
  in
  assert_cases "parse_engl" (fun input -> parse_engl (lex_engl input)) cases
    expected_results

let evaluation_cases =
  [
    "((Lx.x) ((Ly.(y y)) a))";
    "x";
    "((Lx.x) a)";
    "((Lx.b) ((Ly.y) ((Lz.z) a)))";
  ]

let reduce_test _ =
  let expected_results =
    [
      Application (Var "a", Var "a");
      Var "x";
      Var "a";
      Var "b";
    ]
  in
  assert_alpha_equivalent_cases "reduce"
    (fun input -> reduce [] (parse_lambda (lex_lambda input)))
    evaluation_cases expected_results

let laze_test _ =
  let expected_results =
    [
      Application (Func ("y", Application (Var "y", Var "y")), Var "a");
      Var "x";
      Var "a";
      Var "b";
    ]
  in
  assert_alpha_equivalent_cases "laze"
    (fun input -> laze [] (parse_lambda (lex_lambda input)))
    evaluation_cases expected_results

let eager_test _ =
  let expected_results =
    [
      Application (Func ("x", Var "x"), Application (Var "a", Var "a"));
      Var "x";
      Var "a";
      Application
        ( Func ("x", Var "b"),
          Application (Func ("y", Var "y"), Var "a") );
    ]
  in
  assert_alpha_equivalent_cases "eager"
    (fun input -> eager [] (parse_lambda (lex_lambda input)))
    evaluation_cases expected_results

let isalpha_test _ =
  let parse input = input |> lex_lambda |> parse_lambda in
  assert_bool "isalpha: a, a" (isalpha (parse "a") (parse "a"));
  assert_bool "isalpha: a, b" (not (isalpha (parse "a") (parse "b")))

let convert_test _ =
  let cases = ["false"; "not true"; "if true then not false else false"] in
  let expected_results =
    [
      "(Lx.(Ly.y))";
      "((Lx.((x (Lx.(Ly.y))) (Lx.(Ly.x)))) (Lx.(Ly.x)))";
      "(((Lx.(Ly.x)) ((Lx.((x (Lx.(Ly.y))) (Lx.(Ly.x)))) (Lx.(Ly.y)))) (Lx.(Ly.y)))";
    ]
  in
  assert_cases "convert" (fun input -> convert (parse_engl (lex_engl input)))
    cases expected_results

let readable_test _ =
  let cases =
    [
      "(Lx.(Ly.y))";
      "((Lx.((x (Lx.(Ly.y))) (Lx.(Ly.x)))) (Lx.(Ly.x)))";
      "(((Lx.(Ly.x)) ((Lx.((x (Lx.(Ly.y))) (Lx.(Ly.x)))) (Lx.(Ly.y)))) (Lx.(Ly.y)))";
      "(((Lx.(Ly.((x y) (Lx.(Ly.y))))) (Lx.(Ly.x))) (Lx.(Ly.y)))";
      "(((Lx.(Ly.((x (Lx.(Ly.x))) y))) (Lx.(Ly.x))) (Lx.(Ly.y)))";
    ]
  in
  let expected_results =
    [
      "false";
      "(not true)";
      "(if true then (not false) else false)";
      "(true and false)";
      "(true or false)";
    ]
  in
  assert_cases "readable" (fun input -> readable (parse_lambda (lex_lambda input)))
    cases expected_results

let evaluate_boolean_expression input =
  input |> lex_engl |> parse_engl |> convert |> lex_lambda |> parse_lambda |> reduce []
  |> readable

let end_to_end_test _ =
  assert_cases "end_to_end" evaluate_boolean_expression ["true"; "not true"]
    ["true"; "false"]

let suite =
  "lambda-calculus"
  >::: [
         "lex_lambda" >:: lex_lambda_test;
         "lex_engl" >:: lex_engl_test;
         "parse_lambda" >:: parse_lambda_test;
         "parse_engl" >:: parse_engl_test;
         "reduce" >:: reduce_test;
         "laze" >:: laze_test;
         "eager" >:: eager_test;
         "isalpha" >:: isalpha_test;
         "convert" >:: convert_test;
         "readable" >:: readable_test;
         "end_to_end" >:: end_to_end_test;
       ]

let () = run_test_tt_main suite
