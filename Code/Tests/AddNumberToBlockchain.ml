(*bin/lead -r remoteuser@remotehost -i 1 -s 2018031233300*)

open Lwt.Infix
open Ptime
let remote_uri = ref None
let itr = ref 0
let id = ref 0
let start_time = ref (Ptime_clock.now())
let parse_is_local str = 
  remote_uri := Some(str);
  Printf.printf "\n\027[93mUsing leader address:\027[39m %s\n%!" str
let parse_itr num = 
  itr := num
let parse_id num = 
  id := num
let parse_time input = 
  let year = int_of_string (String.sub input 0 4) in
  let month = int_of_string (String.sub input 4 2) in
  let day = int_of_string (String.sub input 6 2) in
  let hour = int_of_string (String.sub input 8 2) in
  let min = int_of_string (String.sub input 10 2) in 
  let sec = 0 in
  let time: Ptime.time = ((hour, min, sec),0) in 
  let date: Ptime.date = (year, month, day) in
  match Ptime.of_date_time (date, time) with
  | Some(new_date) -> start_time := new_date;
  | _ -> ()

let remote_tuple = ("-r", Arg.String parse_is_local, "Specify the remote repository in the form user@host")
let itr_tuple = ("-n", Arg.Int parse_itr, "Specify the number of transactions you'd like to add to the blockchain")
let start_tuple = ("-s", Arg.String parse_time, "Specify when this should begin")
let id_tuple = ("-i", Arg.Int parse_id, "Specify machine id")

let _ = Arg.parse [remote_tuple; itr_tuple; id_tuple; start_tuple] (fun _ -> ()) ""

type transaction = string * string * float
module Config : Blockchain.I_ParticipantConfig with type t = transaction = struct 
  type t = transaction
  module LogCoder = LogStringCoder.TestLogStringCoder
  let leader_uri = !remote_uri
  let validator = None
end

module Participant = Blockchain.MakeParticipant(Config)

let rec add_transactions = function
  | 0 -> Lwt.return ()
  | n -> Participant.add_transaction_to_mempool (string_of_int(!id), "txn", 1.0) >>= fun _ ->
    add_transactions (n-1)

let rec test_blockchain_start() = 
  let now = Ptime_clock.now() in 
  match now > !start_time with  
    | true -> add_transactions !itr
    | false -> Lwt_unix.sleep 0.1 >>= fun _ -> test_blockchain_start();;

Lwt_main.run @@ test_blockchain_start();;