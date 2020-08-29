(* Kernel services *)
module Random = Sihl.Utils.Random.Service
module Log = Sihl.Log.Service
module Config = Sihl.Config.Service.Make (Log)
module Db = Sihl.Data.Db.Service.Make (Config) (Log)
module MigrationRepo = Sihl.Data.Migration.Service.Repo.MakeMariaDb (Db)
module Cmd = Sihl.Cmd.Service
module Migration =
  Sihl.Data.Migration.Service.Make (Log) (Cmd) (Db) (MigrationRepo)
module WebServer = Sihl.Web.Server.Service.Make (Cmd)
module Schedule = Sihl.Schedule.Service.Make (Log)
module Repo = Sihl.Data.Repo.Service

(* Configuration providers *)
module EmailConfigProvider = Sihl.Email.Service.EnvConfigProvider (Config)

(* Repositories *)
module EmailTemplateRepo =
  Sihl.Email.Service.Template.Repo.MakeMariaDb (Db) (Repo) (Migration)

(* Services *)
module EmailTemplate =
  Sihl.Email.Service.Template.Make (Log) (EmailTemplateRepo)
module Email =
  Sihl.Email.Service.Make.Smtp (EmailTemplate) (EmailConfigProvider)
