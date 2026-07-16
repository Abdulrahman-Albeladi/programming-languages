open OUnit2
open TestUtils
open P4.Basics
open P4.Funs

let test_rev_tup _ =
  assert_equal (1, 2, 3) (rev_tup (3, 2, 1)) ~msg:"rev_tup (1)";
  assert_equal (3, 2, 1) (rev_tup (1, 2, 3)) ~msg:"rev_tup (2)";
  assert_equal (3, 1, 1) (rev_tup (1, 1, 3)) ~msg:"rev_tup (3)";
  assert_equal (1, 1, 1) (rev_tup (1, 1, 1)) ~msg:"rev_tup (4)"

let test_is_even _ =
  assert_equal false (is_even 1) ~msg:"is_even (1)";
  assert_equal true (is_even 4) ~msg:"is_even (2)";
  assert_equal false (is_even (-5)) ~msg:"is_even (3)"

let test_volume _ =
  assert_equal 1 (volume (1, 1, 1) (2, 2, 2)) ~msg:"volume (1)";
  assert_equal 4 (volume (1, 1, 1) (2, 3, 3)) ~msg:"volume (2)";
  assert_equal 4 (volume (1, 1, 1) (3, 2, 3)) ~msg:"volume (3)";
  assert_equal 4 (volume (1, 1, 1) (3, 3, 2)) ~msg:"volume (4)";
  assert_equal 8 (volume (1, 1, 1) (3, 3, 3)) ~msg:"volume (5)"

let test_fibonacci _ =
  assert_equal 1 (fibonacci 1) ~msg:"fibonacci (1)";
  assert_equal 1 (fibonacci 2) ~msg:"fibonacci (2)";
  assert_equal 8 (fibonacci 6) ~msg:"fibonacci (3)";
  assert_equal 144 (fibonacci 12) ~msg:"fibonacci (4)"

let test_log _ =
  assert_equal 1 (log 4 4) ~msg:"log (1)";
  assert_equal 2 (log 4 16) ~msg:"log (2)";
  assert_equal 1 (log 4 15) ~msg:"log (3)";
  assert_equal 3 (log 4 64) ~msg:"log (4)"

let test_gcf _ =
  assert_equal 0 (gcf 0 0) ~msg:"gcf (1)";
  assert_equal 3 (gcf 3 0) ~msg:"gcf (2)";
  assert_equal 4 (gcf 12 8) ~msg:"gcf (3)";
  assert_equal 6 (gcf 24 6) ~msg:"gcf (4)";
  assert_equal 1 (gcf 27 10) ~msg:"gcf (5)";
  assert_equal 13 (gcf 13 13) ~msg:"gcf (6)";
  assert_equal 32 (gcf 128 96) ~msg:"gcf (7)"

let test_max_func_chain _ =
  assert_equal 8 (maxFuncChain 2 [fun x -> x + 6]) ~msg:"maxFuncChain (1)";
  assert_equal 24
    (maxFuncChain 2 [fun x -> x + 4; fun x -> x * 4])
    ~msg:"maxFuncChain (2)";
  assert_equal (-1)
    (maxFuncChain (-4) [fun x -> x * 4; fun x -> x + 3])
    ~msg:"maxFuncChain (3)";
  assert_equal 14
    (maxFuncChain 4 [fun x -> x - 2; fun x -> x + 10])
    ~msg:"maxFuncChain (4)";
  assert_equal 501
    (maxFuncChain 0 [fun x -> x - 1; fun x -> x * (-500); fun x -> x + 1])
    ~msg:"maxFuncChain (5)"

let test_reverse _ =
  assert_equal [1] (reverse [1]) ~msg:"reverse (1)";
  assert_equal [3; 2; 1] (reverse [1; 2; 3]) ~msg:"reverse (2)";
  assert_equal [] (reverse []) ~msg:"reverse (3)";
  assert_equal ["c"; "b"; "a"] (reverse ["a"; "b"; "c"])
    ~msg:"reverse (4)"

