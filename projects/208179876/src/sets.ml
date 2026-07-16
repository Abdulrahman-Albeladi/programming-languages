(** List-backed set operations using polymorphic equality. *)

let rec elem x = function
  | h :: t -> h = x || elem x t
  | [] -> false

let insert x set =
  if elem x set then set else x :: set

let insert_all values set =
  List.fold_right insert values set

let rec subset a b =
  match a with
  | h :: t -> elem h b && subset t b
  | [] -> true

let eq a b =
  subset a b && subset b a

let rec remove x = function
  | h :: t -> if h = x then t else h :: remove x t
  | [] -> []

let rec diff a = function
  | [] -> a
  | h :: t -> diff (remove h a) t

let minus = diff

let rec union a b =
  match a with
  | h :: t -> insert h (union t b)
  | [] ->
      (match b with
      | h :: t -> insert h (union [] t)
      | [] -> [])

let rec intersection a b =
  match a with
  | h :: t ->
      if elem h b then insert h (intersection t b) else intersection t b
  | [] -> []

let rec product a b =
  let rec product_with x = function
    | h :: t -> insert (x, h) (product_with x t)
    | [] -> []
  in
  match a with
  | h :: t -> union (product_with h b) (product t b)
  | [] -> []

let rec cat x = function
  | [] -> []
  | h :: t -> (x, h) :: cat x t
