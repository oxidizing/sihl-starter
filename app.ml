let services : (module Sihl.Core.Container.SERVICE) list =
  [ (module Service.WebServer); (module Service.Email) ]

let hello_page =
  Sihl.Web.Route.get "/hello/" (fun _ ->
      Sihl.Web.Res.(html |> set_body "Hello!") |> Lwt.return)

let hello_api =
  Sihl.Web.Route.get "/hello/" (fun _ ->
      Sihl.Web.Res.(json |> set_body {|{"msg":"Hello!"}|}) |> Lwt.return)

let routes = [ ("/page", [ hello_page ], []); ("/api", [ hello_api ], []) ]

let send_example_email_cmd =
  Sihl.Cmd.make ~name:"send-example-email" ~help:"<recipient_email>"
    ~description:
      "Send an example email that contains plain text and html content to \
       <recipient_email>."
    ~fn:(fun args ->
      match args with
      | [ recipient ] ->
          let ctx = Sihl.Core.Ctx.empty in
          let email =
            Sihl.Email.make ~sender:"foo@example.com" ~recipient
              ~subject:"Test email" ~text_content:"This is pure text content"
              ~html_content:
                "<span>This is <b>HTML</b> content, you should see parts of \
                 this text <b>bold</b></span>"
              ~html:true ()
          in
          Service.Email.send ctx email
      | _ ->
          raise
            (Sihl.Cmd.Invalid_usage
               "Usage: <smtp_host> <smtp_username> <smtp_password> <smtp_port> \
                <start_tls> <recipient_email>"))
    ()

module App = Sihl.App.Make (Service)

let _ =
  App.(
    empty |> with_services services |> with_endpoints routes
    |> with_commands [ send_example_email_cmd ]
    |> run)