let test_zip _ =
  assert_equal
    [ (1, 2, 7, 8); (3, 4, 9, 10); (5, 6, 11, 12) ]
    (zip [ (1, 2); (3, 4); (5, 6) ] [ (7, 8); (9, 10); (11, 12) ])
    ~msg:"zip (1)";
  assert_equal [] (zip [] []) ~msg:"zip (2)";
  assert_equal [] (zip [ (1, 4) ] []) ~msg:"zip (3)";
  assert_equal [ (1, 2, 7, 8) ]
    (zip [ (1, 2); (3, 4) ] [ (7, 8) ])
    ~msg:"zip (4)"

let test_is_palindrome _ =
  assert_equal true (is_palindrome [1; 2; 3; 2; 1]) ~msg:"is_palindrome (1)";
  assert_equal true (is_palindrome ["a"; "n"; "n"; "a"])
    ~msg:"is_palindrome (2)";
  assert_equal false (is_palindrome ["N"; "o"; "o"; "n"])
    ~msg:"is_palindrome (3)";
  assert_equal false (is_palindrome ["O"; "C"; "A"; "M"; "L"])
    ~msg:"is_palindrome (4)"

let test_square_primes _ =
  assert_equal [ (2, 4); (3, 9); (5, 25) ]
    (square_primes [1; 2; 3; 4; 5])
    ~msg:"square_primes (1)";
  assert_equal [ (11, 121); (13, 169) ]
    (square_primes [10; 11; 12; 13; 14])
    ~msg:"square_primes (2)";
  assert_equal [] (square_primes [4; 6; 8]) ~msg:"square_primes (3)";
  assert_equal [ (2, 4); (2, 4); (3, 9) ]
    (square_primes [2; 2; 3; 4])
    ~msg:"square_primes (4)"

let test_partition _ =
  assert_equal ([1; 2], [3; 4; 5])
    (partition (fun x -> x <= 2) [1; 2; 3; 4; 5])
    ~msg:"partition (1)";
  assert_equal ([10; 12; 14], [])
    (partition (fun x -> x <> 4) [10; 12; 14])
    ~msg:"partition (2)";
  assert_equal ([2; 4], [1; 3; 5])
    (partition is_even [1; 2; 3; 4; 5])
    ~msg:"partition (3)"

let test_is_present _ =
  let empty = [] in
  let letters = ["w"; "x"; "y"; "z"] in
  let values = [14; 20; 42; 1; 81] in
  assert_equal ~printer:string_of_int_list [] (is_present empty 123);
  assert_equal ~printer:string_of_int_list [0; 0; 1; 0]
    (is_present letters "y");
  assert_equal ~printer:string_of_int_list [0; 0; 0; 0]
    (is_present letters "v");
  assert_equal ~printer:string_of_int_list [0; 0; 1; 0; 0]
    (is_present values 42);
  assert_equal ~printer:string_of_int_list [1; 0; 0; 0; 0]
    (is_present values 14)

let test_count_occ _ =
  let letters = ["a"; "a"; "b"; "a"] in
  let values = [1; 7; 7; 1; 5; 2; 7; 7] in
  let booleans = [true; false; false; true; false; false; false] in
  let empty = [] in
  assert_equal ~printer:string_of_int_pair (3, 1)
    (count_occ letters "a", count_occ letters "b");
  assert_equal ~printer:string_of_int_quad (2, 4, 1, 1)
    (count_occ values 1, count_occ values 7, count_occ values 5, count_occ values 2);
  assert_equal ~printer:string_of_int_pair (2, 5)
    (count_occ booleans true, count_occ booleans false);
  assert_equal ~printer:string_of_int_pair (0, 0)
    (count_occ empty "a", count_occ empty 1)

