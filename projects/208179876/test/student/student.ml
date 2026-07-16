open OUnit2

let test_harness_runs _ =
  assert_bool "test harness runs" true

let suite =
  "student"
  >::: [ "harness_runs" >:: test_harness_runs ]

let () = run_test_tt_main suite
