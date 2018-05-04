open Types
open State

let js = Js.string (* partial function, takes in string *)

let canvas_width = 676. (* 390 *)
let canvas_height = 676. (* 260 *)

module Html = Dom_html
let js = Js.string
let document = Html.document

let clock = ref 1
let sync = ref true
let midattack = ref false

(*********************************************************)
(***************** Map Drawing Functions *****************)
(*********************************************************)

(* [obj_to_img_mapping obj] returns the image source
 * location of the associated object *)
let tile_to_img_mapping (tile : tile) =
  match tile.tile_type with
  | Grass  -> js "Sprites/grass.png"
  | Tree  -> js "Sprites/tree.png"
  | Crack  -> js "Sprites/Crack.png"
  | Bridge  -> js "Sprites/Bridge.png"
  | Bush  -> js "Sprites/Bush.png"
  | Darkbush  -> js "Sprites/Darkbush.png"
  | Water1  -> js "Sprites/Water1.png"
  | Water2  -> js "Sprites/Water2.png"
  | Water3  -> js "Sprites/Water3.png"
  | Water4  -> js "Sprites/Water4.png"
  | Water5  -> js "Sprites/Water5.png"
  | Water6  -> js "Sprites/Water6.png"
  | Water7  -> js "Sprites/Water7.png"
  | Water8  -> js "Sprites/Water8.png"
  | Water9  -> js "Sprites/Water9.png"
  | Wall1  -> js "Sprites/Wall1.png"
  | Wall2  -> js "Sprites/Wall2.png"
  | Wall3  -> js "Sprites/Wall3.png"
  | Wall4  -> js "Sprites/Wall4.png"
  | Wall5  -> js "Sprites/Wall5.png"
  | Wall6  -> js "Sprites/Wall6.png"


(* [draw_tiles map] draws each of the tiles in map's
 * tile list by finding the associated image *)
let draw_map (context: Html.canvasRenderingContext2D Js.t) state =
  context##fillStyle <- js "black";
  context##fillRect (0.,0.,canvas_width,canvas_height);
  let draw_tiles (grid : tile array array) =
    for i = 0 to 14 do
      for j = 0 to 9 do
        let tile = grid.(i).(j) in
        let x = fst tile.coordinate in
        let y = snd tile.coordinate in
        let img_src = tile_to_img_mapping tile in
        let img = Html.createImg document in
        img##src <- img_src;
        context##drawImage (img, 26.*.float_of_int x, 26.*.float_of_int y)
      done
    done in
   draw_tiles state.act_map.grid

   (* [draw_tiles map] draws each of the tiles in map's
 * tile list by finding the associated image *)
let draw_map_9x9 (context: Html.canvasRenderingContext2D Js.t) state =
  context##fillStyle <- js "black";
  context##fillRect (0.,0.,canvas_width,canvas_height);
  let draw_tiles (grid : tile array array) =
    for i = 0 to 2 do
      for j = 0 to 2 do
        let tile = grid.(i).(j) in
        let x = fst tile.coordinate in
        let y = snd tile.coordinate in
        let img_src = tile_to_img_mapping tile in
        let img = Html.createImg document in
        img##src <- img_src;
        context##drawImage (img, float_of_int x, float_of_int y)
      done
    done in
   draw_tiles state.act_map.grid

(* let possible_movement_tiles context state = *)



(*********************************************************)
(**************** Cursor Drawing Functions ***************)
(*********************************************************)

(* [real_time_clock] updates the clock at every loop of the game.
 * Every 30 "time" units, sync is negated which represents the
 * static movement of the cursor and players *)
let real_time_clock () =
  clock := if !clock < 25 then !clock + 1 else 1;
  let x1 = !clock mod 25 in (* bounds *)
  let x2 = !clock mod 30 in (* middle for standing *)
  match x1,x2 with
  | 0,_ -> sync := not(!sync)
  | _,0 -> midattack := not(!midattack)
  | _,_ -> ()

(* [draw_cursor context tile] draws the cursor (big) on the
 * canvas given the integer location defined in tile *)
let draw_cursor_big (context: Html.canvasRenderingContext2D Js.t) tile =
  let (x,y) = tile.coordinate in
  let img = Html.createImg document in
  img##src <- js "Sprites/CursorLarge.png";
  context##drawImage (img, 26. *. float_of_int x, 26. *. float_of_int y)

(* [draw_cursor context tile] draws the cursor (small) on the
 * canvas given the integer location defined in tile *)
let draw_cursor_small (context: Html.canvasRenderingContext2D Js.t) tile =
  let (x,y) = tile.coordinate in
  let img = Html.createImg document in
  img##src <- js "Sprites/CursorSmall.png";
  context##drawImage (img, 26. *. float_of_int x, 26. *. float_of_int y)

