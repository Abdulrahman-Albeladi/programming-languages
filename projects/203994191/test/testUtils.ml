open OUnit2

let assert_true value = assert_equal true value
let assert_false value = assert_equal false value

let string_of_string value = value

let string_of_list string_of_element values =
  "[" ^ String.concat "; " (List.map string_of_element values) ^ "]"

let string_of_pair string_of_first string_of_second (first, second) =
  "(" ^ string_of_first first ^ ", " ^ string_of_second second ^ ")"

let string_of_option string_of_value = function
  | Some value -> string_of_value value
  | None -> "None"

let string_of_int_pair = string_of_pair string_of_int string_of_int
let string_of_string_int_pair = string_of_pair string_of_string string_of_int
let string_of_bool_int_pair = string_of_pair string_of_bool string_of_int
let string_of_float_int_pair = string_of_pair string_of_float string_of_int

let string_of_int_triple _ _ _ (first, second, third) =
  "("
  ^ string_of_int first
  ^ ", "
  ^ string_of_int second
  ^ ", "
  ^ string_of_int third
  ^ ")"

let string_of_int_quad (first, second, third, fourth) =
  "("
  ^ string_of_int first
  ^ ", "
  ^ string_of_int second
  ^ ", "
  ^ string_of_int third
  ^ ", "
  ^ string_of_int fourth
  ^ ")"

let string_of_int_list = string_of_list string_of_int
let string_of_int_pair_list = string_of_list string_of_int_pair
let string_of_bool_list = string_of_list string_of_bool
let string_of_float_list = string_of_list string_of_float
let string_of_bool_int_pair_list = string_of_list string_of_bool_int_pair
let string_of_string_int_pair_list = string_of_list string_of_string_int_pair
let string_of_float_int_pair_list = string_of_list string_of_float_int_pair
let string_of_string_list = string_of_list string_of_string
let string_of_string_list_list = string_of_list string_of_string_list
let string_of_string_option = string_of_option string_of_string
let string_of_string_list_option = string_of_option string_of_string_list
