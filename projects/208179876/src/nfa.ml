open Sets

type ('q, 's) transition = 'q * 's option * 'q

type ('q, 's) nfa_t = {
  sigma : 's list;
  qs : 'q list;
  q0 : 'q;
  fs : 'q list;
  delta : ('q, 's) transition list;
}

let explode (s : string) : char list =
  let rec loop index characters =
    if index < 0 then characters
    else loop (index - 1) (s.[index] :: characters)
  in
  loop (String.length s - 1) []

let transition_source (source, _, _) = source
let transition_symbol (_, symbol, _) = symbol
let transition_destination (_, _, destination) = destination

let add_matching_destination symbol states destinations transition =
  if transition_symbol transition = symbol
     && elem (transition_source transition) states
     && not (elem (transition_destination transition) destinations)
  then insert (transition_destination transition) destinations
  else destinations

let move (nfa : ('q, 's) nfa_t) (states : 'q list) (symbol : 's option) : 'q list =
  match symbol with
  | Some value when not (elem value nfa.sigma) -> []
  | _ -> List.fold_left (add_matching_destination symbol states) [] nfa.delta

let e_closure (nfa : ('q, 's) nfa_t) (states : 'q list) : 'q list =
  let rec loop closure =
    let expanded =
      List.fold_left (add_matching_destination None closure) closure nfa.delta
    in
    if eq closure expanded then closure else loop expanded
  in
  loop states

let accept (nfa : ('q, char) nfa_t) (input : string) : bool =
  let step states character =
    states
    |> e_closure nfa
    |> fun closure -> move nfa closure (Some character)
    |> e_closure nfa
  in
  let final_states =
    match explode input with
    | [] -> e_closure nfa [nfa.q0]
    | characters -> List.fold_left step [nfa.q0] characters
  in
  not (eq [] (intersection final_states nfa.fs))

let new_states (nfa : ('q, 's) nfa_t) (states : 'q list) : 'q list list =
  List.fold_left
    (fun destinations symbol ->
      let destination = e_closure nfa (move nfa states (Some symbol)) in
      insert destination destinations)
    [] nfa.sigma

let new_trans (nfa : ('q, 's) nfa_t) (states : 'q list) : ('q list, 's) transition list =
  List.fold_left
    (fun transitions symbol ->
      let destination = e_closure nfa (move nfa states (Some symbol)) in
      insert (states, Some symbol, destination) transitions)
    [] nfa.sigma

let new_finals (nfa : ('q, 's) nfa_t) (states : 'q list) : 'q list list =
  if eq [] (intersection states nfa.fs) then [] else [states]

let rec nfa_to_dfa_step
    (nfa : ('q, 's) nfa_t)
    (states_to_process : 'q list list)
    (visited : 'q list list)
    (transitions : ('q list, 's) transition list)
    (states : 'q list list)
    (finals : 'q list list) :
    ('q list, 's) transition list * 'q list list * 'q list list =
  match diff states_to_process visited with
  | [] -> (transitions, states, finals)
  | current :: remaining ->
      let pending, transitions, states, finals =
        List.fold_left
          (fun (pending, transitions, states, finals) symbol ->
            let destination = e_closure nfa (move nfa current (Some symbol)) in
            if eq [] destination then (pending, transitions, states, finals)
            else
              let pending =
                if elem destination pending then pending else insert destination pending
              in
              let states =
                if elem destination states then states else insert destination states
              in
              let finals =
                if elem destination finals
                   || eq [] (intersection destination nfa.fs)
                then finals
                else insert destination finals
              in
              ( pending,
                insert (current, Some symbol, destination) transitions,
                states,
                finals ))
          (remaining, transitions, states, finals)
          nfa.sigma
      in
      let next = diff pending visited in
      nfa_to_dfa_step nfa next (insert current visited) transitions states finals

let nfa_to_dfa (nfa : ('q, 's) nfa_t) : ('q list, 's) nfa_t =
  let start_state = e_closure nfa [nfa.q0] in
  let initial_finals =
    if eq [] (intersection start_state nfa.fs) then [] else [start_state]
  in
  let transitions, states, finals =
    nfa_to_dfa_step nfa [start_state] [] [] [start_state] initial_finals
  in
  {
    sigma = nfa.sigma;
    qs = states;
    q0 = start_state;
    fs = finals;
    delta = transitions;
  }
