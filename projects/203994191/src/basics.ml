(** Small functional-programming utilities over tuples, integers, and lists. *)

let rev_tup (a, b, c) = (c, b, a)

let is_even x = x mod 2 = 0

let volume (x1, y1, z1) (x2, y2, z2) =
  let width = abs (x2 - x1) in
  let height = abs (y2 - y1) in
  let depth = abs (z2 - z1) in
  width * height * depth

let rec fibonacci n =
  if n < 0 then invalid_arg "fibonacci: expected a non-negative integer"
  else
    match n with
    | 0 -> 0
    | 1 -> 1
    | n -> fibonacci (n - 1) + fibonacci (n - 2)

(** [log base value] is the largest exponent [n] such that [base ^ n <= value]. *)
let rec log base value =
  if base <= 1 then invalid_arg "log: base must be greater than 1"
  else if base > value then 0
  else 1 + log base (value / base)

let rec gcf x y =
  let x = abs x in
  let y = abs y in
  if y = 0 then x else gcf y (x mod y)

(** Return the greatest value among [init] and each function applied to [init]. *)
let rec maxFuncChain init funcs =
  match funcs with
  | [] -> init
  | func :: rest -> max (func init) (maxFuncChain init rest)

let rec reverse lst =
  match lst with
  | [] -> []
  | head :: tail -> reverse tail @ [ head ]

let rec zip lst1 lst2 =
  match (lst1, lst2) with
  | (a1, b1) :: rest1, (a2, b2) :: rest2 ->
      (a1, b1, a2, b2) :: zip rest1 rest2
  | _ -> []

let is_palindrome lst =
  let rec compare left right =
    match (left, right) with
    | [], [] -> true
    | x :: left_tail, y :: right_tail when x = y ->
        compare left_tail right_tail
    | _ -> false
  in
  compare lst (reverse lst)

let is_prime n =
  let rec check_divisor divisor =
    if divisor * divisor > n then true
    else if n mod divisor = 0 then false
    else check_divisor (divisor + 1)
  in
  n >= 2 && check_divisor 2

(** Keep prime values paired with the truncated square root of each value. *)
let rec square_primes lst =
  match lst with
  | [] -> []
  | value :: rest when is_prime value ->
      (value, int_of_float (sqrt (float_of_int value))) :: square_primes rest
  | _ :: rest -> square_primes rest

let rec partition predicate lst =
  match lst with
  | [] -> ([], [])
  | first :: rest ->
      let matching, remaining = partition predicate rest in
      if predicate first then (first :: matching, remaining)
      else (matching, first :: remaining)

(** Return an indicator list marking elements equal to [x]. *)
let is_present lst x =
  List.map (fun value -> if value = x then 1 else 0) lst

let count_occ lst target =
  List.fold_left
    (fun count value -> if value = target then count + 1 else count)
    0 lst

(* The available implementation selects first components from the first list. *)
let jumping_tuples lst1 _lst2 = List.map fst lst1

let addgenerator x = fun y -> x + y

let uniq lst =
  let contains value values = List.exists (fun candidate -> candidate = value) values in
  let add value values = if contains value values then values else value :: values in
  reverse (List.fold_right add lst [])

let ap fns args =
  List.fold_left
    (fun results fn -> results @ List.map fn args)
    [] fns
