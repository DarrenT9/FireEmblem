open Types


(**The current map*)
type map

(**The current state of the game*)
type state = {
  player: character list;
  items : item list;
  enemies: enemy list;
  maps : map list;
  map_act: map;
  active_tile: tile;
  active_unit: character option;
  menus:(string*menu) list;
  active_menu:menu option;
  menu_cursor: string option;
}

val get_rng : unit -> int

(**[init_state json] initializes the game board from the save file [json]*)
val init_state : 'json -> state

(**[do' act st] returns the state after an input action [act]*)
val do' : action -> state -> state
