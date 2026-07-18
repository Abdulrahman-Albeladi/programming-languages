"""Render finite-state machines with Graphviz."""

from pathlib import Path
from typing import Any, Iterable

import graphviz


def _state_label(state: Any) -> str:
    """Return the display label used for a state."""
    if isinstance(state, list):
        return f'[{",".join(map(str, state))}]'
    return str(state)


def make_nodes(graph: graphviz.Digraph, nodes: Iterable[Any]) -> None:
    """Add FSM states to a Graphviz graph."""
    for node in nodes:
        graph.node(_state_label(node))


def make_transitions(
    graph: graphviz.Digraph,
    transitions: Iterable[tuple[Any, Any, Any]],
) -> None:
    """Add labeled FSM transitions to a Graphviz graph."""
    for start, symbol, end in transitions:
        label = "ε" if symbol == "epsilon" else str(symbol)
        graph.edge(_state_label(start), _state_label(end), label=label)


def make_start(graph: graphviz.Digraph, start_node: Any) -> None:
    """Add the unlabeled entry arrow for the initial state."""
    graph.node("", shape="none")
    graph.edge("", _state_label(start_node))


def make_finals(graph: graphviz.Digraph, final_states: Iterable[Any]) -> None:
    """Mark accepting FSM states with double circles."""
    for state in final_states:
        graph.node(_state_label(state), shape="doublecircle")


def make_visual(
    fsm: Any,
    filename: str = "output",
    cleanup: bool = True,
    output_directory: str = "visual_output",
) -> None:
    """Render an FSM visualization and open it in the system viewer.

    The FSM object must provide ``states``, ``transitions``, ``start``, and
    ``final`` attributes.
    """
    output_path = Path(output_directory)
    output_path.mkdir(parents=True, exist_ok=True)

    graph = graphviz.Digraph(
        filename,
        comment="NFA",
        engine="dot",
        graph_attr={"rankdir": "LR"},
    )

    make_nodes(graph, fsm.states)
    make_transitions(graph, fsm.transitions)
    make_start(graph, fsm.start)
    make_finals(graph, fsm.final)

    graph.render(
        directory=str(output_path),
        view=True,
        quiet=True,
        quiet_view=True,
        cleanup=cleanup,
    )
