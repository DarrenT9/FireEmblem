open Gui
open State
open Types
open Room
open Command

module Html = Dom_html
let js = Js.string (* partial function, takes in string *)
let document = Html.document

(* NOTE: Change this section to make it less similar to Zoldas *)
(************************ DOM HELPERS ************************)

(* [fail] is a failure/exception handler *)
let fail = fun _ -> assert false

(* [get_element_by_id id] gets a DOM element by its id *)
let get_element_by_id id =
  Js.Opt.get (Html.document##getElementById (js id)) fail

let temp_character =
  {
    name = "Lyn";
    stage= Done;
    class' = Paladin;
    growths = [];
    caps = [];
    level = 0;
    exp = 0;
    health = (0,0);
    allegiance = Player;
    str = 0;
    mag = 0;
    def = 0;
    spd = 0;
    res = 0;
    skl = 0;
    lck = 0;
    mov = 0;
    con = 0;
    aid = 0;
    hit = 0;
    atk = 0;
    crit = 0;
    avoid = 0;
    inv = [];
    eqp = None;
    ability = [];
    supports = [];
    wlevels = [];
    ai = BossHunt;
    location= (5,5);
    movement= [];
    direction= North;
  }


(* [append_text e s] appends string s to element e *)
let append_text e s = Dom.appendChild e (document##createTextNode (js s))

let init_state =
  {
    player = [temp_character];
    items = [];
    enemies = [];
    allies = [];
    won = false;
    active_tile = {coordinate = (5,5); ground = Plain; tile_type = Grass;c=None};
    active_unit = None;
    act_map = {width = 0; length = 0; grid = Room.map1.grid};
    menus = [];
    current_menu = {size = 0; options = []};
    menu_active = false;
    menu_cursor = 0;
    funds = 0;
  }

(* [main ()] is begins game execution by first building and designing
 * the html page and designing and subsequently calling the REPL to
 * start execution using the game engine *)
let main () =
  let gui = get_element_by_id "gui" in
  let body = get_element_by_id "body" in
  let logo = Html.createImg document in
  let p1 = Html.createP document in
  let p2 = Html.createP document in
  let p3 = Html.createP document in
  let audio = Html.createAudio document in
  let canvas = Html.createCanvas document in
  gui##style##textAlign <- js "center";
  body##style##backgroundImage <-js "url('Sprites/background.png')";
  body##style##backgroundRepeat <- js "no-repeat";
  logo##src <- js "Sprites/Logo.png";
  audio##src <- js "Sprites/Music/MainTheme.mp3";
  audio##play ();
  gui##style##cssText <- js "font-size:16px";
  gui##style##textAlign <- js "center";
  canvas##width <- int_of_float Gui.canvas_width;
  canvas##height <- int_of_float Gui.canvas_height;
  append_text p1 "Welcome to Fire Emblem! Some stuff about the game ...";
  append_text p2 "Developed by: Frank Rodriguez, Albert Tsao, Darren Tsai, and Ray Gu";
  append_text p3 "for our 3110 final project. Thanks for playing!";
  Dom.appendChild gui logo;
  Dom.appendChild gui p1;
  Dom.appendChild gui canvas;
  Dom.appendChild gui p2;
  Dom.appendChild gui p3;
  let context = canvas##getContext (Html._2d_) in

  (* Add event listeners to the HTML for key press and key
   * lift events. *)
  let _ = Html.addEventListener
      document Html.Event.keydown (Html.handler Command.keydown)
      Js._true in

  let game_loop context bol =
    let rec loop () =
      Gui.draw_state context init_state;
      Html.window##requestAnimationFrame(
        Js.wrap_callback (fun (t:float) -> loop ())
      ) |> ignore
    in loop ()
  in game_loop context false


(* Begin the game *)
let _ = main ()
