open P5.Nfa
open P5.Regexp

let string_of_int_list values =
  "[" ^ String.concat ";" (List.map string_of_int values) ^ "]"

let string_of_int_list_list values =
  "[" ^ String.concat ";" (List.map string_of_int_list values) ^ "]"

let nodup value values = if List.mem value values then values else value :: values

let escape_dot_label value =
  let buffer = Buffer.create (String.length value) in
  String.iter
    (function
      | '\\' -> Buffer.add_string buffer "\\\\"
      | '"' -> Buffer.add_string buffer "\\\""
      | '\n' -> Buffer.add_string buffer "\\n"
      | '\r' -> Buffer.add_string buffer "\\r"
      | '\t' -> Buffer.add_string buffer "\\t"
      | character -> Buffer.add_char buffer character)
    value;
  Buffer.contents buffer

let dot_node_id label = "node_" ^ Digest.to_hex (Digest.string label)

let string_of_vtx _ vertices =
  List.fold_left
    (fun output (vertex, is_final) ->
      let shape = if is_final then "doublecircle" else "circle" in
      output
      ^ Printf.sprintf "  %s [label=\"%s\", shape=%s];\n"
          (dot_node_id vertex)
          (escape_dot_label vertex)
          shape)
    "" vertices

let string_of_ed _ edges =
  List.fold_left
    (fun output ((source, _), label, _, (destination, _)) ->
      output
      ^ Printf.sprintf "  %s -> %s [label=\"%s\"];\n"
          (dot_node_id source)
          (dot_node_id destination)
          (escape_dot_label label))
    "" edges

let getenv_opt name =
  try Some (Sys.getenv name) with Not_found -> None

let output_path () =
  match getenv_opt "AUTOMATA_VIZ_OUTPUT" with
  | Some path when path <> "" -> path
  | _ -> "output.png"

let write_file path contents =
  let channel = open_out_bin path in
  try
    output_string channel contents;
    close_out channel
  with error ->
    close_out_noerr channel;
    raise error

let write_nfa_to_graphviz (show : 'q -> string) (nfa : ('q, char) nfa_t) : bool =
  let start_state, final_states, transitions = nfa.q0, nfa.fs, nfa.delta in
  let start_vertex = (show start_state, List.mem start_state final_states) in
  let vertices, edges =
    List.fold_left
      (fun (vertices, edges) (source, character, destination) ->
        let source_vertex = (show source, List.mem source final_states) in
        let destination_vertex =
          (show destination, List.mem destination final_states)
        in
        let label =
          match character with
          | None -> "ε"
          | Some value -> String.make 1 value
        in
        let edge = (source_vertex, label, false, destination_vertex) in
        ( nodup destination_vertex (nodup source_vertex vertices),
          nodup edge edges ))
      ([], []) transitions
  in
  let dot =
    "digraph G {\n"
    ^ "  rankdir=LR;\n"
    ^ "  __start [shape=point, label=\"\"];\n"
    ^ string_of_vtx show (start_vertex :: vertices)
    ^ Printf.sprintf "  __start -> %s;\n" (dot_node_id (show start_state))
    ^ string_of_ed show edges
    ^ "}\n"
  in
  let image_path = output_path () in
  let dot_path = image_path ^ ".dot" in
  try
    write_file dot_path dot;
    let command =
      Printf.sprintf "dot -Tpng %s -o %s" (Filename.quote dot_path)
        (Filename.quote image_path)
    in
    if Sys.command command = 0 then
      try
        Sys.remove dot_path;
        true
      with Sys_error _ -> false
    else false
  with Sys_error _ -> false

let read_prompt prompt =
  print_string prompt;
  flush stdout;
  try read_line () with End_of_file -> exit 0

let () =
  let expression = read_prompt "Regular expression to visualize: " in
  let target = read_prompt "Convert to DFA (y/n)? " in
  let nfa = string_to_nfa expression in
  let success =
    if target = "n" then write_nfa_to_graphviz string_of_int nfa
    else write_nfa_to_graphviz string_of_int_list (nfa_to_dfa nfa)
  in
  if success then
    Printf.printf "Visualization written to %s.\n" (output_path ())
  else
    prerr_endline
      "Unable to render the automaton. Ensure Graphviz is installed and the output path is writable."
