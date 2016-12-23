open Base

type t

val create
  :  ?dest_dir:string
  -> ?ocamlc:string
  -> ?log:(string -> unit)
  -> string (** name, such as library name *)
  -> t

(** Return the value associated to a variable in the output of [ocamlc -config] *)
val ocaml_config_var     : t -> string -> string option
val ocaml_config_var_exn : t -> string -> string

(** [c_test t ?c_flags ?link_flags c_code] try to compile and link the C code given in
    [c_code]. Return whether compilation was successful. *)
val c_test
  :  t
  -> ?c_flags:   string list (** default: [] *)
  -> ?link_flags:string list (** default: [] *)
  -> string
  -> bool

module C_define : sig
  module Type : sig
    type t =
      | Switch (** defined/undefined *)
      | Int
      | String
    [@@deriving compare, sexp]
  end

  module Value : sig
    type t =
      | Switch of bool
      | Int    of int
      | String of string
    [@@deriving compare, sexp]
  end

  (** Inport some #define from the given header files. For instance:

      {[
        # C.C_define.import c ~includes:"caml/config.h" ["ARCH_SIXTYFOUR", Switch];;
        - (string * Configurator.C_define.Value.t) list = ["ARCH_SIXTYFOUR", Switch true]
      ]}
  *)
  val import
    :  t
    -> ?c_flags:   string list
    -> ?link_flags:string list
    -> includes:   string list
    -> (string * Type.t ) list
    -> (string * Value.t) list

  (** Generate a C header file containing the following #define. [protection_var] is used
      to enclose the file with:

      {[
        #ifndef BLAH
        #define BLAH
        ...
        #endif
      ]}

      If not specified, it is inferred from the name given to [create] and the
      filename. *)
  val gen_header_file
    :  t
    -> fname:string
    -> ?protection_var:string
    -> (string * Value.t) list -> unit
end

(** Typical entry point for configurator programs *)
val main
  :  ?args:(Caml.Arg.key * Caml.Arg.spec * Caml.Arg.doc) list
  -> name:string
  -> (t -> unit)
  -> unit

(** Abort execution. If raised from within [main], the argument of [die] is printed as
    [Error: <message>]. *)
val die : ('a, unit, string, 'b) format4 -> 'a