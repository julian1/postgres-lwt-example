
let (>>=) = Lwt.bind
let return  = Lwt.return

module Lwt_thread = struct
    include Lwt
    include Lwt_chan
end

module Lwt_PGOCaml = PGOCaml_generic.Make (Lwt_thread)

type result_description = Lwt_PGOCaml.result_description 

let log = Lwt_io.write_line Lwt_io.stdout

let fold_m f acc lst =
  let adapt f acc e = acc >>= fun acc -> f acc e in
  List.fold_left (adapt f) (Lwt.return acc) lst 


let run_query () =

    lwt db = Lwt_PGOCaml.connect ~host:"127.0.0.1" ~database: "meteo" ~user:"meteo" ~password:"meteo" () in
         (* Lwt_PGOCaml.verbose (ref 2 ) >>  *)

        (* no ssl *) 
        (* let name = "stmt1" in nonce identifier of prepared statement *)
        let query = "select * from pg_class where relnamespace = $1  " in
        Lwt_PGOCaml.prepare db ~query (* ~name*) () 
        >> Lwt_PGOCaml.execute db (* ~name*) ~params:[ Some (Lwt_PGOCaml.string_of_int 11) ] () 
        >>= fun rows -> 
           
            (* how do we convert the result 
                perhaps with a zip...
            *) 

            (* Lwt_list.iter_s (fun s -> Util.print_row s ) s  *)

            Lwt_list.iter_s (fun (row:Lwt_PGOCaml.row) -> 
              

                fold_m (
                    fun acc e -> e |> function 
                      | Some field -> log field 
                      | _ -> return ()
                  )  
                    
                  () row 

                 ) rows
        >> 
            Lwt_PGOCaml.describe_statement db ()
        >>= function  
             | (param_desc, Some row_desc) -> 
                  let f acc (e : result_description ) =  

                      let oid = e.field_type in
                      let oid_ = Int32.to_string oid in

                      let name_of_oid = try (Lwt_PGOCaml.name_of_type oid)
                        with _ -> "unknown" in

                      log @@ e.name ^ " " ^ oid_  ^ " " ^ name_of_oid
                  in
                  fold_m f () row_desc
              | _ -> Lwt.return ()

(*
val describe_statement : 'a t -> ?name:string -> unit -> (params_description * row_description option) monad
(** [describe_statement conn ?name ()] describes the named or unnamed
*) 
*)

        >> Lwt_PGOCaml.close db

let () = 
    run_query () |> 
    Lwt_main.run
