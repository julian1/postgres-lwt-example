
let (>>=) = Lwt.bind

module Lwt_thread = struct
    include Lwt
    include Lwt_chan
end

module Lwt_PGOCaml = PGOCaml_generic.Make (Lwt_thread)

let run_query () =
    let query = "select * from pg_class where relnamespace = $1  "
    and name = "stmt1" (* nonce identifier of prepared statement *)
    in

    lwt db = Lwt_PGOCaml.connect ~host:"127.0.0.1" ~database: "meteo" ~user:"meteo" ~password:"meteo" () in
        (* Lwt_PGOCaml.verbose ref 2  >> *)
 
        Lwt_PGOCaml.prepare db ~query ~name () 
        >> Lwt_PGOCaml.execute db ~name ~params:[ Some (Lwt_PGOCaml.string_of_int 11) ] () 
        >>= fun s -> 
            Lwt_list.iter_s Util.print_row s 
        >> Lwt_PGOCaml.close db

let () = 
    run_query () |> 
    Lwt_main.run
