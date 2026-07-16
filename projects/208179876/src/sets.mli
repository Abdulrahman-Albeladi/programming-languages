(** List-backed sets with polymorphic equality.

    Operations preserve the order implied by their input lists. *)

val elem : 'a -> 'a list -> bool
(** [elem x xs] is [true] when [x] occurs in [xs]. *)

val insert : 'a -> 'a list -> 'a list
(** [insert x xs] adds [x] to [xs] when it is not already present. *)

val insert_all : 'a list -> 'a list -> 'a list
(** [insert_all xs ys] adds the elements of [xs] to [ys]. *)

val subset : 'a list -> 'a list -> bool
(** [subset xs ys] is [true] when every element of [xs] occurs in [ys]. *)

val eq : 'a list -> 'a list -> bool
(** [eq xs ys] is [true] when [xs] and [ys] contain the same elements. *)

val remove : 'a -> 'a list -> 'a list
(** [remove x xs] removes occurrences of [x] from [xs]. *)

val minus : 'a list -> 'a list -> 'a list
(** [minus xs ys] removes from [xs] the elements occurring in [ys]. *)

val union : 'a list -> 'a list -> 'a list
(** [union xs ys] contains the elements of both input sets. *)

val intersection : 'a list -> 'a list -> 'a list
(** [intersection xs ys] contains elements shared by both input sets. *)

val product : 'a list -> 'b list -> ('a * 'b) list
(** [product xs ys] is the Cartesian product of [xs] and [ys]. *)

val diff : 'a list -> 'a list -> 'a list
(** [diff xs ys] returns the symmetric difference of [xs] and [ys]. *)

val cat : 'a -> 'b list -> ('a * 'b) list
(** [cat x ys] pairs [x] with every element of [ys]. *)
