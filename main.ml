
let (>>=) = Lwt.bind

module Lwt_thread = struct
    include Lwt
    include Lwt_chan
end

module Lwt_PGOCaml = PGOCaml_generic.Make (Lwt_thread)

let log = Lwt_io.write_line Lwt_io.stdout

let fold_m f acc lst =
  let adapt f acc e = acc >>= fun acc -> f acc e in
  List.fold_left (adapt f) (Lwt.return acc) lst 


let run_query () =

    lwt db = Lwt_PGOCaml.connect ~host:"127.0.0.1" ~database: "meteo" ~user:"meteo" ~password:"meteo" () in
         (* Lwt_PGOCaml.verbose (ref 2 ) >>  *)
 
        (* let name = "stmt1" in nonce identifier of prepared statement *)
        let query = "select * from pg_class where relnamespace = $1  " in
        Lwt_PGOCaml.prepare db ~query (* ~name*) () 
        >> Lwt_PGOCaml.execute db (* ~name*) ~params:[ Some (Lwt_PGOCaml.string_of_int 11) ] () 
        >>= fun s -> 
           
            (* how do we convert the result *) 

            Lwt_list.iter_s (fun s -> Util.print_row s ) s 

        >> 
            Lwt_PGOCaml.describe_statement db ()
        >>= fun (param_desc,row_desc) -> 
            match row_desc with 
                Some row_desc' -> ( 
                    fold_m (fun acc (e : Lwt_PGOCaml.result_description ) -> log e.name  ) () row_desc'  
                ) 

(*
val describe_statement : 'a t -> ?name:string -> unit -> (params_description * row_description option) monad
(** [describe_statement conn ?name ()] describes the named or unnamed
*) 
*)

        >> Lwt_PGOCaml.close db

let () = 
    run_query () |> 
    Lwt_main.run