(* [draw_cursor context tile] chooses to draw a big cursor or small
 * cursor based on the current synchornization reference (sync) and
 * then draws that cursor on the coordinate defined by tile *)
let draw_cursor (context: Html.canvasRenderingContext2D Js.t) tile =
  match (!sync) with
  | true ->
    draw_cursor_small context tile
  | false ->
    draw_cursor_big context tile


(*********************************************************)
(**************** Sprite Drawing Functions ***************)
(*********************************************************)

(* [testf context] is a debugging function *)
let testf context =
  let img = Html.createImg document in
  img##src <- js "Sprites/databackground.png";
  context##drawImage (img, 0.,0.)

(* [draw_sprite] draws the sprite located at (sx,sy) with
 * sw width and sh height inside the spritesheet and 
 * projects it onto the canvas at location (x,y) *)
let draw_sprite img_src context (sx, sy) (sw, sh) (x,y) =
  let img = Html.createImg document in
  img##src <- img_src;
  context##drawImage_full (img, sx, sy, sw, sh, x, y, 25., 25.)

(* [draw_lyn context character] draws the proper sprite configuration 
 * for the character lyn based on the character's direction and stage 
 * fields  *)
let draw_lyn (context: Html.canvasRenderingContext2D Js.t) character =
  let img = js "Sprites/lynsheet.png" in
  match character.direction with
  | South -> begin
      match character.stage with
      | Ready -> begin
        match ((!sync)) with
        | true ->
            let sprite_coordinate = (417., 400.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x),26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        | false ->
            let sprite_coordinate = (457., 399.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x),26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        end
      | Moving -> begin
        match ((!sync)) with
        | true->
            let sprite_coordinate = (463., 419.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x) +. 6.,26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        | false ->
            let sprite_coordinate = (420., 420.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x) +. 6.,26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        end
        (* Must finish attacking animation!...fix this so that it guarantees animation will always finish *)
      | Attacking -> begin
        match ((!sync)) with
        | true->
            let sprite_coordinate = (463., 419.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x) +. 6.,26. *. (float_of_int y) +. 6.) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        | false ->
            let sprite_coordinate = (420., 420.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x) +. 6.,26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        end
      | Done -> begin
        match ((!sync)) with
        | true ->
            let sprite_coordinate = (417., 400.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x),26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        | false ->
            let sprite_coordinate = (457., 399.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x),26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
      end
    end
  | East -> begin
      match character.stage with
      | Ready -> begin
        match ((!sync)) with
        | true ->
            let sprite_coordinate = (417., 400.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x),26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        | false ->
            let sprite_coordinate = (457., 399.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x),26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        end
      | Moving -> begin
        match ((!sync)) with
        | true->
            let sprite_coordinate = (418., 442.) in
            let sprite_wxl = (16., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x) +. 0.,26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        | false ->
            let sprite_coordinate = (441., 442.) in
            let sprite_wxl = (16., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x) +. 0.,26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        end
        (* Must finish attacking animation!...fix this so that it guarantees animation will always finish *)
      | Attacking -> begin
        match ((!sync)) with
        | true->
            let sprite_coordinate = (418., 442.) in
            let sprite_wxl = (16., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x) +. 6.,26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        | false ->
            let sprite_coordinate = (441., 442.) in
            let sprite_wxl = (16., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x) +. 0.,26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        end
      | Done -> begin
        match ((!sync)) with
        | true ->
            let sprite_coordinate = (417., 400.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x),26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        | false ->
            let sprite_coordinate = (457., 399.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x),26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
      end
    end
  | North -> begin
      match character.stage with
      | Ready -> begin
        match ((!sync)) with
        | true ->
            let sprite_coordinate = (417., 400.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x),26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        | false ->
            let sprite_coordinate = (457., 399.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x),26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        end
      | Moving -> begin
        match ((!sync)) with
        | true->
            let sprite_coordinate = (419., 461.) in
            let sprite_wxl = (16., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x) +. 0.,26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        | false ->
            let sprite_coordinate = (442., 461.) in
            let sprite_wxl = (16., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x) +. 0.,26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        end
        (* Must finish attacking animation!...fix this so that it guarantees animation will always finish *)
      | Attacking -> begin
        match ((!sync)) with
        | true->
            let sprite_coordinate = (419., 461.) in
            let sprite_wxl = (16., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x) +. 0.,26. *. (float_of_int y) -. 6.) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        | false ->
            let sprite_coordinate = (442., 461.) in
            let sprite_wxl = (16., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x) +. 0.,26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        end
      | Done -> begin
        match ((!sync)) with
        | true ->
            let sprite_coordinate = (417., 400.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x),26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
        | false ->
            let sprite_coordinate = (457., 399.) in
            let sprite_wxl = (15., 16.) in
            let (x,y) = character.location in
            let coordinate = (26. *. (float_of_int x),26. *. (float_of_int y)) in
            draw_sprite img context sprite_coordinate sprite_wxl coordinate
      end
    end
  | West -> ()

