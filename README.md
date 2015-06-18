
sudo apt-get install libpcre3-dev
opam install pgocaml

corebuild -package pgocaml,lwt,lwt.unix,lwt.syntax main.byte

refs
http://docs.camlcity.org/docs/godipkg/3.12/godi-pgocaml/lib/ocaml/pkg-lib/pgocaml/pGOCaml_generic.mli


see also, for thread functor parametization, and dealing with connections

https://github.com/thomas-huet/lwt-pgocaml/blob/master/thread.ml