let test_jumping_tuples _ =
  assert_equal [8; 3; 12; 1; 10; 5]
    (jumping_tuples [ (1, 2); (3, 4); (5, 6) ] [ (7, 8); (9, 10); (11, 12) ])
    ~msg:"jumping tuples (1)";
  assert_equal [false; false; true; true]
    (jumping_tuples [ (true, "a"); (false, "b") ] [ (100, false); (428, true) ])
    ~msg:"jumping tuples (2)";
  assert_equal ["sixth"; "third"; "first"; "eighth"]
    (jumping_tuples
       [ ("first", "second"); ("third", "fourth") ]
       [ ("fifth", "sixth"); ("seventh", "eighth") ])
    ~msg:"jumping tuples (3)";
  assert_equal [] (jumping_tuples [] []) ~msg:"jumping tuples (4)"

let test_addgenerator _ =
  assert_equal 7 ((addgenerator 4) 3) ~msg:"addgenerator (1)";
  assert_equal 5 ((addgenerator 1) 4) ~msg:"addgenerator (2)";
  assert_equal 22 ((addgenerator 11) 11) ~msg:"addgenerator (3)"

let test_uniq _ =
  let letters = ["a"; "a"; "b"; "a"] in
  let values = [1; 7; 7; 1; 5; 2; 7; 7] in
  let booleans = [true; false; false; true; false; false; false] in
  let empty = [] in
  let compare_values x y = if x < y then -1 else if x = y then 0 else 1 in
  assert_equal ~printer:string_of_string_list ["a"; "b"]
    (List.sort compare_values (uniq letters));
  assert_equal ~printer:string_of_int_list [1; 2; 5; 7]
    (List.sort compare_values (uniq values));
  assert_equal ~printer:string_of_bool_list [false; true]
    (List.sort compare_values (uniq booleans));
  assert_equal ~printer:string_of_int_list [] (uniq empty)

let test_ap _ =
  let first = [5; 6; 7; 3] in
  let second = [5; 6; 7] in
  let third = [7; 5] in
  let fourth = [3; 5; 8; 10; 9] in
  let singleton = [3] in
  let empty = [] in
  let functions = [(( + ) 2); (( * ) 7)] in
  let predecessor = [pred] in
  assert_equal ~printer:string_of_int_list [7; 8; 9; 5; 35; 42; 49; 21]
    (ap functions first);
  assert_equal ~printer:string_of_int_list [7; 8; 9; 35; 42; 49]
    (ap functions second);
  assert_equal ~printer:string_of_int_list [9; 7; 49; 35]
    (ap functions third);
  assert_equal ~printer:string_of_int_list [5; 7; 10; 12; 11; 21; 35; 56; 70; 63]
    (ap functions fourth);
  assert_equal ~printer:string_of_int_list [5; 21] (ap functions singleton);
  assert_equal ~printer:string_of_int_list [] (ap functions empty);
  assert_equal ~printer:string_of_int_list (map pred first) (ap predecessor first);
  assert_equal ~printer:string_of_int_list (map pred second) (ap predecessor second);
  assert_equal ~printer:string_of_int_list (map pred third) (ap predecessor third);
  assert_equal ~printer:string_of_int_list (map pred fourth) (ap predecessor fourth);
  assert_equal ~printer:string_of_int_list (map pred singleton)
    (ap predecessor singleton);
  assert_equal ~printer:string_of_int_list (map pred empty) (ap predecessor empty)

let suite =
  "functional utilities" >::: [
    "rev_tup" >:: test_rev_tup;
    "is_even" >:: test_is_even;
    "volume" >:: test_volume;
    "fibonacci" >:: test_fibonacci;
    "log" >:: test_log;
    "gcf" >:: test_gcf;
    "maxFuncChain" >:: test_max_func_chain;
    "reverse" >:: test_reverse;
    "zip" >:: test_zip;
    "jumping_tuples" >:: test_jumping_tuples;
    "is_palindrome" >:: test_is_palindrome;
    "square_primes" >:: test_square_primes;
    "partition" >:: test_partition;
    "addgenerator" >:: test_addgenerator;
    "is_present" >:: test_is_present;
    "count_occ" >:: test_count_occ;
    "uniq" >:: test_uniq;
    "ap" >:: test_ap;
  ]

let () = run_test_tt_main suite