(* [draw_player context character_list] draws all the characters inside
 * the character_list *)
let draw_player (context: Html.canvasRenderingContext2D Js.t) character_list =
  match character_list with
  | [] -> ()
  | h::t ->
    match h.name with
    | "Lyn" -> draw_lyn context h
    | _ -> ()

  (* NOTES:
    1. Moving Down: Left foot = 420 420 and Right foot = 463 419  *)

(*********************************************************)
(***************** Menu Drawing Functions ****************)
(*********************************************************)
(* [draw_menu_movement_back context] draws the background to the
 * movement menu *)
let draw_unit_back context =
  let x = 286. in
  let y = 26. in
  let rec ys x y =
    if x = 364. then ()
    else
      let img = Html.createImg document in
      img##src <- js "Sprites/databackground.png";
      context##drawImage (img, x,y);
      if y = 156. then ys (x+.26.) 26. else ys x (y+.26.) in
  ys x y

(* [unit_movement context] draws text onto the movement menu *)
let menu_unit context =
  context##strokeStyle <- js "white";
  context##font <- js "16px sans-serif";
  context##lineWidth <- Js.float 1.0;
  context##strokeRect (286., 26. ,83.,160.);
  context##strokeText (js "Visit", 300., 50.);
  context##strokeText (js "Attack", 300., 75.);
  context##strokeText (js "Item", 300., 100.);
  context##strokeText (js "Wait", 300., 125.);
  context##strokeText (js "Trade", 300., 150.);
  context##strokeText (js "Open", 300., 175.)

(* [draw_unit_menu context] draws a unit menu
 * on the canvas.*)
let draw_unit_menu context =
  draw_unit_back context;
  menu_unit context


let draw_item_back context =
  let x = 286. in
  let y = 26. in
  let rec ys x y =
    if x = 364. then ()
    else
      let img = Html.createImg document in
      img##src <- js "Sprites/databackground.png";
      context##drawImage (img, x,y);
      if y = 52. then ys (x+.26.) 26. else ys x (y+.26.) in
  ys x y

let menu_item context =
  context##strokeStyle <- js "white";
  context##font <- js "Arial";
  context##strokeRect (286., 26. ,83.,56.);
  context##strokeText (js "Equip/Use", 290., 48.);
  context##strokeText (js "Discard", 300., 73.)

(* [draw_item_menu context] draws an item menu
 * on the canvas.*)
let draw_item_menu context =
  draw_item_back context;
  menu_item context

let draw_tile_back context =
  let x = 286. in
  let y = 26. in
  let rec ys x y =
    if x = 364. then ()
    else
      let img = Html.createImg document in
      img##src <- js "Sprites/databackground.png";
      context##drawImage (img, x,y);
      if y = 104. then ys (x+.26.) 26. else ys x (y+.26.) in
  ys x y

let menu_tile context =
  context##strokeStyle <- js "white";
  context##font <- js "Arial";
  context##strokeRect (286., 26. ,83.,108.);
  context##strokeText (js "Unit", 300., 50.);
  context##strokeText (js "Status", 300., 75.);
  context##strokeText (js "Suspend", 300., 100.);
  context##strokeText (js "End", 300., 125.)

(* [draw_tile_menu context] draws a tile menu
 * on the canvas.*)
let draw_tile_menu context =
  draw_tile_back context;
  menu_tile context


(* [menu_manager context state] draws a menu
 * if is active, otherwise does nothing *)
let menu_manager context state =
  if state.menu_active then
    match state.current_menu with
    | unit_menu -> draw_unit_menu context;
    | tile_menu -> draw_tile_menu context;
    | item_menu -> draw_item_menu context;
  else ()

(*********************************************************)
(****************** Draw State Functions *****************)
(*********************************************************)

(* [draw_selection_board] draws the red and blue
 * tiles around the player which signifies valid
 * moves *)
(* let draw_selection_board =
  failwith "aaaaaaaa" *)

(* Drawing *)
let draw_state (context: Html.canvasRenderingContext2D Js.t) state =
  context##clearRect (0., 0., canvas_width, canvas_height);
  draw_map context state;
  draw_cursor context state.active_tile;
  draw_player context state.player;
  draw_unit_menu context;
  real_time_clock ();
  (* menu_manager context state *)
